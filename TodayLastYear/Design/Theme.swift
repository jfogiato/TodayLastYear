import SwiftUI

// MARK: - Colors

struct AppColors {
    // Primary brand colors
    let burntOrange = Color(red: 0.78, green: 0.42, blue: 0.2)
    let oliveGreen = Color(red: 0.42, green: 0.45, blue: 0.29)
    
    // Warm neutrals (light mode base values)
    let warmWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let warmGray = Color(red: 0.55, green: 0.52, blue: 0.48)
    let warmBlack = Color(red: 0.15, green: 0.13, blue: 0.11)
    
    // Semantic colors
    var primary: Color { burntOrange }
    var secondary: Color { oliveGreen }
    
    // Adaptive colors for dark mode support
    var background: Color {
        Color("Background", bundle: nil)
    }
    
    var cardBackground: Color {
        Color("CardBackground", bundle: nil)
    }
    
    var textPrimary: Color {
        Color("TextPrimary", bundle: nil)
    }
    
    var textSecondary: Color {
        Color("TextSecondary", bundle: nil)
    }
    
    // Calendar accent (used for calendar dots, can be overridden by actual calendar color)
    var calendarAccent: Color { oliveGreen }
}

// MARK: - Typography

struct AppTypography {
    let titleFont: Font = .system(.title, design: .rounded, weight: .semibold)
    let headlineFont: Font = .system(.headline, design: .rounded, weight: .medium)
    let bodyFont: Font = .system(.body, design: .rounded)
    let subheadlineFont: Font = .system(.subheadline, design: .rounded)
    let captionFont: Font = .system(.caption, design: .rounded)
}

// MARK: - Spacing & Layout

struct AppLayout {
    let paddingSmall: CGFloat = 8
    let paddingMedium: CGFloat = 16
    let paddingLarge: CGFloat = 24
    
    let cornerRadiusSmall: CGFloat = 8
    let cornerRadiusMedium: CGFloat = 12
    let cornerRadiusLarge: CGFloat = 16
    
    let cardShadowRadius: CGFloat = 8
    let cardShadowY: CGFloat = 2
}

// MARK: - Theme

struct AppTheme {
    let colors = AppColors()
    let typography = AppTypography()
    let layout = AppLayout()
}

// Global theme instance
let Theme = AppTheme()

// MARK: - Reusable Card Style

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(Theme.layout.paddingMedium)
            .background(Theme.colors.cardBackground)
            .cornerRadius(Theme.layout.cornerRadiusMedium)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Theme.colors.warmBlack.opacity(0.08),
                radius: Theme.layout.cardShadowRadius,
                x: 0,
                y: Theme.layout.cardShadowY
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Subtle Memory/Photo Style

struct MemoryCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(Theme.layout.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: Theme.layout.cornerRadiusMedium)
                    .fill(Theme.colors.cardBackground)
                    .shadow(
                        color: colorScheme == .dark
                            ? Color.black.opacity(0.3)
                            : Theme.colors.warmBlack.opacity(0.1),
                        radius: Theme.layout.cardShadowRadius,
                        x: 0,
                        y: Theme.layout.cardShadowY
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.layout.cornerRadiusMedium)
                    .stroke(Theme.colors.burntOrange.opacity(colorScheme == .dark ? 0.25 : 0.15), lineWidth: 1)
            )
    }
}

extension View {
    func memoryCardStyle() -> some View {
        modifier(MemoryCardModifier())
    }
}

extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
}
