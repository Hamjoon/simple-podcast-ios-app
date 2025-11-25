import SwiftUI

/// Sleep timer view with preset buttons and countdown display
struct SleepTimerView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)

                Text("Sleep Timer")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            // Timer content
            if viewModel.sleepTimer.isActive {
                TimerActiveView()
            } else {
                TimerPresetsView()
            }
        }
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray4), lineWidth: 2)
        )
    }
}

/// View showing timer preset buttons
struct TimerPresetsView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(SleepTimerManager.presets, id: \.self) { minutes in
                Button {
                    viewModel.sleepTimer.start(minutes: minutes)
                } label: {
                    Text("\(minutes) min")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryGradientStart)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primaryGradientStart, lineWidth: 2)
                        )
                }
            }
        }
    }
}

/// View showing active timer countdown
struct TimerActiveView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        HStack {
            // Countdown display
            Text(viewModel.sleepTimer.remainingTimeFormatted)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            // Cancel button
            Button {
                viewModel.sleepTimer.stop()
            } label: {
                Text("Cancel")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
        }
        .padding(15)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primaryGradientStart,
                    Color.primaryGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

#Preview {
    VStack(spacing: 20) {
        SleepTimerView()
    }
    .padding()
    .environmentObject(PodcastViewModel())
}
