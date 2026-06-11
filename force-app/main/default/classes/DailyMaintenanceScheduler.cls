global class DailyMaintenanceScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            DailyProblemService.rotateDailyProblems();
            LeetCodeLiveTracker.validateDailySolve();
        } catch (Exception e) {
            System.debug('DailyMaintenanceScheduler error: ' + e.getMessage());
        }
    }
}
