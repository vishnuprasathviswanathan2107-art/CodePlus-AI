for (CronTrigger job : [SELECT Id FROM CronTrigger]) {
    System.abortJob(job.Id);
}
for (AsyncApexJob job : [SELECT Id FROM AsyncApexJob WHERE Status IN ('Queued', 'Preparing', 'Processing', 'Holding')]) {
    System.abortJob(job.Id);
}
