import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType

    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)

            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var message: String?
    var type: ToastView.ToastType = .success

    func body(content: Content) -> some View {
        ZStack {
            content

            if let message = message {
                VStack {
                    Spacer()
                    ToastView(message: message, type: type)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 100)
                }
                .animation(.spring(), value: message)
            }
        }
    }
}

extension View {
    func toast(message: Binding<String?>, type: ToastView.ToastType = .success) -> some View {
        modifier(ToastModifier(message: message, type: type))
    }
}

#Preview {
    VStack(spacing: 20) {
        ToastView(message: "Project opened successfully", type: .success)
        ToastView(message: "Failed to connect", type: .error)
        ToastView(message: "Loading...", type: .info)
    }
}
