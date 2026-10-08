# Tamir Family Wellbeing 🌿

An iPhone app (SwiftUI + SwiftData, iOS 17+) for the two Tamir parents to track daily wellbeing habits, see a weekly summary, mark treat days and follow their weight.

## Easiest way: the web version (no Mac needed)

`web/index.html` is the same tracker as a web page, published at
https://claude.ai/artifact/8ChtkbhrfAMwaxJrszqd73. Open the link in Safari on the iPhone,
tap **Share → Add to Home Screen**, and it opens like an app. Entries are saved online, so both
parents see the same data once the page is shared with the second parent as an Editor.

The native iPhone app below needs a Mac with Xcode to install.

## Features

**Two parents, one app.** Switch between parents with the segmented control at the top of each screen. Names are editable in Settings.

**Daily log (Today tab).** Each item can be logged for today or any earlier day:

| Area | What you track |
|---|---|
| Food & drink | 💧 Water (liters) · 🥕 Meals with vegetables · 🍎 Fruit servings · 🍞 Carbs level (Low / Moderate / High) · 🍬 Sweets & sugary drinks |
| Sleep | 🛏 Hours slept · 😴 Sleep quality (1–5) |
| Movement | 🏃 Exercise minutes · 👣 Steps |
| Mind | 🙂 Mood · ⚡️ Energy · 😟 Stress (1–5) · 🍃 Mindfulness / quiet time |
| Other | 🍰 **Treat day** toggle · ⚖️ Weight · 📝 Notes |

A green check appears next to an item when that day's goal is met.

**Week summary (Week tab).**
- A 7‑day strip showing which days were logged and which were treat days 🍰
- How many days each goal was reached (water, veggies, sleep, exercise, steps)
- A daily bar chart (Water / Sleep / Veggies / Exercise / Steps) with a goal line; treat days show in pink
- Totals and averages for every metric, including the week's weight change
- A **Family this week** table that compares both parents side by side

**Weight (Weight tab).** Add a weigh-in for any date, see current, starting and total change, a trend chart, and the full history with the change between weigh-ins. Swipe a row to delete it.

**Settings.** Parent names and daily goals (defaults: 2.5 L water, 3 veggie meals, 7 h sleep, 30 min exercise, 8,000 steps).

## Running it on your iPhone

The project is a Swift Playgrounds **App** package (`TamirWellbeing.swiftpm`), so you don't need to create an Xcode project.

**With a Mac (Xcode 15 or later):**
1. Clone this repository and open the `TamirWellbeing.swiftpm` folder in Xcode (File → Open).
2. Connect your iPhone, or pick it as a wireless run destination, and select it at the top of the window.
3. In the *Signing & Capabilities* settings for the app, choose your Apple ID team. A free Personal Team works.
4. Press ▶︎ Run. The first time, confirm the developer on the iPhone in *Settings → General → VPN & Device Management*.

**With an iPad or Mac using Swift Playgrounds:** open `TamirWellbeing.swiftpm` in Swift Playgrounds and tap Run.

> With a free Apple ID, apps installed from Xcode stop opening after 7 days and need to be run from Xcode again. With a paid Apple Developer account ($99/year), you can share the app with both parents through TestFlight.

## Data & privacy

All data is stored on the device with SwiftData. Nothing is sent anywhere. Both parents log on the same phone using the parent switcher.

## Project layout

```
TamirWellbeing.swiftpm/
├── Package.swift            # App settings (name, bundle id, icon, iOS version)
├── TamirWellbeingApp.swift  # App entry point + SwiftData container
├── Models/
│   ├── DailyEntry.swift     # One day of tracking for one parent
│   ├── WeekStats.swift      # Weekly averages / totals
│   └── Settings.swift       # Goal defaults, storage keys, date helpers
└── Views/
    ├── ContentView.swift    # Tabs, parent picker, date stepper
    ├── TodayView.swift      # Daily log form
    ├── WeekView.swift       # Weekly summary, charts, family comparison
    ├── WeightView.swift     # Weight tracking
    └── SettingsView.swift   # Names and goals
```

## Ideas for next versions

- Sync between both parents' phones (iCloud / CloudKit sharing)
- Reminders (e.g. "drink water" or "log your day")
- Import steps, sleep and weight from Apple Health
