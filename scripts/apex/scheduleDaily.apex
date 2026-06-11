// Abort existing CodePulse jobs before rescheduling
for (CronTrigger job : [
    SELECT Id, CronJobDetail.Name
    FROM CronTrigger
    WHERE CronJobDetail.Name LIKE 'CodePulse%'
]) {
    System.abortJob(job.Id);
}

System.schedule('CodePulse Daily Maintenance', '0 0 1 * * ?', new DailyMaintenanceScheduler());
System.schedule('CodePulse Problem Rotation', '0 0 0 * * ?', new DailyProblemRotationScheduler());
System.schedule('CodePulse Morning Motivation', '0 0 8 * * ?', new MorningMotivationScheduler());
System.schedule('CodePulse Daily Reminder', '0 0 20 * * ?', new DailyReminderScheduler());
System.schedule('CodePulse Five Hour Reminder', '0 0 0/5 * * ?', new TwoHourReminderScheduler());
System.schedule('CodePulse Final Reminder 10PM', '0 0 22 * * ?', new FinalReminderScheduler());

System.debug('Scheduled all CodePulse automation jobs.');
