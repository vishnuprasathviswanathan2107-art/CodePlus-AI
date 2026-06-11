List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType, State, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name LIKE '%Daily%' OR CronJobDetail.Name LIKE '%CodePulse%' LIMIT 200];
System.debug('CronTriggers: ' + JSON.serialize(ct));
for (CronTrigger c : ct) System.debug('CronTrigger: ' + c.Id + ' name=' + c.CronJobDetail.Name + ' state=' + c.State + ' next=' + c.NextFireTime);
