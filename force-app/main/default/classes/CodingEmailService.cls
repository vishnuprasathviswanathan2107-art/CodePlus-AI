public with sharing class CodingEmailService {

    private static final String BRAND_COLOR = '#7c3aed';
    private static final String DARK_BG = '#0f172a';

    public static void sendWelcome(Coding_User__c user) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String body = buildEmailHtml(
            'Welcome to CodePulse AI',
            'Hey ' + escapeHtml(user.Full_Name__c) + ' 👋',
            '<p>We are excited to start your coding journey with you.</p>' +
            '<p><strong>Consistency beats talent when talent does not work hard.</strong></p>' +
            '<p>Solve daily. Build streaks. Become unstoppable.</p>',
            'Open Dashboard',
            null
        );

        sendHtmlEmail(user.Email__c, '🚀 Welcome to CodePulse AI', body);
    }

    public static void sendMorningMotivation(Coding_User__c user) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String quote = pickMotivationQuote(user.Id);
        String body = buildEmailHtml(
            'Morning Motivation',
            'Good morning, ' + escapeHtml(user.Full_Name__c) + ' ☀️',
            '<p>' + escapeHtml(quote) + '</p>' +
            '<p>Your daily challenge is waiting. Start strong today.</p>',
            null,
            null
        );

        sendHtmlEmail(user.Email__c, '☀️ Morning Motivation — CodePulse AI', body);
    }

    public static void sendDailyReminder(Coding_User__c user, Daily_Problem__c problem) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String problemBlock = '';
        if (problem != null) {
            problemBlock =
                '<p><strong>Today\'s challenge:</strong> ' +
                escapeHtml(problem.Topic__c) + ' (' +
                escapeHtml(problem.Difficulty__c) + ')</p>';
            if (String.isNotBlank(problem.Problem_Link__c)) {
                problemBlock +=
                    '<p><a href="' + escapeHtml(problem.Problem_Link__c) +
                    '" style="color:#a78bfa;">Solve now →</a></p>';
            }
        }

        String body = buildEmailHtml(
            'Daily Coding Reminder',
            'Hey ' + escapeHtml(user.Full_Name__c) + ' 👋',
            problemBlock +
            '<p>Your coding challenge is waiting today 🔥</p>' +
            '<p>Stay consistent. Solve daily. Become unstoppable.</p>',
            null,
            null
        );

        sendHtmlEmail(user.Email__c, '🚀 Your Daily Coding Reminder', body);
    }

    public static void sendTwoHourNudge(Coding_User__c user) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String body = buildEmailHtml(
            'Friendly Nudge',
            'Still time to code today, ' + escapeHtml(user.Full_Name__c),
            '<p>You have not marked today\'s problem solved yet.</p>' +
            '<p>A quick solve keeps your streak alive 🔥</p>',
            null,
            null
        );

        sendHtmlEmail(user.Email__c, '⏰ CodePulse — Today\'s problem is waiting', body);
    }

    public static void sendCongratulations(Coding_User__c user, Integer streak) {
        sendCongratulations(user, streak, null);
    }

    public static void sendCongratulations(
        Coding_User__c user,
        Integer streak,
        Daily_Problem__c problem
    ) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String platformLine = '';
        if (problem != null && String.isNotBlank(problem.Topic__c)) {
            String platform = String.isNotBlank(problem.Platform__c) ? problem.Platform__c : 'LeetCode';
            platformLine =
                '<p>You completed <strong>' + escapeHtml(problem.Topic__c) +
                '</strong> on ' + escapeHtml(platform) + '.</p>';
        }

        String body = buildEmailHtml(
            'Problem Solved!',
            'Great work, ' + escapeHtml(user.Full_Name__c) + ' 🎉',
            platformLine +
            '<p>Current streak: <strong>' + streak + ' day(s)</strong></p>' +
            '<p>Keep the momentum going tomorrow.</p>',
            null,
            null
        );

        sendHtmlEmail(user.Email__c, '🏆 Nice solve! Streak updated', body);
    }

    public static void sendDailyChallengeEmail(
        Coding_User__c user,
        Daily_Problem__c leetcodeProblem,
        Daily_Problem__c codechefProblem
    ) {
        if (user == null || String.isBlank(user.Email__c)) {
            return;
        }

        String content =
            '<p>Your new daily challenges are ready (rotated at 11:00 PM).</p>' +
            buildProblemEmailBlock(user.Id, 'LeetCode', leetcodeProblem) +
            buildProblemEmailBlock(user.Id, 'CodeChef', codechefProblem) +
            '<p style="margin-top:20px;font-size:14px;color:#64748b;">Use the buttons on each challenge when you are done.</p>';

        String body = buildEmailHtml(
            'Today\'s Challenges',
            'Hey ' + escapeHtml(user.Full_Name__c) + ' 👋',
            content,
            null,
            null
        );

        sendHtmlEmail(user.Email__c, '🚀 CodePulse — Today\'s LeetCode & CodeChef challenges', body);
    }

    public static void sendPostRotationEmails() {
        Daily_Problem__c leetcode = DailyProblemService.queryProblemForDateAndPlatform(
            Date.today(),
            DailyProblemService.PLATFORM_LEETCODE
        );
        Daily_Problem__c codechef = DailyProblemService.queryProblemForDateAndPlatform(
            Date.today(),
            DailyProblemService.PLATFORM_CODECHEF
        );

        List<Coding_User__c> users = [
            SELECT Id, Full_Name__c, Email__c, Reminder_Enabled__c
            FROM Coding_User__c
            WHERE Email__c != null
        ];

        if (users.isEmpty()) {
            return;
        }

        Datetime sentAt = Datetime.now();
        List<Coding_User__c> toUpdate = new List<Coding_User__c>();

        for (Coding_User__c user : users) {
            if (user.Reminder_Enabled__c == false) {
                continue;
            }
            sendDailyChallengeEmail(user, leetcode, codechef);
            toUpdate.add(new Coding_User__c(
                Id = user.Id,
                Last_Daily_Email_Sent__c = sentAt,
                Last_Nudge_Sent_Date__c = null
            ));
        }

        if (!toUpdate.isEmpty() && Schema.sObjectType.Coding_User__c.isUpdateable()) {
            update toUpdate;
        }
    }

    private static String buildProblemEmailBlock(
        Id userId,
        String platformLabel,
        Daily_Problem__c problem
    ) {
        if (problem == null) {
            return '<p><strong>' + escapeHtml(platformLabel) + ':</strong> No problem assigned.</p>';
        }

        String completeUrl = ChallengeEmailTokenService.buildActionUrl(userId, problem.Id, 'complete');
        String skipUrl = ChallengeEmailTokenService.buildActionUrl(userId, problem.Id, 'skip');

        return '<div style="margin:16px 0;padding:16px;background:#f8fafc;border-radius:12px;border:1px solid #e2e8f0;">' +
            '<p style="margin:0 0 8px;"><strong>' + escapeHtml(platformLabel) + '</strong> · ' +
            escapeHtml(problem.Topic__c) + ' (' + escapeHtml(problem.Difficulty__c) + ')</p>' +
            '<p style="margin:0 0 12px;font-size:14px;color:#475569;">' + escapeHtml(problem.AI_Summary__c) + '</p>' +
            (String.isNotBlank(problem.Problem_Link__c)
                ? '<p style="margin:0 0 12px;"><a href="' + escapeHtml(problem.Problem_Link__c) +
                  '" style="color:#7c3aed;">Open on ' + escapeHtml(platformLabel) + ' →</a></p>'
                : '') +
            '<p style="margin:0;">' +
            '<a href="' + escapeHtml(completeUrl) +
            '" style="display:inline-block;background:#202a36;color:#fff;padding:10px 16px;border-radius:999px;text-decoration:none;font-weight:600;margin-right:8px;">Complete</a>' +
            '<a href="' + escapeHtml(skipUrl) +
            '" style="display:inline-block;background:#e2e8f0;color:#334155;padding:10px 16px;border-radius:999px;text-decoration:none;font-weight:600;">Not yet</a>' +
            '</p></div>';
    }

    public static void sendBulkReminders(List<Coding_User__c> users, String emailType) {
        if (users == null || users.isEmpty()) {
            return;
        }

        Daily_Problem__c leetcodeProblem = DailyProblemService.queryProblemForDateAndPlatform(
            Date.today(),
            DailyProblemService.PLATFORM_LEETCODE
        );
        Daily_Problem__c codechefProblem = DailyProblemService.queryProblemForDateAndPlatform(
            Date.today(),
            DailyProblemService.PLATFORM_CODECHEF
        );
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Id oweaId = getOrgWideEmailId();

        for (Coding_User__c user : users) {
            if (String.isBlank(user.Email__c)) {
                continue;
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { user.Email__c });
            mail.setUseSignature(false);

            if (emailType == 'morning') {
                mail.setSubject('☀️ Morning Motivation — CodePulse AI');
                mail.setHtmlBody(buildMorningBody(user));
            } else if (emailType == 'final') {
                mail.setSubject('🌙 Final Reminder (10:00 PM) — Complete today\'s challenges');
                mail.setHtmlBody(buildFinalReminderBody(user, leetcodeProblem, codechefProblem));
            } else if (emailType == 'nudge') {
                mail.setSubject('⏰ CodePulse — 5-hour reminder');
                mail.setHtmlBody(buildNudgeBody(user, leetcodeProblem, codechefProblem));
            } else {
                mail.setSubject('🚀 Your Daily Coding Reminder');
                mail.setHtmlBody(buildReminderBody(user, leetcodeProblem, codechefProblem));
            }

            if (oweaId != null) {
                mail.setOrgWideEmailAddressId(oweaId);
            }

            messages.add(mail);
        }

        if (!messages.isEmpty()) {
            Messaging.sendEmail(messages);
        }
    }

    private static String buildMorningBody(Coding_User__c user) {
        return buildEmailHtml(
            'Morning Motivation',
            'Good morning, ' + escapeHtml(user.Full_Name__c) + ' ☀️',
            '<p>' + escapeHtml(pickMotivationQuote(user.Id)) + '</p>',
            null,
            null
        );
    }

    private static String buildNudgeBody(
        Coding_User__c user,
        Daily_Problem__c leetcodeProblem,
        Daily_Problem__c codechefProblem
    ) {
        return buildEmailHtml(
            'Mandatory 5-Hour Reminder',
            'Still time to code today, ' + escapeHtml(user.Full_Name__c),
            '<p>You have not completed all today\'s challenges yet.</p>' +
            '<p>Please complete and mark status from this email:</p>' +
            buildProblemEmailBlock(user.Id, 'LeetCode', leetcodeProblem) +
            buildProblemEmailBlock(user.Id, 'CodeChef', codechefProblem),
            null,
            null
        );
    }

    private static String buildReminderBody(
        Coding_User__c user,
        Daily_Problem__c leetcodeProblem,
        Daily_Problem__c codechefProblem
    ) {
        return buildEmailHtml(
            'Daily Coding Reminder',
            'Hey ' + escapeHtml(user.Full_Name__c) + ' 👋',
            '<p>Hello ' + escapeHtml(user.Full_Name__c) + ', your today problems are ready:</p>' +
            buildProblemEmailBlock(user.Id, 'LeetCode', leetcodeProblem) +
            buildProblemEmailBlock(user.Id, 'CodeChef', codechefProblem) +
            '<p>Choose <strong>Complete</strong> or <strong>Not yet</strong> from the email itself.</p>',
            null,
            null
        );
    }

    private static String buildFinalReminderBody(
        Coding_User__c user,
        Daily_Problem__c leetcodeProblem,
        Daily_Problem__c codechefProblem
    ) {
        return buildEmailHtml(
            'Final Reminder - 10:00 PM',
            'Final reminder for today, ' + escapeHtml(user.Full_Name__c),
            '<p>This is your final reminder for today.</p>' +
            '<p>Please check your pending challenges and mark your status now:</p>' +
            buildProblemEmailBlock(user.Id, 'LeetCode', leetcodeProblem) +
            buildProblemEmailBlock(user.Id, 'CodeChef', codechefProblem) +
            '<p>Keep your streak alive before the day ends.</p>',
            null,
            null
        );
    }

    private static void sendHtmlEmail(String toAddress, String subject, String htmlBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { toAddress });
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setUseSignature(false);

        Id oweaId = getOrgWideEmailId();
        if (oweaId != null) {
            mail.setOrgWideEmailAddressId(oweaId);
        }

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug('CodingEmailService send failed: ' + e.getMessage());
        }
    }

    private static Id getOrgWideEmailId() {
        List<OrgWideEmailAddress> owes = [
            SELECT Id FROM OrgWideEmailAddress LIMIT 1
        ];
        return owes.isEmpty() ? null : owes[0].Id;
    }

    private static String buildEmailHtml(
        String eyebrow,
        String headline,
        String contentHtml,
        String ctaLabel,
        String ctaUrl
    ) {
        String ctaBlock = '';
        if (String.isNotBlank(ctaLabel) && String.isNotBlank(ctaUrl)) {
            ctaBlock =
                '<p style="margin-top:24px;">' +
                '<a href="' + escapeHtml(ctaUrl) + '" style="background:' + BRAND_COLOR +
                ';color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:600;">' +
                escapeHtml(ctaLabel) + '</a></p>';
        }

        return '<!DOCTYPE html><html><body style="margin:0;padding:0;background:#f1f5f9;">' +
            '<table width="100%" cellpadding="0" cellspacing="0" style="padding:24px 0;">' +
            '<tr><td align="center">' +
            '<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(15,23,42,.12);">' +
            '<tr><td style="background:' + DARK_BG + ';padding:28px 32px;color:#fff;">' +
            '<div style="font-size:12px;letter-spacing:.08em;text-transform:uppercase;opacity:.8;">CodePulse AI</div>' +
            '<div style="font-size:12px;margin-top:8px;opacity:.7;">' + escapeHtml(eyebrow) + '</div>' +
            '<h1 style="margin:12px 0 0;font-size:24px;line-height:1.3;">' + headline + '</h1>' +
            '</td></tr>' +
            '<tr><td style="padding:28px 32px;color:#334155;font-size:16px;line-height:1.6;">' +
            contentHtml + ctaBlock +
            '<p style="margin-top:28px;font-size:13px;color:#94a3b8;">— Team CodePulse AI</p>' +
            '</td></tr></table></td></tr></table></body></html>';
    }

    private static String pickMotivationQuote(Id userId) {
        List<String> quotes = new List<String>{
            'Consistency beats talent when talent does not work hard.',
            'Small daily improvements lead to stunning long-term results.',
            'Discipline is choosing between what you want now and what you want most.',
            'Every expert was once a beginner who refused to quit.',
            'Code a little every day — compound growth is real.'
        };
        Integer index = userId == null
            ? 0
            : Math.mod(Math.abs(Crypto.getRandomInteger()), quotes.size());
        return quotes[index];
    }

    private static String escapeHtml(String value) {
        if (value == null) {
            return '';
        }
        return value.escapeHtml4();
    }
}
