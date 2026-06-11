public with sharing class CodingReminderService {

    public static void sendMorningMotivationEmails() {
        List<Coding_User__c> users = [
            SELECT Id, Full_Name__c, Email__c, Motivation_Emails__c,
                   Morning_Summary_Time__c, Last_Solved_Date__c
            FROM Coding_User__c
            WHERE Motivation_Emails__c = true
              AND Email__c != null
        ];

        List<Coding_User__c> recipients = filterByTimeWindow(
            users,
            'Morning_Summary_Time__c',
            8,
            0
        );

        CodingEmailService.sendBulkReminders(recipients, 'morning');
    }

    public static void sendDailyReminderEmails() {
        DailyProblemService.ensureProblemsForDate(Date.today());

        List<Coding_User__c> users = [
            SELECT Id, Full_Name__c, Email__c, Reminder_Enabled__c,
                   Reminder_Time__c, Last_Solved_Date__c
            FROM Coding_User__c
            WHERE Reminder_Enabled__c = true
              AND Email__c != null
              AND (Last_Solved_Date__c = null OR Last_Solved_Date__c != TODAY)
        ];

        List<Coding_User__c> recipients = filterByTimeWindow(
            users,
            'Reminder_Time__c',
            20,
            0
        );

        CodingEmailService.sendBulkReminders(recipients, 'daily');
    }

    public static void sendFiveHourReminders() {
        DailyProblemService.ensureProblemsForDate(Date.today());
        List<Coding_User__c> users = getReminderEligibleUsers();
        List<Coding_User__c> pending = filterPendingUsers(users);
        if (!pending.isEmpty()) {
            CodingEmailService.sendBulkReminders(pending, 'nudge');
        }
    }

    public static void sendFinalTenPmReminder() {
        DailyProblemService.ensureProblemsForDate(Date.today());
        List<Coding_User__c> users = getReminderEligibleUsers();
        List<Coding_User__c> pending = filterPendingUsers(users);
        if (!pending.isEmpty()) {
            CodingEmailService.sendBulkReminders(pending, 'final');
        }
    }

    public static void sendTwoHourNudges() {
        // Backward-compatible wrapper for older scheduler classes.
        sendFiveHourReminders();
    }

    private static List<Coding_User__c> getReminderEligibleUsers() {
        return [
            SELECT Id, Full_Name__c, Email__c, Reminder_Enabled__c, Last_Solved_Date__c
            FROM Coding_User__c
            WHERE Reminder_Enabled__c = true
              AND Email__c != null
        ];
    }

    private static List<Coding_User__c> filterPendingUsers(List<Coding_User__c> users) {
        List<Coding_User__c> pending = new List<Coding_User__c>();
        for (Coding_User__c user : users) {
            if (!ProblemCompletionService.hasCompletedAllTodayProblems(user.Id)) {
                pending.add(user);
            }
        }
        return pending;
    }

    private static List<Coding_User__c> filterByTimeWindow(
        List<Coding_User__c> users,
        String timeField,
        Integer defaultHour,
        Integer defaultMinute
    ) {
        Datetime nowDt = Datetime.now();
        Integer currentHour = nowDt.hour();
        Integer currentMinute = nowDt.minute();
        List<Coding_User__c> matched = new List<Coding_User__c>();

        for (Coding_User__c user : users) {
            Time scheduledTime = (Time) user.get(timeField);
            Integer hour = defaultHour;
            Integer minute = defaultMinute;

            if (scheduledTime != null) {
                hour = scheduledTime.hour();
                minute = scheduledTime.minute();
            }

            if (hour == currentHour && Math.abs(minute - currentMinute) <= 30) {
                matched.add(user);
            }
        }

        return matched;
    }
}
