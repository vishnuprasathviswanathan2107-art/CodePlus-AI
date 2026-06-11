global class TwoHourReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            // Runs every 5 hours via cron; class name retained for compatibility.
            CodingReminderService.sendFiveHourReminders();
        } catch (Exception e) {
            System.debug('TwoHourReminderScheduler error: ' + e.getMessage());
        }
    }
}
