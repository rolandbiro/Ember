import SwiftUI

struct TimedActivityView: View {
    let duration: Int
    let onComplete: () -> Void

    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var isComplete = false
    @State private var timer: Timer?

    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.cosmosPurple, lineWidth: 8)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.softLavender, .softPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.starWhite)

                    if isComplete {
                        Text("Complete!")
                            .font(.caption)
                            .foregroundColor(.softLavender)
                    }
                }
            }

            if !isComplete {
                Button(action: toggleTimer) {
                    ZStack {
                        Circle()
                            .fill(Color.softLavender)
                            .frame(width: 64, height: 64)

                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.cosmosBackground)
                    }
                }
            }
        }
    }

    private var progress: Double {
        1.0 - (Double(timeRemaining) / Double(duration))
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeTimer()
            }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func completeTimer() {
        pauseTimer()
        isComplete = true
        onComplete()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
