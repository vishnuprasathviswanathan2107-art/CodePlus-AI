global class FinalReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            CodingReminderService.sendFinalTenPmReminder();
        } catch (Exception e) {
            System.debug('FinalReminderScheduler error: ' + e.getMessage());
        }
    }
}
