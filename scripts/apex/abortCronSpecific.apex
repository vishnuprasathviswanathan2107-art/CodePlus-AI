List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'CodePulse Daily Maintenance' LIMIT 10];
for (CronTrigger c : ct) {
    try {
        System.abortJob(c.Id);
        System.debug('Aborted scheduled job: ' + c.CronJobDetail.Name + ' id=' + c.Id);
    } catch (Exception e) {
        System.debug('Failed to abort CronTrigger ' + c.Id + ': ' + e.getMessage());
    }
}
