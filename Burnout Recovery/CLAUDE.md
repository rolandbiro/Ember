# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build for simulator
xcodebuild -project "../Burnout Recovery.xcodeproj" -scheme "Burnout Recovery" -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build for device (requires signing)
xcodebuild -project "../Burnout Recovery.xcodeproj" -scheme "Burnout Recovery" -destination 'generic/platform=iOS' build
```

No tests are currently configured for this project.

## Architecture Overview

Burnout Recovery is a SwiftUI iOS app that helps users recover from burnout through daily guided tasks, gamification (stardust rewards), and progress tracking.

### App Flow

1. **Launch**: `Burnout_RecoveryApp` checks `User.onboardingCompleted`
2. **First Launch**: Shows `WelcomeView` → `OnboardingCoordinator` (5-step flow: name → situation → goal → assessment → results)
3. **Returning Users**: Shows `MainTabView` (Home + Profile tabs)

### Core Services (Singleton Pattern)

- **`UserService.shared`**: Manages user state, stardust/XP, streaks, level-ups. Persists to UserDefaults.
- **`TaskService.shared`**: Loads tasks from `Tasks.json`, generates daily tasks based on user's pace, tracks completion.
- **`BadgeService.shared`**: Evaluates badge criteria on task completion.

### Data Flow

```
Tasks.json → TaskService.allTasks → TaskService.dailyTasks → HomeView
                                                              ↓
User selects task → TaskDetailView → completeTask() → UserService (stardust, streak)
                                                    → BadgeService (badge checks)
```

### Key Models

- **`User`**: Name, situation, goal, pace, stardust, level, streaks, completed tasks
- **`RecoveryTask`**: Static task definitions from JSON with UI type variants
- **`DailyTask`**: Instance of a task for today with completion state
- **`Pace`**: `.gentle` (1 task/day), `.steady` (2), `.active` (3)

### Task UI Types

Tasks in `Tasks.json` use different UI patterns via `uiType`:
- `simple_choice`: Single selection from options
- `multi_select`: Multiple selection with optional limits
- `slider_choice`: Slider-based selection
- `timed_activity`: Breathing/activity with timer
- `choice_with_note`: Selection plus optional text note

### Level System

Stardust thresholds in `LevelInfo.levels`: Spark (0) → Flicker (200) → Glow (500) → Warmth (1000) → Radiance (2000) → Blaze (3500) → Brilliance (5500) → Ember Master (8000)

### Color Palette

All colors defined in `Resources/Colors.swift`:
- `.cosmosBackground` (#0B0B1A) - dark background
- `.cosmosPurple` (#1E1B4B) - card backgrounds
- `.softLavender` (#A78BFA) - primary accent
- `.softPeach` (#FED7AA) - rewards/highlights
- `.starWhite` (#F5F5F7) - text

## File Organization

```
Burnout Recovery/
├── Burnout_RecoveryApp.swift     # App entry, routing logic
├── Data/Tasks.json               # All task definitions
├── Models/                       # Data structures
├── Services/                     # Singleton services
├── Views/
│   ├── Home/                     # Main task list
│   ├── Onboarding/               # 5-step onboarding flow
│   ├── Tasks/                    # Task detail & activities
│   ├── Celebration/              # Reward animations
│   └── Profile/                  # User profile & settings
├── Components/                   # Reusable UI components
└── Resources/                    # Colors, assets
```

## Key Patterns

- **Coordinator pattern**: `OnboardingCoordinator` manages multi-step flow with enum-based state
- **UserDefaults persistence**: Services encode/decode Codable models directly
- **Daily task generation**: Random selection prioritizing category diversity, regenerates at midnight
- **Celebration overlays**: Level-up and task completion celebrations use ZStack overlays
