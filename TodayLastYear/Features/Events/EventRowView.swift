import SwiftUI
import EventKit

struct EventRowView: View {
    let event: EKEvent
    
    var body: some View {
        HStack(spacing: Theme.layout.paddingMedium) {
            // Subtle color accent from calendar
            RoundedRectangle(cornerRadius: 3)
                .fill(calendarColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(Theme.typography.headlineFont)
                    .foregroundStyle(Theme.colors.textPrimary)
                
                if event.isAllDay {
                    Text("All Day")
                        .font(Theme.typography.subheadlineFont)
                        .foregroundStyle(Theme.colors.textSecondary)
                } else if let startDate = event.startDate {
                    Text(startDate, style: .time)
                        .font(Theme.typography.subheadlineFont)
                        .foregroundStyle(Theme.colors.textSecondary)
                }
                
                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                        Text(location)
                            .lineLimit(1)
                    }
                    .font(Theme.typography.captionFont)
                    .foregroundStyle(Theme.colors.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Theme.colors.textSecondary)
        }
        .memoryCardStyle()
    }
    
    private var calendarColor: Color {
        if let cgColor = event.calendar?.cgColor {
            return Color(cgColor: cgColor)
        }
        return Theme.colors.calendarAccent
    }
}
