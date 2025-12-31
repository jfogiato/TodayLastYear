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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.colors.background)
        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor(Theme.colors.textPrimary)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
