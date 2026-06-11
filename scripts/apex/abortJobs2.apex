List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, Status, CronTriggerId FROM AsyncApexJob WHERE ApexClass.Name IN ('DailyMaintenanceScheduler','DailyCodingScheduler','LeetCodeLiveTracker','EmailQueueable') AND Status IN ('Queued','Holding','Processing')];
for (AsyncApexJob j : jobs) {
    try {
        if (j.CronTriggerId != null) {
            System.abortJob(j.CronTriggerId);
            System.debug('Aborted CronTrigger via AsyncApexJob: ' + j.CronTriggerId + ' for class ' + j.ApexClass.Name);
        } else {
            System.abortJob(j.Id);
            System.debug('Aborted AsyncApexJob: ' + j.Id + ' for class ' + j.ApexClass.Name);
        }
    } catch (Exception e) {
        System.debug('Failed to abort job ' + j.Id + ': ' + e.getMessage());
    }
}
