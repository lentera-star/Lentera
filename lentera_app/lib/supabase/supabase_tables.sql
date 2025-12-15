-- Enable required extension for UUID generation
create extension if not exists pgcrypto;

-- USERS TABLE (app profile) — references auth.users
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

create index if not exists idx_users_email on public.users (email);

-- PSYCHOLOGISTS
create table if not exists public.psychologists (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialization text not null,
  price_per_session integer not null,
  is_available boolean not null default true,
  photo_url text,
  bio text,
  rating numeric(3,2) not null default 4.5,
  created_at timestamptz not null default now(),
  constraint uq_psychologists_name unique (name)
);

create index if not exists idx_psychologists_available on public.psychologists (is_available);
create index if not exists idx_psychologists_rating on public.psychologists (rating desc);

-- BOOKINGS
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  psychologist_id uuid not null references public.psychologists(id) on delete cascade,
  start_time timestamptz not null,
  end_time timestamptz not null,
  platform text not null default 'video_call',
  price integer not null,
  admin_fee integer,
  status text not null default 'upcoming',
  notes text,
  rating numeric(3,2),
  review text,
  created_at timestamptz not null default now()
);

create index if not exists idx_bookings_user on public.bookings (user_id);
create index if not exists idx_bookings_psych on public.bookings (psychologist_id);
create index if not exists idx_bookings_start on public.bookings (start_time);

-- MOOD ENTRIES
create table if not exists public.mood_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  mood_rating integer not null,
  mood_tags text[] not null default '{}',
  journal_text text,
  audio_url text,
  transcription text,
  created_at timestamptz not null default now()
);

create index if not exists idx_mood_entries_user on public.mood_entries (user_id);
-- Use immutable cast to date for index
create index if not exists idx_mood_entries_created_date on public.mood_entries ((created_at::date));

-- CONVERSATIONS (AI chat sessions)
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  updated_at timestamptz not null default now()
);

create index if not exists idx_conversations_user on public.conversations (user_id);
create index if not exists idx_conversations_updated on public.conversations (updated_at desc);

-- MESSAGES (chat messages)
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null,
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_messages_conversation on public.messages (conversation_id);
create index if not exists idx_messages_created on public.messages (created_at);

-- OPTIONAL: Clean up legacy columns to avoid NOT NULL conflicts (safe no-ops if absent)
do $$ begin
  if exists(
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'psychologists' and column_name = 'price'
  ) then
    alter table public.psychologists drop column if exists price;
  end if;
end $$;
