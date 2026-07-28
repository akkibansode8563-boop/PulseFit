# Product Requirements Document (PRD): AI Health Manager

## 1. Executive Summary
**AI Health Manager** (`ai_health_manager`) is an enterprise-grade, offline-first mobile application designed to act as the world's smartest personal AI Healthcare Manager. It functions as an AI Nutritionist, AI Fitness Coach, AI Health Advisor, AI Habit Coach, AI Sleep Coach, AI Water Reminder, AI Workout Planner, AI Medical Record Manager, AI Daily Planner, and AI Accountability Partner.

---

## 2. Core Objectives & Features
- **Nutrition AI:** Food image recognition, barcode scanning, calorie counter, protein/carb/fat macro estimation, micronutrient tracking.
- **Water AI:** Smart adaptive hydration reminders, daily intake tracking.
- **Workout AI:** Adaptive workout planning, exercise logger, sets/reps/weight progressive overload tracking, recovery score.
- **Sleep AI:** Sleep tracking, recovery analysis, smart alarm recommendations.
- **Medical Records & Habits:** Medical document scanner, medicine reminders, mood tracker, body measurements log.
- **AI Coach & Analytics:** Multimodal AI chat (OpenAI API with abstraction for Gemini, Claude, Local LLMs), health score, 60-120 FPS charts (`fl_chart`).

---

## 3. UI/UX & State Architecture (6 Core States)
1. **Success:** Rendered interactive UI.
2. **Loading:** Shimmer / skeleton loaders (NO blank screens).
3. **Empty:** Actionable fallback UI with clear CTAs.
4. **Error:** User-friendly message with "Retry" action.
5. **Offline Mode:** Banner indicating cached offline active state.
6. **Retry:** Re-execution logic for failed network/data requests.

---

## 4. Non-Functional & Security Requirements
- **Performance Target:** 60–120 FPS (heavy computations offloaded to background isolates).
- **Offline-First:** SQLite / Drift local database with background `SyncQueue` and conflict resolution.
- **Security:** Strict Supabase Row-Level Security (`auth.uid() = user_id`), environment variable secrets (`.env`), biometric fallback support.
- **Modularity:** Under 250 lines per file where practical; Clean Architecture + Feature-First design.
