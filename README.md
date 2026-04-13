# Utility Hub

A smart everyday toolkit mobile app built with Flutter — providing essential utility tools in a single, polished application.

## Features

### 1. Unit Converter
- **Length** — Meter, Kilometer, Centimeter, Mile, Foot, Inch
- **Weight** — Kilogram, Gram, Pound, Ounce
- **Temperature** — Celsius, Fahrenheit, Kelvin
- **Currency** — USD, EUR, GBP, NGN, KES, JPY, CAD, AUD (live rates with fallback)

### 2. Notes
- Create, edit, and delete notes
- Pin/unpin important notes
- Search notes by title or content
- Persistent local storage with Hive
- Swipe-to-delete with confirmation
- Sorted by pinned status and last updated

### 3. BMI Calculator
- Height (cm) and Weight (kg) input with validation
- BMI result with category classification
- Visual BMI scale indicator
- Health interpretation feedback

### 4. Tip Calculator
- Bill amount input
- Adjustable tip percentage with slider and quick-select chips
- Split bill between multiple people
- Real-time calculation with result breakdown

### Additional Features
- **Splash Screen** — Animated branded intro
- **Dark/Light/System Theme** — Toggle with persistence
- **Material 3 Design** — Clean, modern UI

## Architecture

```
lib/
  app/                          # App-level config
    app.dart                    # Root widget
    routes.dart                 # GoRouter navigation
    theme/
      app_theme.dart            # Material 3 light/dark themes

  features/                     # Feature-based modules
    home/
      presentation/
        home_screen.dart

    unit_converter/
      data/
        currency_service.dart   # Live exchange rate API + fallback
      domain/
        conversion_model.dart   # Unit data models
        converter_utils.dart    # Conversion logic
      presentation/
        converter_provider.dart # Riverpod state management
        unit_converter_screen.dart

    notes/
      data/
        notes_repository.dart   # Hive persistence layer
      domain/
        note_model.dart         # Note data model
      presentation/
        notes_provider.dart     # Riverpod state management
        notes_screen.dart
        note_editor_screen.dart

    bmi/
      domain/
        bmi_calculator_service.dart  # BMI calculation logic
      presentation/
        bmi_screen.dart

    tip_calculator/
      domain/
        tip_calculator_service.dart  # Tip calculation logic
      presentation/
        tip_calculator_screen.dart

    splash/
      presentation/
        splash_screen.dart      # Animated splash intro

  core/
    providers/
      theme_provider.dart       # Theme mode persistence

  main.dart                     # Entry point
```

**Key patterns:**
- **Feature-first folder structure** with data/domain/presentation layers
- **Riverpod** for state management
- **GoRouter** for declarative navigation
- **Hive** for local persistence
- Business logic separated from UI widgets

## Tech Stack

| Category         | Choice             |
|------------------|--------------------|
| Framework        | Flutter            |
| State Management | Riverpod           |
| Navigation       | GoRouter           |
| Local Storage    | Hive               |
| HTTP Client      | http               |
| Typography       | Google Fonts       |
| Design System    | Material 3         |

## Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / Xcode (for emulators)

### Setup

```bash
git clone https://github.com/NjengaC/UTILITY_HUB.git
cd UTILITY_HUB
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.
