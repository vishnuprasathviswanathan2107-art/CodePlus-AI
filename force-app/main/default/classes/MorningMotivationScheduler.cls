global class MorningMotivationScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            CodingReminderService.sendMorningMotivationEmails();
        } catch (Exception e) {
            System.debug('MorningMotivationScheduler error: ' + e.getMessage());
        }
    }
}
