import Foundation
import Auth
import Supabase

enum SignUpResult {
    case signedIn
    case emailConfirmationRequired
}

private final class TaskHolder: @unchecked Sendable {
    var task: Task<Void, Never>?
    deinit { task?.cancel() }
}

@Observable
@MainActor
final class AuthManager {
    var session: Session?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    private let supabase = SupabaseConfig.client
    private let taskHolder = TaskHolder()


    init() {
        session = supabase.auth.currentSession
        listenForAuthChanges()
    }

    deinit {
        // TaskHolder handles cancellation automatically ✅
    }

    func signUp(fullName: String, email: String, password: String) async throws -> SignUpResult {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )

            if response.session != nil {
                session = response.session
                return .signedIn
            }

            successMessage = "Check your email to confirm your account."
            return .emailConfirmationRequired
        } catch {
            errorMessage = mapAuthError(error)
            throw error
        }
    }

    func signOut() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.auth.signOut()
            session = nil
        } catch {
            errorMessage = mapAuthError(error)
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = mapAuthError(error)
        }
    }

    private func listenForAuthChanges() {
        taskHolder.task = Task {
            for await (_, session) in supabase.auth.authStateChanges {
                self.session = session
            }
        }
    }

    private func mapAuthError(_ error: Error) -> String {
        let message = error.localizedDescription.lowercased()

        if message.contains("already registered") || message.contains("already exists") {
            return "An account with this email already exists."
        }

        if message.contains("password") && (message.contains("short") || message.contains("least")) {
            return "Password must be at least 6 characters."
        }

        if message.contains("invalid") && message.contains("email") {
            return "Please enter a valid email address."
        }

        if message.contains("network") || message.contains("internet") {
            return "Network error. Please check your connection and try again."
        }

        if let configError = error as? SupabaseConfigError {
            return configError.localizedDescription
        }

        return error.localizedDescription
    }
}
