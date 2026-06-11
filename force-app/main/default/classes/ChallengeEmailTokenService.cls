public with sharing class ChallengeEmailTokenService {

    private static final String TOKEN_SECRET = 'CodePulseAI-Email-Token-v1';

    public static String buildToken(Id userId, Id problemId) {
        String payload = String.valueOf(userId) + '|' + String.valueOf(problemId) + '|' + String.valueOf(Date.today());
        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(payload), Blob.valueOf(TOKEN_SECRET));
        return EncodingUtil.convertToHex(mac).substring(0, 32);
    }

    public static Boolean isValidToken(Id userId, Id problemId, String token) {
        if (userId == null || problemId == null || String.isBlank(token)) {
            return false;
        }
        return buildToken(userId, problemId) == token;
    }

    public static String getEmailBaseUrl() {
        String labelUrl = System.Label.CodePulse_Email_Base_URL;
        if (String.isNotBlank(labelUrl) && !labelUrl.contains('your-domain')) {
            return labelUrl.removeEnd('/');
        }
        return Url.getOrgDomainUrl().toExternalForm();
    }

    public static String buildActionUrl(Id userId, Id problemId, String action) {
        String token = buildToken(userId, problemId);
        return getEmailBaseUrl() +
            '/apex/ChallengeResponse' +
            '?uid=' + EncodingUtil.urlEncode(String.valueOf(userId), 'UTF-8') +
            '&pid=' + EncodingUtil.urlEncode(String.valueOf(problemId), 'UTF-8') +
            '&action=' + EncodingUtil.urlEncode(action, 'UTF-8') +
            '&token=' + EncodingUtil.urlEncode(token, 'UTF-8');
    }
}
