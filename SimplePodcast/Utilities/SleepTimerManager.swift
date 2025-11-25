import Foundation
import Combine
import UserNotifications

/// Manages sleep timer functionality for the podcast player
@MainActor
class SleepTimerManager: ObservableObject {
    static let shared = SleepTimerManager()

    // MARK: - Published Properties

    @Published private(set) var isActive: Bool = false
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var remainingTimeFormatted: String = "00:00"

    // MARK: - Timer Presets

    static let presets: [Int] = [15, 30, 45, 60]

    // MARK: - Private Properties

    private var timer: Timer?
    private var endTime: Date?
    private let audioPlayerService: AudioPlayerService

    // MARK: - Initialization

    private init() {
        self.audioPlayerService = AudioPlayerService.shared
        requestNotificationPermission()
    }

    // MARK: - Public Methods

    /// Start the sleep timer with specified minutes
    /// - Parameter minutes: Number of minutes until playback stops
    func start(minutes: Int) {
        stop()

        let totalSeconds = minutes * 60
        endTime = Date().addingTimeInterval(TimeInterval(totalSeconds))
        remainingSeconds = totalSeconds
        isActive = true

        updateFormattedTime()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    /// Stop and reset the sleep timer
    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil
        remainingSeconds = 0
        isActive = false
        remainingTimeFormatted = "00:00"
    }

    /// Add additional time to the running timer
    /// - Parameter minutes: Additional minutes to add
    func addTime(minutes: Int) {
        guard isActive, let currentEndTime = endTime else { return }

        let additionalSeconds = TimeInterval(minutes * 60)
        endTime = currentEndTime.addingTimeInterval(additionalSeconds)
        remainingSeconds += minutes * 60
        updateFormattedTime()
    }

    // MARK: - Private Methods

    private func tick() {
        guard let endTime = endTime else {
            stop()
            return
        }

        let remaining = endTime.timeIntervalSinceNow

        if remaining <= 0 {
            handleTimerComplete()
        } else {
            remainingSeconds = Int(remaining)
            updateFormattedTime()
        }
    }

    private func handleTimerComplete() {
        // Stop playback
        audioPlayerService.pause()

        // Show notification
        showCompletionNotification()

        // Reset timer
        stop()
    }

    private func updateFormattedTime() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        remainingTimeFormatted = String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func showCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Sleep Timer"
        content.body = "Playback stopped - sleep well!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
}
