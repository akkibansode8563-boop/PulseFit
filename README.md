# PulseFit — AI Health Manager & Nutrition Vision Engine

PulseFit is an enterprise-grade, offline-resilient AI Health Manager Flutter application designed for personalized health tracking, smart workout routines, water & sleep monitoring, and high-accuracy AI food recognition.

---

## 🌟 Key Features

* **📷 AI Food Recognition Engine**: High-accuracy food scanner (`gpt-4o-mini` Vision) with pre-calibrated regional Indian food density database (`RegionalFoodDatabase`).
* **🛡️ Production Offline & Quota Resilience**: Automatic fallback to local feature matching when internet or cloud API quotas are unavailable.
* **🔑 Secure API Key Management**: On-device key storage via `ApiKeyStorageService` with zero hardcoded secret assets in binary builds.
* **📊 Macro & Health Dashboards**: Real-time calorie, protein, carbs, fat, fiber, and sugar tracking with interactive portion adjustments.
* **💪 AI Reasoning & Personalized Routines**: BMR/TDEE calculation via Mifflin-St Jeor equation and health-condition-aware workout plans.
* **🔔 Lockscreen Notifications**: High-priority water and medicine reminders for Android 13+ (API 33+).

---

## 🚀 Quick Start Guide

### 1. Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19.0 or higher)
* Android Studio / VS Code with Dart & Flutter extensions

### 2. Installation
```bash
git clone https://github.com/akkibansode8563-boop/PulseFit.git
cd PulseFit
flutter pub get
```

### 3. API Key Configuration
PulseFit does **not** bundle API secrets in shipped application binaries. 
1. Run the app on your emulator or device:
   ```bash
   flutter run
   ```
2. Navigate to **Profile & Goals → AI Vision Key Settings**.
3. Paste your OpenAI API Key (starts with `sk-`) obtained from [platform.openai.com/api-keys](https://platform.openai.com/api-keys).
4. Tap **Save Key**. The key is stored securely on-device for future sessions.

---

## 📐 Architecture & Project Map

```
lib/
├── core/
│   ├── error/            # AppException hierarchy & ErrorPresenter
│   ├── services/         # OpenAIServiceImpl, ApiKeyStorageService, VisionHttpClient
│   └── theme/            # AppColors, AppTheme, ThemeProvider
├── features/
│   ├── nutrition/        # AI Food Scanner, RegionalFoodDatabase, FoodAnalysisMapper
│   ├── profile/          # UserProfile, AI Reasoning Engine, Settings Entry
│   ├── settings/         # ApiKeySettingsScreen
│   ├── workout/          # GPS Activity Tracker, Exercises & Routines
│   └── water/            # Hydration Gauge & Reminders
└── main.dart             # Application Entry Point
```

---

## 🧪 Running Tests & Audit Benchmarks

Run unit and integration test suites:
```bash
flutter test
```

Run the 1,000 Food Accuracy Benchmark test:
```bash
flutter test test/features/nutrition/food_engine_1000_benchmark_test.dart
```

---

## 📄 Error Handling Documentation
See [docs/error-handling.md](docs/error-handling.md) for exception classification rules and UI message formatting guidelines.
