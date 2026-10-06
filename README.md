# CycleGo 🚲 — Campus Bike Rental Application

**CycleGo** is a modern, production-quality, cross-platform campus bicycle rental application built with **Flutter** and **Material 3** for a B.Tech CSE (AI) Cross Platform Application exam project.

It enables students and faculty to check real-time bike availability across campus docking stations, instantly reserve bicycles, track live rides with custom metrics, and return bikes to any station across campus with immediate state synchronization.

---

## 📱 Features

- 🗺️ **Live Station Map & List**: 8 realistic campus docking hubs with real-time bike counts, dock capacities, walking distances, and an interactive vector campus map.
- ⚡ **Instant State Reactivity (Provider)**: Real-time bike count decrementing on reservation and incrementing on return without manual refresh.
- 🚦 **Accessible Color Coding**:
  - 🟢 **Plenty (>= 5 bikes)**: Emerald Green with confirmation badge.
  - 🟡 **Low (1-4 bikes)**: Warm Amber with caution badge.
  - 🔴 **Empty (0 bikes)**: Red tint, distinct border, "Unavailable" badge, and disabled reservation buttons.
  - *Inclusive Design*: Multi-sensory cues (icons, badges, text labels) ensuring full accessibility without relying on color alone.
- 🔐 **Single-Active-Ride Rule**: Strict validation ensuring a student holds only one active reservation at a time.
- 🚴 **Reserve-Ride-Return Journey**:
  - **Step 1: Choose Station**: Filter by nearest, most bikes, or search by name.
  - **Step 2: Reserve**: Bike assignment & unlock PIN code generation with stepper cues.
  - **Step 3: Active Ride**: Real-time timer, speed/distance estimator, calorie & carbon emission calculations.
  - **Step 4: Flexible Return**: Drop off at **ANY** station with open docks.
- 💾 **Persistent Ride History**: Saves completed rides with date, duration, route, and eco-impact stats locally across restarts using `shared_preferences`.
- 🤖 **Live Campus Simulation**: Toggleable background simulator that mimics other students checking out/in bikes in real-time.
- 🌓 **Material 3 Theming**: Seamless Light & Dark mode support using custom `ThemeExtension<AvailabilityColors>`.
- 💻 **Cross-Platform Responsive**: Auto-adapts layout from phone single-column to wide-screen split-pane layout (NavigationRail + side-by-side live map & details).

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3.47+ (Dart 3.13+)
- **Design System**: Material 3 (`useMaterial3: true`)
- **State Management**: `Provider` (`MultiProvider`, `ChangeNotifier`, `Consumer`, `context.watch`)
- **Local Storage**: `shared_preferences` (JSON-encoded records)
- **Platforms**: Android, iOS, Web, macOS, Windows, Linux

---

## 📂 Project Structure

```
lib/
├── app.dart                       # Root MaterialApp with MultiProvider & NavigationRail shell
├── main.dart                      # App entrypoint and async storage initialization
├── models/
│   ├── active_ride.dart           # Active ride entity & serialization
│   ├── ride_record.dart           # Completed ride history model with formatted metrics
│   └── station.dart               # Campus docking station model & availability logic
├── providers/
│   ├── ride_history_provider.dart # Persistent ride history state & green campus analytics
│   ├── station_provider.dart      # Real-time station inventory, reservation/return rules & simulation
│   └── theme_provider.dart        # Light/Dark theme mode management and persistence
├── screens/
│   ├── active_ride_screen.dart    # Live ride ticker, trip metrics, and return modal
│   ├── reservation_screen.dart    # Station details, bike reservation pass, and unlock PIN
│   ├── ride_history_screen.dart   # Chronological trip history & eco impact summary
│   └── station_list_screen.dart   # Interactive campus map, station cards, search, & filters
├── services/
│   └── storage_service.dart       # SharedPreferences JSON persistence layer
├── theme/
│   ├── app_theme.dart             # Material 3 light/dark themes with emerald-teal seed
│   └── availability_colors.dart   # Custom ThemeExtension for status colors
└── widgets/
    ├── active_ride_banner.dart    # Pulsing banner for ongoing rides on home screen
    ├── availability_badge.dart    # Accessible status badge (color + icon + text)
    ├── campus_map_header.dart     # CustomPainter vector map of campus cycle lanes
    ├── progress_stepper.dart      # 4-step visual journey indicator
    ├── ride_card.dart             # Card widget for trip logs with route markers
    └── station_card.dart          # Station card with dock capacity bar & reserve CTA
```

---

## 🚀 Setup and Run Instructions

### Prerequisites
- Flutter SDK (version 3.20.0 or later)
- Dart SDK (version 3.4.0 or later)

### Installation
1. Clone the repository and navigate into the project directory:
   ```bash
   cd CrossPlatform_CycleGO_43_134
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run code analysis to verify cleanliness:
   ```bash
   flutter analyze
   ```
4. Run all unit and widget tests:
   ```bash
   flutter test
   ```
5. Run the application:
   - **Chrome / Web**:
     ```bash
     flutter run -d chrome
     ```
   - **macOS Desktop**:
     ```bash
     flutter run -d macos
     ```
   - **Mobile (Android/iOS)**:
     ```bash
     flutter run
     ```

---

## 🧪 Verification Matrix

| Acceptance Criterion | Verification Method | Status |
|---|---|---|
| Immediate station count decrement on reserve | `test/unit/station_provider_test.dart` & UI walk-through | ✅ Verified |
| Immediate station count increment on return | `test/unit/station_provider_test.dart` & UI walk-through | ✅ Verified |
| History shows pickup, return, duration | `test/unit/ride_history_provider_test.dart` & `RideCard` | ✅ Verified |
| Zero-bike stations highlighted in distinct color & disabled | `StationCard` + `AvailabilityColors` + Widget test | ✅ Verified |
| Station entries show name, distance, bike count | `StationCard` layout tests | ✅ Verified |
| Persistent history across app restarts | `StorageService` unit test + `SharedPreferences` mock | ✅ Verified |
| Material 3 Light/Dark theme with `ThemeExtension` | `AppTheme` + `AvailabilityColors` toggle | ✅ Verified |
| Phone & Desktop wide-screen responsiveness | `LayoutBuilder` with split-pane & NavigationRail | ✅ Verified |
| Cloud Firestore real-time sync & offline caching | `FirestoreService` with snapshot stream & metadata | ✅ Verified |
| Clean code analysis with zero lint warnings | `flutter analyze` | ✅ 0 issues |

---

## 📄 Documentation Artifacts
- **[JUSTIFICATION.md](file:///Users/rohansamanta/Desktop/CrossPlatform_CycleGO_43_134/JUSTIFICATION.md)**: Architectural & design rationale.
- **[FIGMA_SPEC.md](file:///Users/rohansamanta/Desktop/CrossPlatform_CycleGO_43_134/FIGMA_SPEC.md)**: Screen-by-screen Figma UI design tokens, components, and user flows.
- **[TEST_REPORT.md](file:///Users/rohansamanta/Desktop/CrossPlatform_CycleGO_43_134/TEST_REPORT.md)**: Comprehensive automated and manual test execution report.
