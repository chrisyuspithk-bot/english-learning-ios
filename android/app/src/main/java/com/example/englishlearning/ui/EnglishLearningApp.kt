package com.example.englishlearning.ui

import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.englishlearning.AppContainer
import com.example.englishlearning.ui.auth.AuthViewModel
import com.example.englishlearning.ui.screens.ChapterDetailScreen
import com.example.englishlearning.ui.screens.HomeScreen
import com.example.englishlearning.ui.screens.LoginScreen

object Routes {
    const val LOGIN = "login"
    const val HOME = "home"
    const val CHAPTER = "chapter/{chapterId}/{title}"

    fun chapter(chapterId: String, title: String): String =
        "chapter/$chapterId/${Uri.encode(title)}"
}

@Composable
fun EnglishLearningApp(container: AppContainer) {
    val navController = rememberNavController()

    val authViewModel: AuthViewModel = viewModel {
        AuthViewModel(container.authRepository)
    }

    NavHost(navController = navController, startDestination = Routes.LOGIN) {
        composable(Routes.LOGIN) {
            LoginScreen(
                viewModel = authViewModel,
                onLoggedIn = {
                    navController.navigate(Routes.HOME) {
                        popUpTo(Routes.LOGIN) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.HOME) {
            HomeScreen(
                container = container,
                authViewModel = authViewModel,
                onOpenChapter = { id, title ->
                    navController.navigate(Routes.chapter(id, title))
                },
                onLogout = {
                    navController.navigate(Routes.LOGIN) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Routes.CHAPTER,
            arguments = listOf(
                navArgument("chapterId") { type = NavType.StringType },
                navArgument("title") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val chapterId = backStackEntry.arguments?.getString("chapterId").orEmpty()
            val title = backStackEntry.arguments?.getString("title").orEmpty()
            ChapterDetailScreen(
                container = container,
                chapterId = chapterId,
                title = title,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
