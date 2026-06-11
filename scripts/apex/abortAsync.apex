List<AsyncApexJob> jobs = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Status IN ('Queued','Processing','Preparing') AND (ApexClass.Name LIKE '%Daily%' OR ApexClass.Name LIKE '%LeetCode%' OR ApexClass.Name LIKE '%Email%' OR ApexClass.Name LIKE '%Coding%') LIMIT 200];
System.debug('Found ' + jobs.size() + ' AsyncApexJobs to abort');
for (AsyncApexJob j : jobs) {
    try {
        System.abortJob(j.Id);
        System.debug('Aborted AsyncApexJob: ' + j.ApexClass.Name + ' id=' + j.Id + ' status=' + j.Status);
    } catch (Exception e) {
        System.debug('Failed to abort AsyncApexJob ' + j.Id + ': ' + e.getMessage());
    }
}
