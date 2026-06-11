public with sharing class UserProfileController {

    @AuraEnabled
    public static void deleteUser(Id userId) {
        if (userId == null) {
            throw new AuraHandledException('User id is required');
        }

        if (!Schema.sObjectType.Coding_User__c.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to delete users');
        }

        Coding_User__c user = [
            SELECT Id
            FROM Coding_User__c
            WHERE Id = :userId
            LIMIT 1
        ];

        try {
            List<User_Problem_Completion__c> completions = [
                SELECT Id 
                FROM User_Problem_Completion__c 
                WHERE Coding_User__c = :userId
            ];
            if (!completions.isEmpty()) {
                delete completions;
            }
            delete user;
        } catch (DmlException e) {
            throw new AuraHandledException('Unable to delete user: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createUser(
        String fullName,
        String email,
        String leetCodeUsername,
        String codeChefUsername,
        String avatarUrl,
        String reminderTime,
        String morningSummaryTime,
        Boolean reminderEnabled,
        Boolean motivationEmails
    ) {
        return saveUser(null, fullName, email, leetCodeUsername, codeChefUsername, avatarUrl,
            reminderTime, morningSummaryTime, reminderEnabled, motivationEmails, true);
    }

    @AuraEnabled
    public static void updateUser(
        Id userId,
        String fullName,
        String email,
        String leetCodeUsername,
        String codeChefUsername,
        String avatarUrl,
        String reminderTime,
        String morningSummaryTime,
        Boolean reminderEnabled,
        Boolean motivationEmails
    ) {
        saveUser(userId, fullName, email, leetCodeUsername, codeChefUsername, avatarUrl,
            reminderTime, morningSummaryTime, reminderEnabled, motivationEmails, false);
    }

    private static Id saveUser(
        Id userId,
        String fullName,
        String email,
        String leetCodeUsername,
        String codeChefUsername,
        String avatarUrl,
        String reminderTime,
        String morningSummaryTime,
        Boolean reminderEnabled,
        Boolean motivationEmails,
        Boolean isCreate
    ) {
        if (String.isBlank(fullName) || String.isBlank(email)) {
            throw new AuraHandledException('Name and email are required');
        }

        Boolean creating = isCreate == true;
        if (creating && !Schema.sObjectType.Coding_User__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create users');
        }
        if (!creating && !Schema.sObjectType.Coding_User__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update users');
        }

        if (creating) {
            List<Coding_User__c> dup = [
                SELECT Id
                FROM Coding_User__c
                WHERE Email__c = :email
                LIMIT 1
            ];
            if (!dup.isEmpty()) {
                throw new AuraHandledException('A user with that email already exists');
            }
        }

        Time eveningTime = CodingUserService.parseTimeString(
            reminderTime,
            Time.newInstance(20, 0, 0, 0)
        );
        Time morningTime = CodingUserService.parseTimeString(
            morningSummaryTime,
            Time.newInstance(8, 0, 0, 0)
        );

        Coding_User__c record;
        if (creating) {
            record = new Coding_User__c(
                Full_Name__c = fullName,
                Email__c = email,
                LeetCode_Username__c = leetCodeUsername,
                CodeChef_Username__c = codeChefUsername,
                Avatar_URL__c = avatarUrl,
                Current_Streak__c = 0,
                Total_Solved__c = 0,
                Longest_Streak__c = 0,
                Reminder_Enabled__c = reminderEnabled == null ? true : reminderEnabled,
                Motivation_Emails__c = motivationEmails == null ? true : motivationEmails,
                Reminder_Time__c = eveningTime,
                Morning_Summary_Time__c = morningTime
            );
            insert record;
            try {
                System.enqueueJob(new EmailQueueable(record.Id, 'welcome'));
            } catch (Exception e) {
                System.debug('Failed to enqueue welcome email: ' + e.getMessage());
            }
            return record.Id;
        }

        if (userId == null) {
            throw new AuraHandledException('User id is required for update');
        }

        record = [
            SELECT Id, Email__c
            FROM Coding_User__c
            WHERE Id = :userId
            LIMIT 1
        ];

        if (!record.Email__c.equalsIgnoreCase(email)) {
            List<Coding_User__c> dup = [
                SELECT Id
                FROM Coding_User__c
                WHERE Email__c = :email AND Id != :userId
                LIMIT 1
            ];
            if (!dup.isEmpty()) {
                throw new AuraHandledException('A user with that email already exists');
            }
        }

        record.Full_Name__c = fullName;
        record.Email__c = email;
        record.LeetCode_Username__c = leetCodeUsername;
        record.CodeChef_Username__c = codeChefUsername;
        record.Avatar_URL__c = avatarUrl;
        record.Reminder_Enabled__c = reminderEnabled == null ? true : reminderEnabled;
        record.Motivation_Emails__c = motivationEmails == null ? true : motivationEmails;
        record.Reminder_Time__c = eveningTime;
        record.Morning_Summary_Time__c = morningTime;

        update record;
        return record.Id;
    }
}
