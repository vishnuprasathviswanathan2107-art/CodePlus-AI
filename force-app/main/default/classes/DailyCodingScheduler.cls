global class DailyCodingScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        new DailyMaintenanceScheduler().execute(sc);
    }
}
