package com.example.englishlearning.speech

/**
 * Mirrors the iOS `PronunciationScorer`: a normalised Levenshtein distance
 * between the recognised speech and the target word, producing a 0..1 score.
 */
object PronunciationScorer {

    fun score(recognized: String, target: String): Double {
        val a = normalize(recognized)
        val b = normalize(target)
        if (a.isEmpty() || b.isEmpty()) return 0.0
        val distance = levenshtein(a, b)
        val maxLength = maxOf(a.length, b.length)
        return 1.0 - distance.toDouble() / maxLength
    }

    private fun normalize(string: String): String {
        val filtered = string.lowercase().filter { it.isLetter() || it == ' ' }
        return filtered.split(' ').filter { it.isNotEmpty() }.joinToString(" ")
    }

    private fun levenshtein(lhs: String, rhs: String): Int {
        val dp = Array(lhs.length + 1) { IntArray(rhs.length + 1) }
        for (i in 0..lhs.length) dp[i][0] = i
        for (j in 0..rhs.length) dp[0][j] = j

        for (i in 1..lhs.length) {
            for (j in 1..rhs.length) {
                val cost = if (lhs[i - 1] == rhs[j - 1]) 0 else 1
                dp[i][j] = minOf(
                    dp[i - 1][j] + 1,
                    minOf(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
                )
            }
        }
        return dp[lhs.length][rhs.length]
    }
}
