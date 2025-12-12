# Assessment UX Improvements Design

**Date:** 2025-12-12
**Status:** Approved

## Overview

A felhasználói tesztelés alapján 5 fő problémát azonosítottunk az assessment és onboarding flow-ban. Ez a dokumentum tartalmazza a jóváhagyott design döntéseket.

## Problémák

1. Assessment kérdések közötti átmenet nem egyértelmű
2. Next gomb felesleges (auto-advance mellett)
3. See Results gomb túl korán jelenik meg
4. Results screen-en nincs értékelés/motiváció
5. Home screen üres - 0/0 tasks bug + hiányzó first-time experience

---

## 1. Assessment UX javítások

### Kiválasztás feedback (Subtle & Calm)

- Gomb kiválasztásakor: scale animáció (1.0 → 1.03 → 1.0) + háttérszín váltás
- Checkmark ikon megjelenik a kiválasztott opción (fade in)
- 0.6 másodperc várakozás az auto-advance előtt

### Átmenet kérdések között

- Jelenlegi kérdés fade out + enyhe balra slide
- Új kérdés fade in + jobbról slide
- Progress bar animáltan növekszik

### Navigáció

- ❌ **Next gomb eltávolítva** (auto-advance van)
- ✅ **Back gomb marad**

### Utolsó kérdés

- Válasz kiválasztása után 0.6s delay
- "See Results" gomb fade in + scale animációval jelenik meg
- Gomb azonnal kattintható (nem disabled állapotban jelenik meg)

---

## 2. Results Screen (Assessment után)

### Celebratory effect

- Sparkle/stardust animáció a képernyő tetején
- "First Step Complete" badge megjelenik
- Haptic feedback (opcionális)

### Burnout értékelés

Az assessment válaszok alapján 3 szint egyike:

| Szint | Score | Üzenet |
|-------|-------|--------|
| Enyhe | Alacsony | "Jó úton vagy - megelőzés módban" |
| Közepes | Közepes | "Figyelj magadra - ideje lassítani" |
| Erős | Magas | "Támogatásra van szükséged - lépésről lépésre" |

### Személyre szabott üzenet

A választott `situation` és `goal` alapján generált szöveg, pl:
> "Azt mondtad, hogy érzelmileg kimerültnek érzed magad, és szeretnéd visszanyerni az energiádat. Kis lépésekkel fogunk haladni."

### Mi fog történni - előnézet

- Pace megjelenítése: "Napi [1/2/3] kis feladat vár rád"
- Task kategóriák előnézete ikonokkal:
  - 🫁 Légzés (breathe)
  - 💭 Reflexió (reflect)
  - 🙏 Hála (gratitude)
  - 🚶 Mozgás (move)
  - 🧘 Tudatosság (mindful)
- "Bármikor állíthatod a tempót a beállításokban"

### CTA gomb

"Kezdjük el" / "Begin Your Journey"

---

## 3. Home Screen javítások

### Első alkalom (onboarding után)

- Welcome banner a tetején:
  > "Üdv, [név]! Itt az első task-od."
- Egy task azonnal megjelenik (a pace szerinti mennyiség)
- Banner eltűnik a task elvégzése után (vagy swipe to dismiss)

### Üres lista kezelése

Két eset:
1. **Este regisztráció** - nincs még task
2. **Minden task kész** - nap végén

Megoldás:
```
"Ma készen vagy! 🌟"
"Szeretnél még egyet kipróbálni?"
[Igen, mutass egyet] [Nem, pihenek]
```

- **"Igen"** → random bonus task jelenik meg (+stardust jutalom)
- **"Nem"** → motivációs üzenet: "Holnap új feladatok várnak. Pihenj jól!"

### Technikai bug fix

- `TaskService.generateDailyTasks()` hívása az onboarding UTÁN (nem app indulásakor)
- Ellenőrzés: ha `dailyTasks.isEmpty` és `allTasks` nem üres → újragenerálás
- Race condition fix: várni kell amíg a pace beállításra kerül

---

## Érintett fájlok

- `Views/Onboarding/AssessmentView.swift` - UX javítások
- `Views/Onboarding/OnboardingCoordinator.swift` - Results screen bővítés
- `Views/Home/HomeView.swift` - Welcome banner, empty state
- `Services/TaskService.swift` - Bug fix, generateDailyTasks timing
- `Models/Assessment.swift` - Burnout level calculation
- `Components/ChoiceButton.swift` - Selection animation

---

## Implementation Notes

- SwiftUI animációk: `.animation(.spring())`, `.transition()`
- Haptic: `UIImpactFeedbackGenerator`
- Assessment score calculation: már létezik `Assessment.calculatePace()`, bővíteni kell burnout level-lel
