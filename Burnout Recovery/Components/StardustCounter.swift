import SwiftUI

struct StardustCounter: View {
    let amount: Int
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundColor(.softPeach)
            Text("\(amount)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
            if showLabel {
                Text("stardust")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.cosmosPurple)
        )
    }
}

struct StardustRewardView: View {
    let amount: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 4) {
            Text("+\(amount)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.softPeach)
            Image(systemName: "sparkles")
                .foregroundColor(.softPeach)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundColor(.softPeach)
            Text("\(days)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
            Text(days == 1 ? "day" : "days")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.softPeach.opacity(0.3), Color.softPink.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(Color.softPeach.opacity(0.5), lineWidth: 1)
        )
    }
}
