public with sharing class CodingUserService {

    public static void applySolve(Coding_User__c user, Daily_Problem__c problem) {
        if (user == null || problem == null) {
            return;
        }

        Date today = Date.today();
        Boolean alreadySolvedToday = user.Last_Solved_Date__c == today;

        if (!alreadySolvedToday) {
            if (user.Total_Solved__c == null) {
                user.Total_Solved__c = 0;
            }
            user.Total_Solved__c += 1;

            if (user.Current_Streak__c == null) {
                user.Current_Streak__c = 0;
            }

            if (user.Last_Solved_Date__c == today.addDays(-1)) {
                user.Current_Streak__c += 1;
            } else {
                user.Current_Streak__c = 1;
            }

            user.Last_Solved_Date__c = today;

            if (user.Longest_Streak__c == null) {
                user.Longest_Streak__c = 0;
            }
            if (user.Current_Streak__c > user.Longest_Streak__c) {
                user.Longest_Streak__c = user.Current_Streak__c;
            }
        }
    }

    public static Time parseTimeString(String timeValue, Time defaultTime) {
        if (String.isBlank(timeValue)) {
            return defaultTime;
        }

        List<String> parts = timeValue.split(':');
        if (parts.size() < 2) {
            return defaultTime;
        }

        try {
            Integer hour = Integer.valueOf(parts[0]);
            Integer minute = Integer.valueOf(parts[1]);
            return Time.newInstance(hour, minute, 0, 0);
        } catch (Exception e) {
            return defaultTime;
        }
    }
}
