# Architectural & Design Decisions: Justification Report

**Course**: B.Tech Computer Science & Engineering (AI)  
**Project**: CycleGo — Cross-Platform Campus Bike Rental System  

This document articulates and justifies the core engineering, state management, UI/UX, accessibility, and storage decisions made in building **CycleGo**.

---

## 1. State Management: Why Provider?

### Evaluation against Alternatives
1. **Provider (`ChangeNotifier`, `MultiProvider`, `Consumer` / `context.watch`)**:
   - **Lightweight & Official Recommendation**: Endorsed by the Flutter team as an idiomatic approach for reactive applications.
   - **Optimal Complexity-to-Scale Ratio**: For an on-device campus cycle system requiring immediate inventory synchronization and active ride timers, Provider offers low boilerplate and high testability without the heavy boilerplate of Bloc (events, states, transformers) or Riverpod's external container generation.
   - **Surgical Rebuilds**: By utilizing targeted `Consumer<T>` and `Selector<T, R>` alongside `context.watch<T>()` at leaf widgets, only widgets displaying mutated station counts or live timer seconds re-render, preserving a 60/120 FPS render pipeline.

2. **Why not BLoC/Cubit?**:
   - While BLoC is well-suited for enterprise applications with deeply nested asynchronous streams, it introduces substantial ceremony (Event-State mapping, complex transitions) that obscures the core business rules of this project.

3. **Why not Riverpod?**:
   - Riverpod requires global providers and consumer widgets (`ConsumerWidget`, `WidgetRef`), deviating from standard Flutter widget hierarchies and adding external abstractions unnecessary for exam-scoped single-app projects.

---

## 2. Local Storage: Why SharedPreferences with JSON?

### Evaluation against Alternatives
1. **`shared_preferences` with JSON encoding**:
   - **Cross-Platform Parity**: Runs seamlessly out of the box on Android (`SharedPreferences`), iOS (`NSUserDefaults`), Web (`localStorage`), and Desktop (file-backed key-value store) without platform channel configuration.
   - **Zero Backend Footprint**: Eliminates external server dependencies, network latency, and authentication overhead, making the exam application completely offline-first and self-contained.
   - **Data Volume Fit**: Campus rental history for an individual user comprises lightweight structured logs (dozens to hundreds of records), which serialize to compact JSON payloads (< 50 KB), well within optimal memory thresholds.

2. **Why not SQLite / Hive / Isar?**:
   - Relational tables or binary databases add native build toolchain dependencies (e.g. SQLite C binaries, build_runner code generation) that increase build times and introduce potential platform compilation friction without tangible performance gains for this data scale.

---

## 3. UI Framework & Design System: Why Material 3?

- **Modern Visual Standards**: Enables `useMaterial3: true` with dynamic color palettes generated via `ColorScheme.fromSeed(seedColor: Color(0xFF00897B))`.
- **Component Evolution**: Leverages updated Material 3 widgets:
  - `NavigationBar` (replacing deprecated `BottomNavigationBar`) with pill indicator animations.
  - `NavigationRail` for wide-screen tablet and desktop environments.
  - `FilledButton` and `FilledButton.tonal` for distinct visual hierarchy.
  - `FilterChip` and `InputChip` for intuitive one-tap station filtering.
  - `Card` shapes with customizable outlines and subtle elevation.

---

## 4. Color-Coding & Accessibility (a11y) Justification

### Multi-Sensory Dual Encoding
Relying solely on color creates barriers for users with color vision deficiencies (e.g., Deuteranopia or Protanopia). CycleGo implements strict **dual encoding**:

| State | Threshold | Visual Color | Icon Cue | Textual Label | Assistive Semantic |
|---|---|---|---|---|---|
| **Plenty** | $\ge 5$ bikes | Emerald Green (`#15803D`) | `Icons.check_circle_rounded` | "Plenty (X available)" | "Station status: X Available" |
| **Low** | $1 - 4$ bikes | Amber Gold (`#D97706`) | `Icons.warning_amber_rounded` | "Low Stock (X left)" | "Station status: Low Stock (X left)" |
| **Empty** | $0$ bikes | Crimson Red (`#DC2626`) | `Icons.block_rounded` | "Unavailable (0 bikes)" | "Station status: Unavailable" |

### ThemeExtension Architecture
Rather than hardcoding colors inside widget build methods, `AvailabilityColors extends ThemeExtension<AvailabilityColors>` is defined with dedicated light and dark luminance pairings. This ensures consistent contrast ratios ($\ge 4.5:1$ against backgrounds conforming to WCAG AA guidelines).

---

## 5. Single-Active-Ride Rule Justification

- **Physical & Operational Realism**: A single student can physically ride only one bicycle at a time.
- **Anti-Hoarding Guardrail**: Prevents resource monopolization on campus docking stations where supply is limited.
- **Deterministic State Machine**: Simplifies active timer tracking, GPS/route calculation, and return validation to a single active ride session.

---

## 6. Project Architecture & Layer Separation

```
Presentation Layer (Screens & Widgets)
          ↓ (watches / reads)
Business Logic Layer (Providers: StationProvider, RideHistoryProvider, ThemeProvider)
          ↓ (calls)
Data Access Layer (StorageService: SharedPreferences JSON Engine)
          ↓ (serializes / deserializes)
Domain Models (Station, ActiveRide, RideRecord)
```

- **Separation of Concerns**: UI widgets contain zero storage logic; providers contain zero raw file handling.
- **Testability**: Providers can be unit-tested in complete isolation by injecting a mock or in-memory `StorageService`.
- **Responsiveness**: `LayoutBuilder` splits layout dynamically between compact (phone) and expanded (tablet/desktop) viewports without breaking UI state or remounting providers.
