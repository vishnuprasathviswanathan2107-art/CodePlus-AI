public with sharing class ProblemCompletionService {

    public class CompletionResult {
        @AuraEnabled public Boolean alreadyCompleted;
        @AuraEnabled public Boolean streakUpdated;
        @AuraEnabled public Integer streak;
        @AuraEnabled public Integer totalSolved;
    }

    public static CompletionResult markProblemComplete(Id problemId, Id userId) {
        if (problemId == null || userId == null) {
            throw new AuraHandledException('Both problemId and userId are required');
        }

        List<Daily_Problem__c> probs = [
            SELECT Id, Completed_Count__c, Problem_Date__c, Platform__c, Topic__c
            FROM Daily_Problem__c
            WHERE Id = :problemId
            LIMIT 1
        ];
        if (probs.isEmpty()) {
            throw new AuraHandledException('Daily problem not found');
        }

        List<Coding_User__c> users = [
            SELECT Id, Current_Streak__c, Longest_Streak__c, Total_Solved__c,
                   Last_Solved_Date__c, Full_Name__c, Email__c
            FROM Coding_User__c
            WHERE Id = :userId
            LIMIT 1
        ];
        if (users.isEmpty()) {
            throw new AuraHandledException('User not found');
        }

        Daily_Problem__c problem = probs[0];
        Coding_User__c user = users[0];
        Date today = Date.today();

        if (hasUserCompletedProblem(userId, problemId)) {
            CompletionResult existing = new CompletionResult();
            existing.alreadyCompleted = true;
            existing.streakUpdated = false;
            existing.streak = Integer.valueOf(user.Current_Streak__c == null ? 0 : user.Current_Streak__c);
            existing.totalSolved = Integer.valueOf(user.Total_Solved__c == null ? 0 : user.Total_Solved__c);
            return existing;
        }

        Boolean alreadySolvedToday = user.Last_Solved_Date__c == today;

        if (Schema.sObjectType.User_Problem_Completion__c.isCreateable()) {
            insert new User_Problem_Completion__c(
                Coding_User__c = userId,
                Daily_Problem__c = problemId,
                Completed_On__c = today
            );
        }

        if (problem.Completed_Count__c == null) {
            problem.Completed_Count__c = 0;
        }
        problem.Completed_Count__c += 1;

        CodingUserService.applySolve(user, problem);

        update new List<sObject>{ problem, user };

        CompletionResult result = new CompletionResult();
        result.alreadyCompleted = false;
        result.streakUpdated = !alreadySolvedToday;
        result.streak = Integer.valueOf(user.Current_Streak__c == null ? 0 : user.Current_Streak__c);
        result.totalSolved = Integer.valueOf(user.Total_Solved__c == null ? 0 : user.Total_Solved__c);

        if (!alreadySolvedToday) {
            try {
                CodingEmailService.sendCongratulations(user, result.streak, problem);
            } catch (Exception e) {
                System.debug('Congrats email skipped: ' + e.getMessage());
            }
        }

        return result;
    }

    public static Boolean hasUserCompletedProblem(Id userId, Id problemId) {
        if (userId == null || problemId == null) {
            return false;
        }
        return ![SELECT Id FROM User_Problem_Completion__c
                 WHERE Coding_User__c = :userId AND Daily_Problem__c = :problemId
                 LIMIT 1].isEmpty();
    }

    public static Set<Id> getCompletedProblemIdsForUser(Id userId, Date onDate) {
        Set<Id> completedIds = new Set<Id>();
        if (userId == null || onDate == null) {
            return completedIds;
        }

        for (User_Problem_Completion__c row : [
            SELECT Daily_Problem__c
            FROM User_Problem_Completion__c
            WHERE Coding_User__c = :userId
              AND Completed_On__c = :onDate
        ]) {
            completedIds.add(row.Daily_Problem__c);
        }
        return completedIds;
    }

    public static Boolean hasCompletedAllTodayProblems(Id userId) {
        List<Daily_Problem__c> todayProblems = DailyProblemService.getProblemsForDate(Date.today());
        if (todayProblems.isEmpty()) {
            return false;
        }

        Set<Id> completed = getCompletedProblemIdsForUser(userId, Date.today());
        for (Daily_Problem__c problem : todayProblems) {
            if (!completed.contains(problem.Id)) {
                return false;
            }
        }
        return true;
    }

    public static Boolean hasCompletedAnyTodayProblem(Id userId) {
        Set<Id> completed = getCompletedProblemIdsForUser(userId, Date.today());
        return !completed.isEmpty();
    }
}
