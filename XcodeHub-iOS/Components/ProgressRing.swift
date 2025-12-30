import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    init(progress: Double, lineWidth: CGFloat = 10, color: Color = .blue) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

struct ProgressRingWithLabel: View {
    let progress: Double
    let label: String
    let color: Color
    let size: CGFloat

    init(progress: Double, label: String, color: Color = .blue, size: CGFloat = 100) {
        self.progress = progress
        self.label = label
        self.color = color
        self.size = size
    }

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, lineWidth: size * 0.1, color: color)

            VStack(spacing: 2) {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))

                Text(label)
                    .font(.system(size: size * 0.1))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressRing(progress: 0.75, color: .blue)
            .frame(width: 100, height: 100)

        ProgressRingWithLabel(
            progress: 0.65,
            label: "Used",
            color: .orange,
            size: 150
        )
    }
    .padding()
}
