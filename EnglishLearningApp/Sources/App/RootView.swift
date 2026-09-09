import SwiftUI

/// Top-level view: shows the login screen until authenticated, then the main app.
struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        Group {
            if store.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
