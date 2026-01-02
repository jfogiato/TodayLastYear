//
//  TodayLastYearApp.swift
//  TodayLastYear
//
//  Created by Joe Fogiato on 12/28/25.
//

import SwiftUI

@main
struct TodayLastYearApp: App {
    init() {
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Use dynamic colors that adapt to light/dark mode
        appearance.backgroundColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
            } else {
                return UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)
            }
        }
        
        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1.0)
                } else {
                    return UIColor(red: 0.15, green: 0.13, blue: 0.11, alpha: 1.0)
                }
            }
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
