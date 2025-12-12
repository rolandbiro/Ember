# Ember — Burnout Recovery

> *"Your spark is still there"*

**Version:** 1.0
**Date:** 2025-12-12
**Platform:** iOS (SwiftUI)
**Language:** English

---

## Overview

Ember is a gamified wellness app that helps users recognize, track, and recover from burnout through daily micro-tasks and reflections.

**This is not a clinical tool** — it's a premium, playful companion that makes recovery feel achievable and enjoyable.

### Design Principles

| Principle | Meaning |
|-----------|---------|
| **Playful, not infantile** | Game mechanics without childish aesthetics |
| **Professional, not clinical** | Evidence-based without feeling like therapy |
| **Rewarding, not overwhelming** | Micro-rewards that motivate, not exhaust |
| **Simple interaction** | Choices over typing, taps over forms |
| **Elegant addiction** | Subtle dopamine hits that bring users back |
| **KISS** | Keep implementation simple, don't over-engineer |

---

## Visual Identity

### Style: Soft Cosmos

- Dark, calming backgrounds (deep blues, purples)
- Soft glowing accents (lavender, pink, peach)
- Floating particles, subtle star animations
- Elegant typography, generous spacing
- Premium feel — Headspace meets game UI

### Color Palette

```swift
extension Color {
    static let cosmosBackground = Color(hex: "0B0B1A")
    static let cosmosPurple = Color(hex: "1E1B4B")
    static let softLavender = Color(hex: "A78BFA")
    static let softPink = Color(hex: "F0ABFC")
    static let softBlue = Color(hex: "7DD3FC")
    static let softPeach = Color(hex: "FED7AA")
    static let starWhite = Color(hex: "F5F5F7")
}
```

---

## User Flow

### First Launch

```
1. Welcome Screen
   "Welcome to Ember"
   [Get Started]

2. Name Input
   "What should we call you?"
   [Text field - single word]

3. Situation (multi-choice)
   "What's been going on?"
   ○ Work is overwhelming me
   ○ I feel emotionally exhausted
   ○ I lost motivation for things I enjoyed
   ○ I'm always tired, no matter how much I rest
   ○ I want to prevent burnout

4. Goal (multi-choice)
   "What do you hope to achieve?"
   ○ Recover my energy
   ○ Find balance
   ○ Feel like myself again
   ○ Build healthier habits

5. Assessment (9 questions)
   MBI-GS9 based, choice format
   → Results: pace recommendation (not shown as score)

6. Journey Begins
   "Your path is ready" → First daily task
```

### Daily Use

```
Home Screen:
- Greeting + streak display
- Today's tasks (1-3 based on pace)
- Progress indicator (stardust + level)

Task Flow:
- Tap task → Task screen
- Complete (choices + optional note)
- Celebration → Return to home

Weekly:
- Quick reassessment (3 questions)
- Pace adjustment if needed
```

### Screen List (MVP)

| Screen | Purpose |
|--------|---------|
| Welcome | First launch intro |
| Onboarding (3 steps) | Name, situation, goal |
| Assessment | 9-question burnout check |
| Home | Daily hub, tasks, progress |
| Task Detail | Complete individual task |
| Celebration | Reward overlay |
| Profile | Stats, badges, settings |
| Settings | Notifications, preferences |

---

## Gamification System

### Currency: Stardust

| Action | Reward |
|--------|--------|
| Complete daily task | +30-75 stardust |
| Finish all daily tasks | +50 bonus |
| Daily check-in streak | +10 per day |
| Weekly assessment | +100 stardust |

### Levels

| Level | Name | Stardust Required |
|-------|------|-------------------|
| 1 | Spark | 0 |
| 2 | Flicker | 200 |
| 3 | Glow | 500 |
| 4 | Warmth | 1,000 |
| 5 | Radiance | 2,000 |
| 6 | Blaze | 3,500 |
| 7 | Brilliance | 5,500 |
| 8 | Ember Master | 8,000 |

### Streak System

- **Counter:** Days in a row with at least 1 task completed
- **Streak Freeze:** 1 free freeze per week (auto-used if missed)
- **Streak Loss:** Counter resets, but total stardust stays
- **Milestone rewards:** 7 days, 14 days, 30 days, 60 days, 100 days

### Badges (15 starter badges)

| Badge | Unlock Condition |
|-------|------------------|
| First Light | Complete first task |
| Week One | 7-day streak |
| Night Owl | Complete task after 9 PM |
| Early Bird | Complete task before 7 AM |
| Storyteller | Write 10 optional notes |
| Zen Mind | Complete 10 breathing tasks |
| Resilient | Recover from lost streak |
| Focused | Complete all tasks 5 days in a row |
| Blooming | Reach Level 3 |
| Rising Star | Reach Level 5 |
| Ember Master | Reach Level 8 |
| Monthly Hero | 30-day streak |
| Collector | Earn 5 badges |
| Balanced | Complete tasks in all 5 categories |
| Self-Aware | Complete 4 weekly assessments |

