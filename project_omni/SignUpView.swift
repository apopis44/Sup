import SwiftUI

struct SignUpView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var validationMessage: String?
    @State private var showSuccessAlert = false

    private let signUpBlue = Color(red: 0.20, green: 0.58, blue: 1.0)

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    Text("Sign Up")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .center)

                    signUpPanel
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 64)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(false)
        .alert("Account Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(authManager.successMessage ?? "Check your email to confirm your account.")
        }
    }

    private var signUpPanel: some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                AuthTextField(
                    title: "Full Name",
                    systemImage: "person",
                    text: $fullName,
                    contentType: .name
                )

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
                    text: $password,
                    contentType: .newPassword
                )

                AuthSecureField(
                    title: "Confirm Password",
                    systemImage: "lock.rotation",
                    text: $confirmPassword,
                    contentType: .password
                )
            }

            if let validationMessage {
                Text(validationMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task { await createAccount() }
            } label: {
                Group {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .tint(signUpBlue)
            .disabled(authManager.isLoading)

            Button("Already have an account? Log in") {
                dismiss()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.black)
        }
        .padding(22)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.black.opacity(0.10), lineWidth: 1)
        }
    }

    private func createAccount() async {
        validationMessage = nil
        authManager.errorMessage = nil

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            validationMessage = "Please enter your full name."
            return
        }

        if !isValidEmail(trimmedEmail) {
            validationMessage = "Please enter a valid email address."
            return
        }

        if password.count < 6 {
            validationMessage = "Password must be at least 6 characters."
            return
        }

        if password != confirmPassword {
            validationMessage = "Passwords do not match."
            return
        }

        do {
            let result = try await authManager.signUp(
                fullName: trimmedName,
                email: trimmedEmail,
                password: password
            )

            if result == .emailConfirmationRequired {
                showSuccessAlert = true
            }
        } catch {
            // Error message is set on authManager.
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environment(AuthManager())
    }
}
