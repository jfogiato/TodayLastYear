import SwiftUI
import EventKit

struct EventDetailView: View {
    let event: EKEvent
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.layout.paddingMedium) {
                // Header card
                VStack(alignment: .leading, spacing: Theme.layout.paddingSmall) {
                    HStack {
                        Circle()
                            .fill(calendarColor)
                            .frame(width: 10, height: 10)
                        Text(event.calendar?.title ?? "Calendar")
                            .font(Theme.typography.captionFont)
                            .foregroundStyle(Theme.colors.textSecondary)
                    }
                    
                    Text(event.title)
                        .font(Theme.typography.titleFont)
                        .foregroundStyle(Theme.colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .memoryCardStyle()
                
                // Time card
                DetailCard(title: "When", icon: "clock") {
                    if event.isAllDay {
                        Text("All Day")
                            .font(Theme.typography.bodyFont)
                            .foregroundStyle(Theme.colors.textPrimary)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.startDate, format: .dateTime.weekday(.wide).month(.wide).day().year())
                            Text("\(event.startDate, style: .time) – \(event.endDate, style: .time)")
                                .foregroundStyle(Theme.colors.textSecondary)
                        }
                        .font(Theme.typography.bodyFont)
                        .foregroundStyle(Theme.colors.textPrimary)
                    }
                }
                
                // Location card
                if let location = event.location, !location.isEmpty {
                    DetailCard(title: "Location", icon: "location") {
                        Text(location)
                            .font(Theme.typography.bodyFont)
                            .foregroundStyle(Theme.colors.textPrimary)
                    }
                }
                
                // Notes card
                if let notes = event.notes, !notes.isEmpty {
                    DetailCard(title: "Notes", icon: "note.text") {
                        Text(notes)
                            .font(Theme.typography.bodyFont)
                            .foregroundStyle(Theme.colors.textPrimary)
                    }
                }
                
                // URL card
                if let url = event.url {
                    DetailCard(title: "Link", icon: "link") {
                        Link(url.absoluteString, destination: url)
                            .font(Theme.typography.bodyFont)
                            .foregroundStyle(Theme.colors.primary)
                    }
                }
            }
            .padding(Theme.layout.paddingMedium)
        }
        .background(Theme.colors.background.ignoresSafeArea())
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var calendarColor: Color {
        if let cgColor = event.calendar?.cgColor {
            return Color(cgColor: cgColor)
        }
        return Theme.colors.calendarAccent
    }
}

// MARK: - Reusable Detail Card

struct DetailCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.layout.paddingSmall) {
            Label(title, systemImage: icon)
                .font(Theme.typography.captionFont)
                .foregroundStyle(Theme.colors.textSecondary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .memoryCardStyle()
    }
}
