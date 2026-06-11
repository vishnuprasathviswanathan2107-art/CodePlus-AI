public without sharing class ChallengeResponseController {

    public String pageTitle { get; private set; }
    public String message { get; private set; }
    public Boolean isSuccess { get; private set; }

    public ChallengeResponseController() {
        pageTitle = 'CodePulse AI';
        message = 'Invalid request.';
        isSuccess = false;

        try {
            String uid = ApexPages.currentPage().getParameters().get('uid');
            String pid = ApexPages.currentPage().getParameters().get('pid');
            String action = ApexPages.currentPage().getParameters().get('action');
            String token = ApexPages.currentPage().getParameters().get('token');

            if (String.isBlank(uid) || String.isBlank(pid) || String.isBlank(action) || String.isBlank(token)) {
                return;
            }

            Id userId = Id.valueOf(uid);
            Id problemId = Id.valueOf(pid);

            if (!ChallengeEmailTokenService.isValidToken(userId, problemId, token)) {
                message = 'This link has expired or is invalid. Please use today\'s email or the dashboard.';
                return;
            }

            if (action == 'complete') {
                ProblemCompletionService.CompletionResult result =
                    ProblemCompletionService.markProblemComplete(problemId, userId);
                isSuccess = true;
                pageTitle = 'Marked complete';
                if (result.alreadyCompleted) {
                    message = 'You already marked this problem complete. Great consistency!';
                } else {
                    message = 'Challenge marked complete. Streak: ' + result.streak + ' day(s).';
                }
            } else if (action == 'skip') {
                isSuccess = true;
                pageTitle = 'Saved for later';
                message = 'No problem — we will send a reminder if you have not completed today\'s challenges.';
            } else {
                message = 'Unknown action.';
            }
        } catch (Exception e) {
            message = 'Something went wrong: ' + e.getMessage();
        }
    }
}
