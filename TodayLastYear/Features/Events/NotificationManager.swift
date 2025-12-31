import UserNotifications
import EventKit
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }
            if granted {
                await scheduleDailyNotification()
            }
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleDailyNotification() async {
        // Remove any existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create the notification content (will be updated dynamically)
        let content = UNMutableNotificationContent()
        content.title = "One Year Ago"
        content.body = await generateNotificationBody()
        content.sound = .default
        
        // Schedule for 9am daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Daily notification scheduled for 9am")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    private func generateNotificationBody() async -> String {
        let eventCount = fetchEventCountFromOneYearAgo()
        
        switch eventCount {
        case 0:
            return "Nothing happened on this day last year. A quiet day!"
        case 1:
            return "You had 1 event this day last year. Check it out!"
        default:
            return "You had \(eventCount) events this day last year! Check them out!"
        }
    }
    
    private func fetchEventCountFromOneYearAgo() -> Int {
        let eventStore = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .fullAccess else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return 0 }
        let startOfDay = calendar.startOfDay(for: oneYearAgo)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        return events.count
    }
}
