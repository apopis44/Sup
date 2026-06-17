import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager  // ← added
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 26) {
                        Text("Login")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .center)

                        authPanel
                    }
                    .padding(.horizontal, 21)
                    .padding(.vertical, 64)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var authPanel: some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                AuthTextField(
                    title: "Email",
                    systemImage: "envelope",
                    text: $email,
                    keyboardType: .emailAddress,
                    contentType: .emailAddress
                )

                AuthSecureField(
                    title: "Password",
                    systemImage: "lock",
                    text: $password
                )
            }

            HStack {
                Button {
                    rememberMe.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(rememberMe ? Color.black : Color.black.opacity(0.54))

                        Text("Remember me")
                    }
                    .foregroundStyle(.black.opacity(0.72))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remember me")
                .accessibilityValue(rememberMe ? "On" : "Off")

                Spacer()

                Button("Forgot password?") {}
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
            }
            .font(.subheadline)

            // ← added: show error message
            if let error = authManager.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: 10) {
                Button {
                    Task { await authManager.signIn(email: email, password: password) }  // ← added
                } label: {
                    if authManager.isLoading {
                        ProgressView()  // ← shows spinner while logging in
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .tint(.black)
                .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)  // ← added

                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .tint(Color(red: 0.20, green: 0.58, blue: 1.0))
            }

            Divider()
                .overlay(.black.opacity(0.12))

            VStack(spacing: 12) {
                Text("Or log in with")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.52))

                VStack(spacing: 10) {
                    SocialAuthButton(provider: .apple)
                    SocialAuthButton(provider: .google)
                    SocialAuthButton(provider: .facebook)
                    SocialAuthButton(provider: .microsoft)
                }
            }
        }
        .padding(22)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.black.opacity(0.10), lineWidth: 1)
        }
    }
}

@ViewBuilder
private func socialBrandIcon(_ name: String) -> some View {
    Image(name)
        .renderingMode(.original)
        .resizable()
        .scaledToFit()
}

private enum SocialProvider: String {
    case apple, google, facebook, microsoft

    var title: String {
        switch self {
        case .apple: "Continue with Apple"
        case .google: "Continue with Google"
        case .facebook: "Continue with Facebook"
        case .microsoft: "Continue with Microsoft"
        }
    }

    @ViewBuilder
    var icon: some View {
        switch self {
        case .apple: socialBrandIcon("AppleLogo")
        case .google: socialBrandIcon("GoogleG")
        case .facebook: socialBrandIcon("FacebookLogo")
        case .microsoft: socialBrandIcon("MicrosoftLogo")
        }
    }
}

private struct SocialAuthButton: View {
    let provider: SocialProvider

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 12) {
                provider.icon
                    .frame(width: 24, height: 24)

                Text(provider.title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)

                Spacer(minLength: 0)
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.black.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
