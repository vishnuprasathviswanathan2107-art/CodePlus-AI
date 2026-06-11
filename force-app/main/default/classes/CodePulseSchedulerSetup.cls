public with sharing class CodePulseSchedulerSetup {

    public static void scheduleDailyRotation() {
        abortJobs('CodePulse_Rotation');

        System.schedule(
            'CodePulse_Rotation_11PM',
            DailyProblemRotationScheduler.getRotationCron(),
            new DailyProblemRotationScheduler()
        );
    }

    private static void abortJobs(String nameContains) {
        for (CronTrigger job : [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :('%' + nameContains + '%')
        ]) {
            System.abortJob(job.Id);
        }
    }
}
