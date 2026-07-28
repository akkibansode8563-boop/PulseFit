# System Architecture Document: AI Health Manager

## 1. Overview & Clean Architecture Design
**AI Health Manager** follows **Clean Architecture** combined with a **Feature-First** structure. Code is organized into feature domains under `lib/features/<feature>/` and shared core services under `lib/core/`.

```
lib/
├── core/
│   ├── config/       # Environment configs (.env)
│   ├── constants/    # Global constants & keys
│   ├── errors/       # Result<T> and Failure hierarchy
│   ├── services/     # Connectivity, Storage, Biometrics
│   ├── theme/        # Material 3 tokens & AppTheme
│   └── utils/        # Date, math, isolate helpers
├── features/
│   ├── authentication/
│   ├── dashboard/
│   ├── nutrition/
│   ├── water/
│   ├── sleep/
│   ├── workout/
│   ├── steps/
│   ├── medical/
│   ├── habits/
│   ├── ai/
│   └── profile/
└── shared/
    └── widgets/      # Shared 6-state UI widgets & shimmers
```

---

## 2. Layer Separation
- **Domain Layer (`domain/`):** Pure Dart entities, repository contracts, and use cases.
- **Data Layer (`data/`):** Repositories implementation, Supabase remote data sources, Drift local data sources, DTOs, and sync queue bindings.
- **Presentation Layer (`presentation/`):** Riverpod Providers (`AsyncNotifier` / `Notifier`), Material Design 3 screens, and UI state management.

---

## 3. Provider-Agnostic AI Architecture
The AI engine connects via an abstract interface `IAIService`:
```
IAIService -> OpenAIProvider (Current)
           -> Future: GeminiProvider, ClaudeProvider, LocalLLMProvider
```
This enables seamless switching between remote multimodal models and local LLMs without modifying business logic.
