package com.example.englishlearning

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.englishlearning.ui.EnglishLearningApp
import com.example.englishlearning.ui.theme.EnglishLearningTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            EnglishLearningTheme {
                val container = (application as EnglishLearningApp).container
                EnglishLearningApp(container)
            }
        }
    }
}
