# QR Code Generator - Flutter Application
**Task 1 — Auspify Technologies Practical Training Program**

A single-screen Flutter application engineered with **Clean Architecture** and **Cubit State Management** (`flutter_bloc`). The app generates crisp standard QR codes from user text or URLs, saves them to the device's local gallery, and shares them via the native OS share sheet. It operates completely **offline** without external databases or network calls.

---

## ✨ Features & Requirements

- **Instant QR Code Generation**: Converts text or URLs into standard black-and-white QR codes using `qr_flutter`.
- **Save to Gallery**: Captures the rendered QR code as a bitmap via `RepaintBoundary` and saves it to the device photo library using `image_gallery_saver`.
- **Native Sharing**: Exports the QR code image to the device's temporary cache (`path_provider`) and launches the native system share sheet via `share_plus`.
- **Exclusively Light Mode**: Clean, eye-friendly, professional Light Mode design avoiding dark mode as required.
- **Robust Error Handling**:
  - Validation SnackBar for empty inputs.
  - Graceful handling of storage permission denials with user feedback.
  - Non-blocking asynchronous loading states to prevent double-click race conditions.
- **Responsive Layout**: Designed for seamless adaptation across various device dimensions with no keyboard overflow.

---

## 🏛️ System Architecture

The project strictly follows **Clean Architecture** principles to cleanly decouple the presentation layer from business logic and platform-specific data sources:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Palette for eye-friendly Light Mode
│   │   ├── app_dimensions.dart      # Spacing and sizing tokens
│   │   └── app_strings.dart         # Centralized user strings & error messages
│   ├── errors/
│   │   ├── exceptions.dart          # Data-layer exceptions
│   │   └── failures.dart            # Domain-level failure types
│   ├── theme/
│   │   └── app_theme.dart           # Light Material 3 ThemeData configuration
│   └── utils/
│       ├── qr_image_capturer.dart   # RepaintBoundary-to-PNG byte converter
│       └── result.dart              # Sealed Result container for functional errors
├── features/
│   └── qr_generator/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── qr_local_data_source.dart  # Platform channels (gallery, cache, share)
│       │   └── repositories/
│       │       └── qr_repository_impl.dart    # Implements domain repository contract
│       ├── domain/
│       │   └── repositories/
│       │       └── qr_repository.dart         # Pure Dart repository interface
│       └── presentation/
│           ├── cubit/
│           │   ├── qr_cubit.dart              # Cubit business logic (Generate, Save, Share)
│           │   └── qr_state.dart              # Sealed states (Initial, Success, Error, Feedback)
│           ├── pages/
│           │   └── qr_home_page.dart          # Single home screen with BlocConsumer
│           └── widgets/
│               ├── qr_action_buttons.dart     # Save & Share action buttons
│               ├── qr_display_card.dart       # RepaintBoundary & QrImageView card
│               └── qr_input_section.dart      # Input field & Generate button
└── main.dart                                  # Dependency composition root
```

---

## ⚡ State Management Flow (Cubit)

The state is managed using `QrCubit` with the following sealed states:
- `QrInitial`: Initial state before any generation.
- `QrGeneratedSuccess`: QR code successfully displayed; tracks `isSaving` and `isSharing` flags.
- `QrFeedbackSuccess`: Transient state for positive feedback (SnackBar) without tearing down the QR code.
- `QrError`: Transient state for validation, permission, or platform errors.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.13.0` (Dart `^3.13.0`)
- Android Studio / VS Code with Flutter extension
- Android SDK (API 21+) or iOS 12+

### Installation & Run
```bash
# Clone the repository
git clone <repository-url>
cd qr_generator_app

# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run the app on an emulator or physical device
flutter run
```

---

## 🧪 Testing Suite
16 comprehensive automated unit and widget tests are included:
- **Cubit Tests**: Valid generation, empty input validation, asynchronous saving/sharing state transitions, permission denial handling.
- **Repository Tests**: Result wrapping, exception mapping to `Failure` types.
- **Widget Tests**: Rendering of initial state, empty-input SnackBar appearance, dynamic display of QR card and action buttons upon input.

Run tests anytime with:
```bash
flutter test
```
