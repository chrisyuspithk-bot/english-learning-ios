package com.example.englishlearning.data.remote

/**
 * In-memory bearer-token holder. The iOS POC keeps the token on `APIClient.shared`
 * for the lifetime of the process; this mirrors that behaviour. A production app
 * should persist it (e.g. EncryptedSharedPreferences / DataStore).
 */
class TokenStore {
    @Volatile
    var token: String? = null
}
