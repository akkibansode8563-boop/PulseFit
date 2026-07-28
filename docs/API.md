# API & Remote Service Specifications: AI Health Manager

## 1. Supabase Backend Integration

### Authentication Endpoints
- `signUpWithEmail(email, password)` -> `Result<AuthResponse>`
- `signInWithEmail(email, password)` -> `Result<AuthResponse>`
- `signOut()` -> `Result<void>`

### Database Operations (PostgreSQL + RLS)
- All table interactions (`profiles`, `vitals`, `meals`, `workouts`, `sleep`, `medical_records`) automatically inject `auth.uid()` for strict row-level security.

---

## 2. AI Engine Specifications (Provider-Agnostic)

### `IAIService` Interface
```dart
abstract class IAIService {
  Future<Result<String>> generateHealthAdvice({
    required UserProfile profile,
    required List<VitalRecord> vitals,
    required List<MealRecord> meals,
    required String userQuery,
  });

  Future<Result<MealAnalysis>> analyzeFoodImage({
    required String imagePath,
  });

  Future<Result<DocumentAnalysis>> analyzeMedicalDocument({
    required String imagePath,
  });
}
```

### OpenAI Implementation (`OpenAIProvider`)
- Model: `gpt-4o` (multimodal vision + text)
- Base URL: Read dynamically from `.env`
- Fallback / Retries: Exponential backoff with rate limit handling
