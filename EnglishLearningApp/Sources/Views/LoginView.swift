import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Theme.primary, Color(hex: "7AA6FF")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                    Text("English Explorers")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Primary 5 · Hong Kong")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                VStack(spacing: 14) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                    if let error = store.loginError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.yellow)
                    }

                    Button(action: login) {
                        HStack {
                            if store.isLoggingIn {
                                ActivityIndicator(style: .medium)
                            }
                            Text(store.isLoggingIn ? "Logging in…" : "Log in")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accent)
                        .cornerRadius(12)
                    }
                    .disabled(store.isLoggingIn)

                    Text("Demo: any username and password")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(Color.black.opacity(0.15))
                .cornerRadius(20)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }

    private func login() {
        store.login(username: username, password: password)
    }
}
