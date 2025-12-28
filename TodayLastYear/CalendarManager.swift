import EventKit
import Combine

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
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
        
        // Get the start and end of the same day, one year ago
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return }
        let startOfDay = calendar.startOfDay(for: oneYearAgo)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let fetchedEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = fetchedEvents
        }
    }
}
