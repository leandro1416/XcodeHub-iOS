import SwiftUI

struct ProjectCard: View {
    let project: XcodeProject
    let onOpen: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: project.icon)
                    .font(.title2)
                    .foregroundStyle(project.platform == .iOS ? .blue : .purple)
                    .frame(width: 40, height: 40)
                    .background(
                        (project.platform == .iOS ? Color.blue : Color.purple)
                            .opacity(0.1)
                    )
                    .cornerRadius(10)

                Spacer()

                Text(project.platform.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (project.platform == .iOS ? Color.blue : Color.purple)
                            .opacity(0.1)
                    )
                    .foregroundStyle(project.platform == .iOS ? .blue : .purple)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(project.path)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                Button(action: onOpen) {
                    HStack {
                        Image(systemName: "hammer.fill")
                        Text("Open")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 44, height: 38)
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct ProjectCardCompact: View {
    let project: XcodeProject
    let onOpen: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .font(.title3)
                .foregroundStyle(project.platform == .iOS ? .blue : .purple)
                .frame(width: 36, height: 36)
                .background(
                    (project.platform == .iOS ? Color.blue : Color.purple)
                        .opacity(0.1)
                )
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(project.platform.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)

            Button(action: onOpen) {
                Image(systemName: "arrow.up.forward.square")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        ProjectCard(
            project: XcodeProject(
                name: "ProductivityHub-iOS",
                path: "/Users/neog/Apps/iOS/ProductivityHub-iOS"
            ),
            onOpen: {},
            onDelete: {}
        )

        ProjectCardCompact(
            project: XcodeProject(
                name: "17Licoes-macOS",
                path: "/Users/neog/Apps/macOS/17Licoes-macOS"
            ),
            onOpen: {},
            onDelete: {}
        )
    }
    .padding()
}
