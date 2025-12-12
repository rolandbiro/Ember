//
//  Burnout_RecoveryApp.swift
//  Burnout Recovery
//
//  Created by Biro Roland on 2025. 12. 12..
//

import SwiftUI

@main
struct Burnout_RecoveryApp: App {
    @StateObject private var userService = UserService.shared
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !userService.user.onboardingCompleted {
                    if showOnboarding {
                        OnboardingCoordinator {
                            // Onboarding complete - view will refresh
                        }
                    } else {
                        WelcomeView(showOnboarding: $showOnboarding)
                    }
                } else {
                    MainTabView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