### Celebration Tiers

| Tier | Trigger | Animation |
|------|---------|-----------|
| **Micro** | Tap any choice | Subtle sparkle + soft haptic |
| **Medium** | Complete task | Stardust float up + sound + "+X stardust" |
| **Big** | Badge/Level/Milestone | Full screen glow + badge reveal + confetti |

---

## Task System

### 5 Task Categories

| Category | Icon | Purpose | Based On |
|----------|------|---------|----------|
| **Breathe** | Wind | Relaxation, stress relief | MBSR, breathing techniques |
| **Reflect** | Thought bubble | Self-awareness, journaling | CBT, reflective writing |
| **Gratitude** | Flower | Positive focus, reframing | Positive psychology |
| **Move** | Walking | Physical micro-actions | Behavioral activation |
| **Mindful** | Eye | Present moment awareness | Mindfulness research |

### Task UI Types

1. **Simple Choice** — Single select from options
2. **Multi-select** — Select all that apply
3. **Slider + Choice** — Scale rating + follow-up choice
4. **Timed Activity** — Guided breathing/meditation
5. **Choice + Optional Note** — Selection with text field option

### Pace System

| Pace | Daily Tasks | For Whom |
|------|-------------|----------|
| **Gentle** | 1 task | High burnout score |
| **Steady** | 2 tasks | Medium burnout score |
| **Active** | 3 tasks | Low/prevention mode |

User can adjust pace anytime in settings.

---

## Assessment

Based on MBI-GS9 (Maslach Burnout Inventory - General Survey, 9-item version), validated in 2024 research.

### Three Dimensions

1. **Exhaustion** (3 questions) — Emotional/physical depletion
2. **Cynicism** (3 questions) — Detachment, reduced engagement
3. **Efficacy** (3 questions) — Sense of accomplishment

### Scoring

- 7-point scale per question (Never → Daily)
- Results determine initial pace recommendation
- User never sees "burnout score" — only supportive messaging

---

## Notifications

### Strategy: Gentle Reminders (customizable)

**Default behavior:**
- 1 daily reminder at user-chosen time
- Streak warning if task not completed by 8 PM

**User can customize:**
- Reminder time
- Streak alerts on/off
- All notifications off

**Tone:** Supportive, never pushy
- "Your daily reflection is waiting"
- "Don't let your 7-day streak slip away"

---

## Technical Architecture

### Project Structure

```
Ember/
├── App/
│   └── EmberApp.swift
├── Models/
│   ├── User.swift
│   ├── Task.swift
│   ├── Progress.swift
│   └── Badge.swift
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   ├── Tasks/
│   ├── Celebration/
│   └── Profile/
├── Components/
│   ├── ChoiceButton.swift
│   ├── ProgressBar.swift
│   ├── StardustCounter.swift
│   └── BadgeView.swift
├── Services/
│   ├── TaskService.swift
│   ├── ProgressService.swift
│   └── NotificationService.swift
├── Data/
│   ├── Tasks.json
│   └── Badges.json
└── Resources/
    ├── Assets.xcassets
    └── Sounds/
```

### Data Storage

| Data | Storage |
|------|---------|
| User profile | UserDefaults |
| Progress (stardust, streak) | UserDefaults |
| Completed tasks | UserDefaults |
| Task content | JSON bundle |

### Dependencies

| Need | Solution |
|------|----------|
| Animations | SwiftUI native + Lottie (optional) |
| Haptics | UIImpactFeedbackGenerator |
| Notifications | UserNotifications framework |
| Sound effects | AVFoundation |

---

## Scientific Foundation

### Burnout Assessment
- Maslach Burnout Inventory (MBI) — gold standard, 35+ years of validation
- MBI-GS9 — 9-item short version, validated 2024

### Recovery Techniques
- **MBSR** (Mindfulness-Based Stress Reduction) — most evidence for burnout
- **CBT** (Cognitive Behavioral Therapy) — effective for reframing
- **Positive Psychology** — gratitude interventions
- **Behavioral Activation** — micro-actions for energy

### Gamification Research
- Micro-rewards increase adherence (90% in eQuoo study)
- Customization improves engagement
- Progress visualization motivates continued use

---

## Future Considerations

- AI-assisted personalized task generation
- CloudKit sync for multi-device
- Apple Watch companion
- Widgets for quick check-in
- Social features (optional accountability partners)
- Android version

---

## References

1. Maslach Burnout Inventory - Mind Garden
2. MBI-GS9 Validation Study (Frontiers in Psychology, 2024)
3. Effectiveness of Individual-Based Strategies to Reduce Nurse Burnout (2024)
4. Gamification in Mental Health Apps (BMC Public Health, 2023)
5. Recommendations for Implementing Gamification (Frontiers in Psychology, 2020)
