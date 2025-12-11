/* DATABASE_SCHEMA.sql */
/* Target: PostgreSQL (Supabase) */

-- 1. USERS
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. MOOD TRACKER
CREATE TABLE public.mood_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    mood_score INTEGER CHECK (mood_score BETWEEN 1 AND 5), -- 1: Sad, 5: Happy
    journal_text TEXT,
    audio_path TEXT, -- Path to Supabase Storage bucket
    transcription TEXT, -- Result from Whisper AI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CHAT HISTORY (AI)
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CONSULTATION (Psychologist)
CREATE TABLE public.psychologists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    title VARCHAR(100), -- e.g., "M.Psi, Psikolog"
    bio TEXT,
    price INTEGER NOT NULL, -- in IDR
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id),
    psychologist_id UUID REFERENCES public.psychologists(id),
    status VARCHAR(20) CHECK (status IN ('pending', 'paid', 'completed', 'cancelled')),
    session_time TIMESTAMP WITH TIME ZONE,
    payment_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);