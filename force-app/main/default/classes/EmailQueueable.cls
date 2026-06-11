public with sharing class EmailQueueable implements Queueable {

    private Id userId;
    private String type;

    public EmailQueueable(Id userId, String type) {
        this.userId = userId;
        this.type = type;
    }

    public void execute(QueueableContext context) {
        if (userId == null) {
            return;
        }

        List<Coding_User__c> users = [
            SELECT Id, Full_Name__c, Email__c, Motivation_Emails__c
            FROM Coding_User__c
            WHERE Id = :userId
            LIMIT 1
        ];

        if (users.isEmpty() || String.isBlank(users[0].Email__c)) {
            return;
        }

        Coding_User__c user = users[0];

        if (type == 'welcome') {
            CodingEmailService.sendWelcome(user);
        } else if (type == 'reminder') {
            DailyProblemService.ensureProblemsForDate(Date.today());
            Daily_Problem__c problem = DailyProblemService.queryProblemForDateAndPlatform(
                Date.today(),
                DailyProblemService.PLATFORM_LEETCODE
            );
            CodingEmailService.sendDailyReminder(user, problem);
        } else if (type == 'morning') {
            CodingEmailService.sendMorningMotivation(user);
        } else {
            DailyProblemService.ensureProblemsForDate(Date.today());
            Daily_Problem__c problem = DailyProblemService.queryProblemForDateAndPlatform(
                Date.today(),
                DailyProblemService.PLATFORM_LEETCODE
            );
            CodingEmailService.sendDailyReminder(user, problem);
        }
    }
}
