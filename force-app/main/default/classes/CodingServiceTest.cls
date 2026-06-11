@isTest
public class CodingServiceTest {

    @isTest static void testCreateAndDeleteUser() {
        Test.startTest();

        Time reminder = Time.newInstance(20,0,0,0);
        Time morning = Time.newInstance(8,0,0,0);

        Id userId = CodingService.createUser('Test User','test@example.com','leetUser','codeChef', reminder, morning, true);
        System.assertNotEquals(null, userId);

        Coding_User__c u = [SELECT Id, Email__c FROM Coding_User__c WHERE Id = :userId LIMIT 1];
        System.assertEquals('test@example.com', u.Email__c);

        CodingService.deleteUser(userId);

        Integer count = [SELECT count() FROM Coding_User__c WHERE Id = :userId];
        System.assertEquals(0, count);

        Test.stopTest();
    }

    @isTest static void testMarkProblemSolved() {
        // create test problem (Name may be auto-numbered in some orgs)
        Daily_Problem__c p = new Daily_Problem__c(Problem_Date__c = Date.today());
        insert p;

        Id userId = CodingService.createUser('Solver','solver@example.com','solverLC','solverCC', Time.newInstance(20,0,0,0), Time.newInstance(8,0,0,0), true);

        Test.startTest();
        CodingService.markProblemSolved(p.Id, userId);
        Test.stopTest();

        Daily_Problem__c p2 = [SELECT Completed_Count__c FROM Daily_Problem__c WHERE Id = :p.Id LIMIT 1];
        System.assertEquals(1, Integer.valueOf(p2.Completed_Count__c));

        Coding_User__c u2 = [SELECT Current_Streak__c, Last_Solved_Date__c FROM Coding_User__c WHERE Id = :userId LIMIT 1];
        System.assertEquals(1, Integer.valueOf(u2.Current_Streak__c));
        System.assertEquals(Date.today(), u2.Last_Solved_Date__c);
    }
}
