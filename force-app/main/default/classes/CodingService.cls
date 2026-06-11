public with sharing class CodingService {

    public class ServiceResult {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String message;
    }

    public static Id createUser(
        String fullName,
        String email,
        String leetCodeUsername,
        String codeChefUsername,
        Time reminderTime,
        Time morningSummary,
        Boolean reminderEnabled
    ) {
        Coding_User__c cu = new Coding_User__c(
            Full_Name__c = fullName,
            Email__c = email,
            LeetCode_Username__c = leetCodeUsername,
            CodeChef_Username__c = codeChefUsername,
            Current_Streak__c = 0,
            Total_Solved__c = 0,
            Longest_Streak__c = 0,
            Reminder_Enabled__c = reminderEnabled,
            Reminder_Time__c = reminderTime,
            Morning_Summary_Time__c = morningSummary,
            Motivation_Emails__c = true
        );

        insert cu;
        return cu.Id;
    }

    public static void deleteUser(Id userId) {
        if (userId == null) {
            return;
        }
        Coding_User__c cu = [SELECT Id FROM Coding_User__c WHERE Id = :userId LIMIT 1];
        delete cu;
    }

    public static void markProblemSolved(Id problemId, Id userId) {
        if (problemId == null || userId == null) {
            return;
        }
        ProblemCompletionService.markProblemComplete(problemId, userId);
    }
}
