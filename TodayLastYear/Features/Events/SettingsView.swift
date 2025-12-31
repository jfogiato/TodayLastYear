import SwiftUI
import WidgetKit

struct SettingsView: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var notificationsEnabled: Bool = false
    @State private var showingTimePicker = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $notificationsEnabled) {
                    Label {
                        Text("Daily Reminder")
                            .font(Theme.typography.bodyFont)
                    } icon: {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Theme.colors.primary)
                    }
                }
                .tint(Theme.colors.primary)
                .onChange(of: notificationsEnabled) { _, newValue in
                    Task {
                        await handleNotificationToggle(newValue)
                    }
                }
                
                if notificationsEnabled {
                    HStack {
                        Label {
                            Text("Reminder Time")
                                .font(Theme.typography.bodyFont)
                        } icon: {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(Theme.colors.secondary)
                        }
                        
                        Spacer()
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: reminderTime) { _, _ in
                                Task {
                                    await notificationManager.scheduleDailyNotification(at: reminderTime)
                                }
                            }
                    }
                }
            } header: {
                Text("Notifications")
                    .font(Theme.typography.captionFont)
            } footer: {
                Text("Get a daily reminder to check what happened on this day last year.")
                    .font(Theme.typography.captionFont)
                    .foregroundStyle(Theme.colors.textSecondary)
            }
            
            Section {
                HStack {
                    Label {
                        Text("Calendar Access")
                            .font(Theme.typography.bodyFont)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(Theme.colors.secondary)
                    }
                    
                    Spacer()
                    
                    Text("Granted")
                        .font(Theme.typography.subheadlineFont)
                        .foregroundStyle(Theme.colors.textSecondary)
                }
                
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label {
                        Text("Open System Settings")
                            .font(Theme.typography.bodyFont)
                    } icon: {
                        Image(systemName: "gear")
                            .foregroundStyle(Theme.colors.textSecondary)
                    }
                }
                .foregroundStyle(Theme.colors.textPrimary)
            } header: {
                Text("Permissions")
                    .font(Theme.typography.captionFont)
            }
            
            Section {
                HStack {
                    Text("Version")
                        .font(Theme.typography.bodyFont)
                    Spacer()
                    Text("1.0.0")
                        .font(Theme.typography.subheadlineFont)
                        .foregroundStyle(Theme.colors.textSecondary)
                }
            } header: {
                Text("About")
                    .font(Theme.typography.captionFont)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.colors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationsEnabled = notificationManager.isAuthorized
            loadSavedReminderTime()
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await notificationManager.requestAuthorization()
            if granted {
                await notificationManager.scheduleDailyNotification(at: reminderTime)
            } else {
                await MainActor.run {
                    notificationsEnabled = false
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    private func loadSavedReminderTime() {
        if let savedHour = UserDefaults.standard.object(forKey: "reminderHour") as? Int,
           let savedMinute = UserDefaults.standard.object(forKey: "reminderMinute") as? Int {
            reminderTime = Calendar.current.date(from: DateComponents(hour: savedHour, minute: savedMinute)) ?? reminderTime
        }
    }
}
