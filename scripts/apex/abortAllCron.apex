List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name LIKE '%CodePulse%' OR CronJobDetail.Name LIKE '%LeetCode%' OR CronJobDetail.Name LIKE '%Daily%' OR CronJobDetail.Name LIKE '%Email%' LIMIT 200];
System.debug('Found ' + ct.size() + ' CronTriggers to abort');
for (CronTrigger c : ct) {
    try {
        System.abortJob(c.Id);
        System.debug('Aborted CronTrigger: ' + c.CronJobDetail.Name + ' id=' + c.Id + ' state=' + c.State);
    } catch (Exception e) {
        System.debug('Failed to abort CronTrigger ' + c.Id + ': ' + e.getMessage());
    }
}
