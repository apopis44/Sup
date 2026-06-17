import SwiftUI
import Auth

struct HomeView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome!")
                .font(.largeTitle.weight(.bold))

            if let email = authManager.session?.user.email {
                Text(email)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Button("Sign Out") {
                Task { await authManager.signOut() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authManager.isLoading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    HomeView()
        .environment(AuthManager())
}
