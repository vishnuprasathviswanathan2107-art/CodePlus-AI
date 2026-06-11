global class DailyReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            CodingReminderService.sendDailyReminderEmails();
        } catch (Exception e) {
            System.debug('DailyReminderScheduler error: ' + e.getMessage());
        }
    }
}
