import SwiftUI

struct AuthTextField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(.black.opacity(0.50))
                .frame(width: 22)

            TextField(title, text: $text)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .autocorrectionDisabled(keyboardType == .emailAddress)
                .foregroundStyle(.black)
                .tint(.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.black.opacity(0.12), lineWidth: 1)
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var contentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(.black.opacity(0.50))
                .frame(width: 22)

            SecureField(title, text: $text)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundStyle(.black)
                .tint(.black)
        }
        .id(title)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.black.opacity(0.12), lineWidth: 1)
        }
    }
}
