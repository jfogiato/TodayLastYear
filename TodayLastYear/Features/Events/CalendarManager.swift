import EventKit
import Combine

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    var oneYearAgoDate: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    }
    
    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                if granted {
                    self.fetchEventsFromOneYearAgo()
                }
            }
        } catch {
            print("Failed to request access: \(error)")
        }
    }
    
    func fetchEventsFromOneYearAgo() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return }
        var startOfDay = calendar.startOfDay(for: oneYearAgo)
        var endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Handle leap year edge cases
        let todayComponents = calendar.dateComponents([.month, .day], from: now)
        
        // If today is Feb 29, also include Feb 28 from last year
        if todayComponents.month == 2 && todayComponents.day == 29 {
            startOfDay = calendar.date(byAdding: .day, value: -1, to: startOfDay)!
        }
        
        // If today is Feb 28 and last year was a leap year, also include Feb 29
        if todayComponents.month == 2 && todayComponents.day == 28 {
            let lastYearFeb29Components = DateComponents(year: calendar.component(.year, from: oneYearAgo), month: 2, day: 29)
            if calendar.date(from: lastYearFeb29Components) != nil {
                endOfDay = calendar.date(byAdding: .day, value: 1, to: endOfDay)!
            }
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let fetchedEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = fetchedEvents
        }
    }
}
