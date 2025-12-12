import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = .cosmosPurple
    var foregroundColor: Color = .softLavender

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [foregroundColor, foregroundColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(min(progress, 1.0))))
            }
        }
        .frame(height: height)
    }
}

struct LevelProgressView: View {
    let stardust: Int

    var body: some View {
        let levelInfo = LevelInfo.level(for: stardust)
        let progress = LevelInfo.progress(for: stardust)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(levelInfo.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.softLavender)
                Text(levelInfo.name)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
                Spacer()
                if levelInfo.level < 8 {
                    let next = LevelInfo.levels[levelInfo.level]
                    Text("\(stardust)/\(next.stardustRequired)")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.5))
                }
            }

            ProgressBar(progress: progress)
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cosmosBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isEnabled ?
                            LinearGradient(
                                colors: [.softLavender, .softPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(!isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.softLavender)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.softLavender.opacity(0.5), lineWidth: 1)
                )
        }
    }
}
