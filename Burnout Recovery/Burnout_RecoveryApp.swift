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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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

                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
