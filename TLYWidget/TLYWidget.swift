import WidgetKit
import SwiftUI
import EventKit

// MARK: - Timeline Entry

struct TLYEntry: TimelineEntry {
    let date: Date
    let events: [EventData]
    let oneYearAgoDate: Date
}

// Simple struct since EKEvent isn't directly usable in widgets
struct EventData: Identifiable {
    let id: String
    let title: String
    let isAllDay: Bool
    let startDate: Date
}

// MARK: - Provider

struct TLYProvider: TimelineProvider {
    private let eventStore = EKEventStore()
    
    func placeholder(in context: Context) -> TLYEntry {
        TLYEntry(
            date: Date(),
            events: [
                EventData(id: "1", title: "Coffee with Sarah", isAllDay: false, startDate: Date()),
                EventData(id: "2", title: "Team standup", isAllDay: false, startDate: Date())
            ],
            oneYearAgoDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TLYEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TLYEntry>) -> Void) {
        let events = fetchEventsFromOneYearAgo()
        let oneYearAgoDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        let entry = TLYEntry(
            date: Date(),
            events: events,
            oneYearAgoDate: oneYearAgoDate
        )
        
        // Refresh at midnight
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
    
    private func fetchEventsFromOneYearAgo() -> [EventData] {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .fullAccess else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return [] }
        let startOfDay = calendar.startOfDay(for: oneYearAgo)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        return ekEvents.map { event in
            EventData(
                id: event.eventIdentifier,
                title: event.title ?? "Untitled",
                isAllDay: event.isAllDay,
                startDate: event.startDate
            )
        }
    }
}

// MARK: - Widget Views

struct TLYWidgetEntryView: View {
    var entry: TLYEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: TLYEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.colors.primary)
                
                Text(entry.oneYearAgoDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.colors.primary)
            }
            
            if entry.events.isEmpty {
                Spacer()
                Text("Nothing happened")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.events.prefix(3)) { event in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.colors.secondary)
                                .frame(width: 6, height: 6)
                            
                            Text(event.title)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(Theme.colors.textPrimary)
                                .lineLimit(1)
                        }
                    }
                    
                    if entry.events.count > 3 {
                        Text("+\(entry.events.count - 3) more")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.colors.textSecondary)
                            .padding(.leading, 12)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Theme.colors.background
        }
    }
}

struct MediumWidgetView: View {
    let entry: TLYEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Left side - date card
            VStack(spacing: 4) {
                Image(systemName: "memories")
                    .font(.system(.title2, design: .rounded))
                    .foregroundStyle(Theme.colors.primary)
                
                Text(entry.oneYearAgoDate.formatted(.dateTime.day()))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.colors.textPrimary)
                
                Text(entry.oneYearAgoDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Theme.colors.textSecondary)
                
                Text(entry.oneYearAgoDate.formatted(.dateTime.year()))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.colors.textSecondary)
            }
            .frame(width: 70)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Theme.layout.cornerRadiusSmall)
                    .fill(Color.white)
                    .shadow(color: Theme.colors.warmBlack.opacity(0.08), radius: 4, x: 0, y: 2)
            )
            
            // Right side - events
            VStack(alignment: .leading, spacing: 0) {
                if entry.events.isEmpty {
                    Spacer()
                    Text("No events on this day")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Theme.colors.textSecondary)
                    Spacer()
                } else {
                    ForEach(entry.events.prefix(3)) { event in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.colors.secondary)
                                .frame(width: 3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.system(.footnote, design: .rounded, weight: .medium))
                                    .foregroundStyle(Theme.colors.textPrimary)
                                    .lineLimit(1)
                                
                                if event.isAllDay {
                                    Text("All Day")
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(Theme.colors.textSecondary)
                                } else {
                                    Text(event.startDate, style: .time)
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(Theme.colors.textSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.layout.cornerRadiusSmall)
                                .fill(Color.white)
                                .shadow(color: Theme.colors.warmBlack.opacity(0.06), radius: 2, x: 0, y: 1)
                        )
                    }
                    
                    if entry.events.count > 3 {
                        Text("+\(entry.events.count - 3) more")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.colors.textSecondary)
                            .padding(.top, 4)
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Theme.colors.background
        }
    }
}

// MARK: - Widget Configuration

@main
struct TLYWidget: Widget {
    let kind: String = "TLYWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TLYProvider()) { entry in
            TLYWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("One Year Ago")
        .description("See what you did on this day last year.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
