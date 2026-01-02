import SwiftUI
import EventKit
import WidgetKit

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                switch calendarManager.authorizationStatus {
                case .notDetermined:
                    onboardingView
                    
                case .fullAccess:
                    if calendarManager.events.isEmpty {
                        emptyStateView
                    } else {
                        eventListView
                    }
                    
                default:
                    deniedView
                }
            }
            .navigationTitle(calendarManager.oneYearAgoDate.formatted(.dateTime.month(.wide).day().year()))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundStyle(Theme.colors.textSecondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(Theme.colors.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.colors.background.ignoresSafeArea())
        .onAppear {
            Task {
                if notificationManager.isAuthorized {
                    await notificationManager.scheduleDailyNotification()
                }
            }
            WidgetCenter.shared.reloadAllTimelines()
        }   
    }
    
    // MARK: - Subviews
    
    private var onboardingView: some View {
        VStack(spacing: Theme.layout.paddingLarge) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(Theme.colors.primary)
            
            Text("See what you did on this day, one year ago")
                .font(Theme.typography.headlineFont)
                .foregroundStyle(Theme.colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await calendarManager.requestAccess()
                    _ = await notificationManager.requestAuthorization()
                }
            } label: {
                Text("Get Started")
                    .font(Theme.typography.headlineFont)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.layout.paddingLarge)
                    .padding(.vertical, Theme.layout.paddingMedium)
                    .background(Theme.colors.primary)
                    .cornerRadius(Theme.layout.cornerRadiusMedium)
            }
        }
        .padding(Theme.layout.paddingLarge)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.layout.paddingMedium) {
            Image(systemName: "moon.stars")
                .font(.system(size: 50))
                .foregroundStyle(Theme.colors.secondary)
            
            Text("Nothing happened")
                .font(Theme.typography.titleFont)
                .foregroundStyle(Theme.colors.textPrimary)
            
            Text("You had no events on this day last year.")
                .font(Theme.typography.bodyFont)
                .foregroundStyle(Theme.colors.textSecondary)
        }
    }
    
    private var deniedView: some View {
        VStack(spacing: Theme.layout.paddingMedium) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(Theme.colors.primary)
            
            Text("Calendar Access Denied")
                .font(Theme.typography.titleFont)
                .foregroundStyle(Theme.colors.textPrimary)
            
            Text("Please enable calendar access in Settings.")
                .font(Theme.typography.bodyFont)
                .foregroundStyle(Theme.colors.textSecondary)
        }
    }
    
    private var eventListView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.layout.paddingMedium) {
                ForEach(calendarManager.events, id: \.eventIdentifier) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRowView(event: event)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Theme.layout.paddingMedium)
        }
    }
}
