import SwiftUI

struct StorageCard: View {
    let title: String
    let size: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(size)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StorageCardLarge: View {
    let title: String
    let size: String
    let icon: String
    let color: Color
    let percentage: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Spacer()

                if let pct = percentage {
                    Text(String(format: "%.1f%%", pct))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(size)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 16) {
        StorageCard(
            title: "Projects",
            size: "2.5 GB",
            icon: "folder",
            color: .orange
        )

        StorageCardLarge(
            title: "Xcode DerivedData",
            size: "1.2 GB",
            icon: "hammer",
            color: .blue,
            percentage: 45.2
        )
    }
    .padding()
}
