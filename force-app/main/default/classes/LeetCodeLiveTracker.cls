public with sharing class LeetCodeLiveTracker {

    public static void validateDailySolve() {
        Date yesterday = Date.today().addDays(-1);

        List<Coding_User__c> staleUsers = [
            SELECT Id, Current_Streak__c, Last_Solved_Date__c, Full_Name__c, Email__c,
                   Reminder_Enabled__c
            FROM Coding_User__c
            WHERE Current_Streak__c > 0
              AND (Last_Solved_Date__c = NULL OR Last_Solved_Date__c < :yesterday)
        ];

        if (staleUsers.isEmpty()) {
            return;
        }

        for (Coding_User__c user : staleUsers) {
            user.Current_Streak__c = 0;
        }

        try {
            update staleUsers;
        } catch (DmlException e) {
            System.debug('Failed to reset streaks: ' + e.getMessage());
        }
    }

    public static void sendDailyReminders() {
        CodingReminderService.sendDailyReminderEmails();
    }
}
