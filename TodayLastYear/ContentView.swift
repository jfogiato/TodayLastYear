import SwiftUI
import EventKit

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        NavigationStack {
            Group {
                switch calendarManager.authorizationStatus {
                case .notDetermined:
                    VStack(spacing: 20) {
                        Text("See what you did on this day, one year ago")
                            .multilineTextAlignment(.center)
                        Button("Allow Calendar Access") {
                            Task {
                                await calendarManager.requestAccess()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                case .fullAccess:
                    if calendarManager.events.isEmpty {
                        ContentUnavailableView(
                            "Nothing happened",
                            systemImage: "calendar",
                            description: Text("You had no events on this day last year.")
                        )
                    } else {
                        List(calendarManager.events, id: \.eventIdentifier) { event in
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                if let startDate = event.startDate {
                                    Text(startDate, style: .time)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                default:
                    ContentUnavailableView(
                        "Calendar Access Denied",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Please enable calendar access in Settings.")
                    )
                }
            }
            .navigationTitle("One Year Ago")
        }
    }
}
