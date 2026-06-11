// Abort scheduled CronTriggers and AsyncApexJobs for CodePulse classes
List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN ('DailyMaintenanceScheduler','DailyCodingScheduler','LeetCodeLiveTracker','EmailQueueable','DailyCodingScheduler','DailyMaintenanceScheduler')];
for (CronTrigger c : ct) {
    try {
        System.abortJob(c.Id);
        System.debug('Aborted CronTrigger: ' + c.CronJobDetail.Name + ' id=' + c.Id);
    } catch (Exception e) {
        System.debug('Failed to abort CronTrigger ' + c.Id + ': ' + e.getMessage());
    }
}

List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE ApexClass.Name IN ('DailyMaintenanceScheduler','DailyCodingScheduler','LeetCodeLiveTracker','EmailQueueable') AND Status IN ('Queued','Holding','Processing')];
for (AsyncApexJob j : jobs) {
    try {
        System.abortJob(j.Id);
        System.debug('Aborted AsyncApexJob: ' + j.ApexClass.Name + ' id=' + j.Id);
    } catch (Exception e) {
        System.debug('Failed to abort AsyncApexJob ' + j.Id + ': ' + e.getMessage());
    }
}
