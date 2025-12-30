import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    let icon: String?
    let color: Color

    init(label: String, value: String, icon: String? = nil, color: Color = .primary) {
        self.label = label
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
            }

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        StatRow(label: "iOS Apps", value: "24", icon: "iphone", color: .blue)
        StatRow(label: "macOS Apps", value: "30", icon: "desktopcomputer", color: .purple)

        HStack(spacing: 12) {
            StatBadge(value: "54", label: "Total", color: .blue)
            StatBadge(value: "24", label: "iOS", color: .green)
            StatBadge(value: "30", label: "macOS", color: .purple)
        }
    }
    .padding()
}
