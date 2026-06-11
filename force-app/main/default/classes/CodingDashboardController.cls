public with sharing class CodingDashboardController {

    public class DashboardData {
        @AuraEnabled public List<Coding_User__c> users;
        @AuraEnabled public Daily_Problem__c leetcodeToday;
        @AuraEnabled public Daily_Problem__c leetcodeTomorrow;
        @AuraEnabled public Daily_Problem__c codechefToday;
        @AuraEnabled public Daily_Problem__c codechefTomorrow;
        @AuraEnabled public List<Id> completedProblemIds;
        @AuraEnabled public String motivationQuote;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData(Id selectedUserId) {
        DashboardData data = new DashboardData();
        data.motivationQuote = 'Consistency beats talent when talent does not work hard.';
        data.completedProblemIds = new List<Id>();

        data.users = [
            SELECT Id, Name, Full_Name__c, Email__c,
                   LeetCode_Username__c, CodeChef_Username__c,
                   Avatar_URL__c, Current_Streak__c, Longest_Streak__c,
                   Total_Solved__c, Reminder_Time__c, Morning_Summary_Time__c,
                   Reminder_Enabled__c, Motivation_Emails__c, Last_Solved_Date__c,
                   Last_Daily_Email_Sent__c
            FROM Coding_User__c
            ORDER BY Current_Streak__c DESC, CreatedDate DESC
        ];

        Date today = Date.today();
        Date tomorrow = today.addDays(1);

        data.leetcodeToday = DailyProblemService.queryProblemForDateAndPlatform(
            today,
            DailyProblemService.PLATFORM_LEETCODE
        );
        data.leetcodeTomorrow = DailyProblemService.queryProblemForDateAndPlatform(
            tomorrow,
            DailyProblemService.PLATFORM_LEETCODE
        );
        data.codechefToday = DailyProblemService.queryProblemForDateAndPlatform(
            today,
            DailyProblemService.PLATFORM_CODECHEF
        );
        data.codechefTomorrow = DailyProblemService.queryProblemForDateAndPlatform(
            tomorrow,
            DailyProblemService.PLATFORM_CODECHEF
        );

        if (selectedUserId != null) {
            data.completedProblemIds = new List<Id>(
                ProblemCompletionService.getCompletedProblemIdsForUser(selectedUserId, today)
            );
        }

        return data;
    }

    @AuraEnabled
    public static void ensureDailyProblems() {
        DailyProblemService.rotateDailyProblems();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAnalytics() {
        Map<String, Object> analytics = new Map<String, Object>();

        analytics.put('totalUsers', [SELECT COUNT() FROM Coding_User__c]);

        analytics.put('activeUsers', [
            SELECT COUNT()
            FROM Coding_User__c
            WHERE Current_Streak__c > 0
        ]);

        analytics.put('solvedToday', [
            SELECT COUNT()
            FROM Coding_User__c
            WHERE Last_Solved_Date__c = TODAY
        ]);

        List<Daily_Problem__c> todayProblems = [
            SELECT Completed_Count__c
            FROM Daily_Problem__c
            WHERE Problem_Date__c = TODAY
        ];
        Integer completions = 0;
        for (Daily_Problem__c p : todayProblems) {
            completions += p.Completed_Count__c == null ? 0 : Integer.valueOf(p.Completed_Count__c);
        }
        analytics.put('todayCompletions', completions);

        List<Coding_User__c> topUser = [
            SELECT Name, Full_Name__c, Current_Streak__c, Longest_Streak__c
            FROM Coding_User__c
            ORDER BY Current_Streak__c DESC
            LIMIT 1
        ];

        if (!topUser.isEmpty()) {
            analytics.put('topCoder', topUser[0].Full_Name__c != null ? topUser[0].Full_Name__c : topUser[0].Name);
            analytics.put('topStreak', topUser[0].Current_Streak__c);
            analytics.put('longestStreak', topUser[0].Longest_Streak__c);
        }

        return analytics;
    }

    @AuraEnabled(cacheable=true)
    public static List<Coding_User__c> getLeaderboard() {
        return [
            SELECT Id, Name, Full_Name__c, Avatar_URL__c,
                   Current_Streak__c, Total_Solved__c, Longest_Streak__c
            FROM Coding_User__c
            ORDER BY Current_Streak__c DESC, Total_Solved__c DESC
            LIMIT 10
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Coding_User__c> getSolvedLeaderboard() {
        return [
            SELECT Id, Name, Full_Name__c, Avatar_URL__c, Total_Solved__c, Current_Streak__c
            FROM Coding_User__c
            ORDER BY Total_Solved__c DESC
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static Map<String, Object> markProblemSolved(Id problemId, Id userId) {
        ProblemCompletionService.CompletionResult result =
            ProblemCompletionService.markProblemComplete(problemId, userId);

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('alreadySolvedToday', result.alreadyCompleted);
        payload.put('streak', result.streak);
        payload.put('totalSolved', result.totalSolved);
        payload.put('streakUpdated', result.streakUpdated);
        return payload;
    }
}
