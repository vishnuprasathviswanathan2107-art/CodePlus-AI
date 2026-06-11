@IsTest
private class DailyProblemServiceTest {

    @IsTest
    static void createsTodayAndTomorrowProblemsForBothPlatforms() {
        Test.startTest();
        DailyProblemService.rotateDailyProblems();
        Test.stopTest();

        List<Daily_Problem__c> problems = [
            SELECT Problem_Date__c, Platform__c
            FROM Daily_Problem__c
            WHERE Problem_Date__c IN (:Date.today(), :Date.today().addDays(1))
        ];

        System.assertEquals(4, problems.size(), 'Should create 2 platforms for today and tomorrow');
    }

    @IsTest
    static void markSolveUpdatesStreakOncePerDay() {
        Daily_Problem__c problem = DailyProblemService.ensureProblemForDateAndPlatform(
            Date.today(),
            DailyProblemService.PLATFORM_LEETCODE
        );
        Coding_User__c user = new Coding_User__c(
            Full_Name__c = 'Test User',
            Email__c = 'test@example.com',
            Current_Streak__c = 0,
            Total_Solved__c = 0,
            Reminder_Enabled__c = true
        );
        insert user;

        Test.startTest();
        ProblemCompletionService.markProblemComplete(problem.Id, user.Id);
        ProblemCompletionService.markProblemComplete(problem.Id, user.Id);
        Test.stopTest();

        user = [
            SELECT Current_Streak__c, Total_Solved__c, Last_Solved_Date__c
            FROM Coding_User__c
            WHERE Id = :user.Id
        ];

        System.assertEquals(1, user.Current_Streak__c);
        System.assertEquals(1, user.Total_Solved__c);
        System.assertEquals(Date.today(), user.Last_Solved_Date__c);
    }

    @IsTest
    static void rotationSendsEmailsAndSchedulesNudge() {
        Coding_User__c user = new Coding_User__c(
            Full_Name__c = 'Email User',
            Email__c = 'emailuser@example.com',
            Reminder_Enabled__c = true
        );
        insert user;

        Test.startTest();
        DailyProblemRotationScheduler scheduler = new DailyProblemRotationScheduler();
        scheduler.execute(null);
        Test.stopTest();

        user = [
            SELECT Last_Daily_Email_Sent__c
            FROM Coding_User__c
            WHERE Id = :user.Id
        ];
        System.assertNotEquals(null, user.Last_Daily_Email_Sent__c);
    }
}
