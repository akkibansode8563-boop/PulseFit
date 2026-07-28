# Database Schema & Synchronization Specification

## 1. Overview
**AI Health Manager** utilizes a dual-database architecture:
1. **Remote Backend:** PostgreSQL managed by Supabase with Row-Level Security (RLS).
2. **Local Offline DB:** SQLite managed by Drift with background sync queueing.

---

## 2. Remote PostgreSQL Schema (Supabase)

### Table: `profiles`
```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    date_of_birth DATE,
    gender TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access own profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);
```

### Table: `vitals`
```sql
CREATE TABLE public.vitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- blood_pressure, heart_rate, glucose, weight, etc.
    value_numeric DOUBLE PRECISION,
    value_text TEXT,
    unit TEXT,
    measured_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.vitals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access own vitals" ON public.vitals
    FOR ALL USING (auth.uid() = user_id);
```

---

## 3. Local SQLite Schema (Drift)

### Table: `LocalVitals`
- `id`: Text (UUID) - Primary Key
- `userId`: Text
- `type`: Text
- `valueNumeric`: Real (Nullable)
- `valueText`: Text (Nullable)
- `unit`: Text
- `measuredAt`: DateTime
- `isSynced`: Bool (Default: false)

### Table: `SyncQueue`
- `id`: Integer (Auto Increment) - Primary Key
- `table`: Text
- `recordId`: Text
- `operation`: Text (INSERT, UPDATE, DELETE)
- `payloadJson`: Text
- `attempts`: Integer (Default: 0)
- `lastError`: Text (Nullable)
- `createdAt`: DateTime
