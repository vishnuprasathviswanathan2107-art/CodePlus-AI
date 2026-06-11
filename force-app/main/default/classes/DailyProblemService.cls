public with sharing class DailyProblemService {

    public static final String PLATFORM_LEETCODE = 'LeetCode';
    public static final String PLATFORM_CODECHEF = 'CodeChef';

    private class ProblemSeed {
        String topic;
        String difficulty;
        String link;
        String summary;

        ProblemSeed(String topic, String difficulty, String link, String summary) {
            this.topic = topic;
            this.difficulty = difficulty;
            this.link = link;
            this.summary = summary;
        }
    }

    private static final List<ProblemSeed> LEETCODE_BANK = new List<ProblemSeed>{
        new ProblemSeed(
            'Two Sum',
            'Easy',
            'https://leetcode.com/problems/two-sum/',
            'Find two indices whose values add up to the target. Use a hash map for O(n) time.'
        ),
        new ProblemSeed(
            'Valid Parentheses',
            'Easy',
            'https://leetcode.com/problems/valid-parentheses/',
            'Use a stack to match opening and closing brackets in linear time.'
        ),
        new ProblemSeed(
            'Merge Intervals',
            'Medium',
            'https://leetcode.com/problems/merge-intervals/',
            'Sort intervals by start, then merge overlapping ranges greedily.'
        ),
        new ProblemSeed(
            'Longest Substring Without Repeating Characters',
            'Medium',
            'https://leetcode.com/problems/longest-substring-without-repeating-characters/',
            'Sliding window with a map of last seen indices maximizes window length.'
        ),
        new ProblemSeed(
            'Binary Tree Level Order Traversal',
            'Medium',
            'https://leetcode.com/problems/binary-tree-level-order-traversal/',
            'BFS with a queue collects nodes level by level.'
        ),
        new ProblemSeed(
            'Course Schedule',
            'Medium',
            'https://leetcode.com/problems/course-schedule/',
            'Topological sort detects cycles in prerequisite graphs.'
        ),
        new ProblemSeed(
            'Coin Change',
            'Medium',
            'https://leetcode.com/problems/coin-change/',
            'Bottom-up DP finds minimum coins to reach each amount.'
        ),
        new ProblemSeed(
            'Trapping Rain Water',
            'Hard',
            'https://leetcode.com/problems/trapping-rain-water/',
            'Two-pointer or prefix max arrays compute trapped volume.'
        )
    };

    private static final List<ProblemSeed> CODECHEF_BANK = new List<ProblemSeed>{
        new ProblemSeed(
            'START01',
            'Easy',
            'https://www.codechef.com/problems/START01',
            'Read two numbers and print their sum — a warm-up for CodeChef I/O format.'
        ),
        new ProblemSeed(
            'Factorial',
            'Easy',
            'https://www.codechef.com/problems/FCTRL',
            'Count trailing zeros in n! using prime factorization of 5s.'
        ),
        new ProblemSeed(
            'Reverse The Array',
            'Easy',
            'https://www.codechef.com/problems/REVARRAY',
            'Reverse an array in-place with two pointers.'
        ),
        new ProblemSeed(
            'Chef and Subarrays',
            'Medium',
            'https://www.codechef.com/problems/CHSUBARR',
            'Count subarrays with sum divisible by k using prefix sums.'
        ),
        new ProblemSeed(
            'Chef and Digits',
            'Medium',
            'https://www.codechef.com/problems/LGFRQ',
            'Frequency counting on digit arrays.'
        ),
        new ProblemSeed(
            'Maximum Subarray Sum',
            'Medium',
            'https://www.codechef.com/problems/MAXSUBARR',
            'Kadane\'s algorithm finds the maximum contiguous subarray sum.'
        ),
        new ProblemSeed(
            'Longest Common Subsequence',
            'Hard',
            'https://www.codechef.com/problems/CHOCOLA',
            '2D DP for classic LCS on strings.'
        ),
        new ProblemSeed(
            'Graph Paths',
            'Hard',
            'https://www.codechef.com/problems/GRAPHPATH',
            'BFS/DFS on adjacency lists for reachability.'
        )
    };

    public static void rotateDailyProblems() {
        ensureProblemsForDate(Date.today());
        ensureProblemsForDate(Date.today().addDays(1));
    }

    public static void ensureProblemsForDate(Date problemDate) {
        ensureProblemForDateAndPlatform(problemDate, PLATFORM_LEETCODE);
        ensureProblemForDateAndPlatform(problemDate, PLATFORM_CODECHEF);
    }

    public static Daily_Problem__c ensureProblemForDate(Date problemDate) {
        return ensureProblemForDateAndPlatform(problemDate, PLATFORM_LEETCODE);
    }

    public static Daily_Problem__c ensureProblemForDateAndPlatform(Date problemDate, String platform) {
        if (problemDate == null || String.isBlank(platform)) {
            return null;
        }

        Daily_Problem__c existing = queryProblemForDateAndPlatform(problemDate, platform);
        if (existing != null) {
            return existing;
        }

        if (!Schema.sObjectType.Daily_Problem__c.isCreateable()) {
            return null;
        }

        Integer dayOffset = Math.abs(Date.newInstance(2024, 1, 1).daysBetween(problemDate));
        Integer platformOffset = platform == PLATFORM_CODECHEF ? 3 : 0;
        List<ProblemSeed> bank = platform == PLATFORM_CODECHEF ? CODECHEF_BANK : LEETCODE_BANK;
        Integer bankIndex = Math.mod(dayOffset + platformOffset, bank.size());
        ProblemSeed seed = bank[bankIndex];

        Daily_Problem__c problem = new Daily_Problem__c(
            Problem_Date__c = problemDate,
            Platform__c = platform,
            Topic__c = seed.topic,
            Difficulty__c = seed.difficulty,
            Problem_Link__c = seed.link,
            AI_Summary__c = seed.summary,
            Completed_Count__c = 0
        );

        insert problem;
        return problem;
    }

    public static Daily_Problem__c queryProblemForDate(Date problemDate) {
        return queryProblemForDateAndPlatform(problemDate, PLATFORM_LEETCODE);
    }

    public static Daily_Problem__c queryProblemForDateAndPlatform(Date problemDate, String platform) {
        if (problemDate == null || String.isBlank(platform)) {
            return null;
        }

        List<Daily_Problem__c> problems = [
            SELECT Id, Name, Topic__c, Difficulty__c, Problem_Link__c,
                   AI_Summary__c, Problem_Date__c, Completed_Count__c, Platform__c
            FROM Daily_Problem__c
            WHERE Problem_Date__c = :problemDate
              AND Platform__c = :platform
            LIMIT 1
        ];

        if (!problems.isEmpty()) {
            return problems[0];
        }

        if (platform == PLATFORM_LEETCODE) {
            List<Daily_Problem__c> legacy = [
                SELECT Id, Name, Topic__c, Difficulty__c, Problem_Link__c,
                       AI_Summary__c, Problem_Date__c, Completed_Count__c, Platform__c
                FROM Daily_Problem__c
                WHERE Problem_Date__c = :problemDate
                  AND Platform__c = null
                LIMIT 1
            ];
            return legacy.isEmpty() ? null : legacy[0];
        }

        return null;
    }

    public static Daily_Problem__c getProblemForDate(Date problemDate) {
        return queryProblemForDate(problemDate);
    }

    public static List<Daily_Problem__c> getProblemsForDate(Date problemDate) {
        List<Daily_Problem__c> results = new List<Daily_Problem__c>();
        Daily_Problem__c leetcode = queryProblemForDateAndPlatform(problemDate, PLATFORM_LEETCODE);
        Daily_Problem__c codechef = queryProblemForDateAndPlatform(problemDate, PLATFORM_CODECHEF);
        if (leetcode != null) {
            results.add(leetcode);
        }
        if (codechef != null) {
            results.add(codechef);
        }
        return results;
    }
}
