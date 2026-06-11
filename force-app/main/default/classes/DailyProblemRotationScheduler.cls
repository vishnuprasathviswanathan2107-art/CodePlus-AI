global class DailyProblemRotationScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        try {
            DailyProblemService.rotateDailyProblems();
            CodingEmailService.sendPostRotationEmails();
            scheduleTwoHourNudge();
        } catch (Exception e) {
            System.debug('DailyProblemRotationScheduler error: ' + e.getMessage());
        }
    }

  public static void scheduleTwoHourNudge() {
        Datetime runAt = Datetime.now().addHours(2);
        String jobName = 'CodePulse_2h_Nudge_' + String.valueOf(runAt.getTime());
        String cron = buildCron(runAt);
        System.schedule(jobName, cron, new TwoHourReminderScheduler());
    }

    private static String buildCron(Datetime dt) {
        return String.format(
            '0 {0} {1} {2} {3} ? {4}',
            new List<String>{
                String.valueOf(dt.minute()),
                String.valueOf(dt.hour()),
                String.valueOf(dt.day()),
                String.valueOf(dt.month()),
                String.valueOf(dt.year())
            }
        );
    }

    public static String getRotationCron() {
        return '0 0 23 * * ?';
    }
}
