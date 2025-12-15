-- Enable Row Level Security on all tables
alter table if exists public.users enable row level security;
alter table if exists public.psychologists enable row level security;
alter table if exists public.bookings enable row level security;
alter table if exists public.mood_entries enable row level security;
alter table if exists public.conversations enable row level security;
alter table if exists public.messages enable row level security;

-- USERS policies
drop policy if exists users_select_own on public.users;
create policy users_select_own on public.users
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists users_insert_any on public.users;
create policy users_insert_any on public.users
  for insert
  to authenticated
  with check (true);

drop policy if exists users_update_any on public.users;
create policy users_update_any on public.users
  for update
  to authenticated
  using (auth.uid() = id)
  with check (true);

drop policy if exists users_delete_own on public.users;
create policy users_delete_own on public.users
  for delete
  to authenticated
  using (auth.uid() = id);

-- PSYCHOLOGISTS: allow all authenticated users to read; allow writes for authenticated as well
drop policy if exists psychologists_select_all on public.psychologists;
create policy psychologists_select_all on public.psychologists
  for select to authenticated using (true);

drop policy if exists psychologists_write_all on public.psychologists;
create policy psychologists_write_all on public.psychologists
  for all to authenticated using (true) with check (true);

-- BOOKINGS: only owners can access their rows
drop policy if exists bookings_owner_all on public.bookings;
create policy bookings_owner_all on public.bookings
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- MOOD ENTRIES: only owners can access their rows
drop policy if exists mood_entries_owner_all on public.mood_entries;
create policy mood_entries_owner_all on public.mood_entries
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- CONVERSATIONS: only owners can access
drop policy if exists conversations_owner_all on public.conversations;
create policy conversations_owner_all on public.conversations
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- MESSAGES: access limited to owner of the parent conversation
drop policy if exists messages_in_owner_conversation on public.messages;
create policy messages_in_owner_conversation on public.messages
  for all to authenticated
  using (
    exists(
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  )
  with check (
    exists(
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  );
