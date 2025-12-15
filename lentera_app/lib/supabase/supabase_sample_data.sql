-- Helper function to insert users into auth.users and auth.identities tables
CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert data into the 'users' table
-- Reference existing user 'lenteraina2025@gmail.com'
INSERT INTO public.users (id, email, full_name, avatar_url, created_at)
SELECT
  (SELECT id FROM auth.users WHERE email = 'lenteraina2025@gmail.com'),
  'lenteraina2025@gmail.com',
  'Lentera Ina',
  'https://example.com/avatars/lentera.jpg',
  '2023-05-03 19:41:43.580424+00'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'lenteraina2025@gmail.com');

-- Create a new user for demonstration purposes
SELECT insert_user_to_auth('john.doe@example.com', 'securepassword123');

INSERT INTO public.users (id, email, full_name, avatar_url, created_at)
SELECT
  (SELECT id FROM auth.users WHERE email = 'john.doe@example.com'),
  'john.doe@example.com',
  'John Doe',
  'https://example.com/avatars/john_doe.jpg',
  '2023-06-01 10:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'john.doe@example.com');

-- Insert data into the 'mood_entries' table
INSERT INTO public.mood_entries (user_id, mood_rating, mood_tags, journal_text, audio_url, transcription, created_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com'),
  4,
  ARRAY['happy', 'productive'],
  'Today was a good day, felt very productive and achieved my goals.',
  'https://example.com/audio/mood1.mp3',
  'Today was a good day, felt very productive and achieved my goals.',
  '2023-05-04 09:00:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'lenteraina2025@gmail.com');

INSERT INTO public.mood_entries (user_id, mood_rating, mood_tags, journal_text, audio_url, transcription, created_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com'),
  2,
  ARRAY['stressed', 'tired'],
  'Feeling overwhelmed with work, need a break.',
  'https://example.com/audio/mood2.mp3',
  'Feeling overwhelmed with work, need a break.',
  '2023-05-05 14:30:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'lenteraina2025@gmail.com');

INSERT INTO public.mood_entries (user_id, mood_rating, mood_tags, journal_text, audio_url, transcription, created_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'john.doe@example.com'),
  3,
  ARRAY['neutral', 'thoughtful'],
  'Reflecting on recent events, trying to find clarity.',
  'https://example.com/audio/mood3.mp3',
  'Reflecting on recent events, trying to find clarity.',
  '2023-06-02 11:00:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'john.doe@example.com');

-- Insert data into the 'psychologists' table
INSERT INTO public.psychologists (name, specialization, price_per_session, is_available, photo_url, bio, rating) VALUES
('Dr. Sarah Chen', 'Cognitive Behavioral Therapy', 75.00, TRUE, 'https://example.com/photos/sarah_chen.jpg', 'Experienced CBT therapist focusing on anxiety and depression.', 4.8),
('Dr. Michael Lee', 'Family Counseling', 90.00, TRUE, 'https://example.com/photos/michael_lee.jpg', 'Specializes in family dynamics and relationship issues.', 4.7),
('Dr. Emily White', 'Trauma Therapy', 80.00, FALSE, 'https://example.com/photos/emily_white.jpg', 'Expert in EMDR and trauma-informed care.', 4.9),
('Dr. David Kim', 'Adolescent Psychology', 65.00, TRUE, 'https://example.com/photos/david_kim.jpg', 'Works with teenagers on self-esteem and behavioral challenges.', 4.5);

-- Insert data into the 'conversations' table
INSERT INTO public.conversations (user_id, title, updated_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com'),
  'Initial AI Check-in',
  '2023-05-04 10:00:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'lenteraina2025@gmail.com');

INSERT INTO public.conversations (user_id, title, updated_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com'),
  'Stress Management Session',
  '2023-05-05 15:00:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'lenteraina2025@gmail.com');

INSERT INTO public.conversations (user_id, title, updated_at)
SELECT
  (SELECT id FROM public.users WHERE email = 'john.doe@example.com'),
  'Coping with Change',
  '2023-06-02 12:00:00+00'
WHERE EXISTS (SELECT 1 FROM public.users WHERE email = 'john.doe@example.com');

-- Insert data into the 'messages' table
INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Initial AI Check-in'),
  'user',
  'Hi, I''m feeling a bit down today.',
  '2023-05-04 10:01:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Initial AI Check-in');

INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Initial AI Check-in'),
  'assistant',
  'I''m sorry to hear that. Can you tell me more about what''s making you feel down?',
  '2023-05-04 10:02:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Initial AI Check-in');

INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Stress Management Session'),
  'user',
  'I''m really stressed about work deadlines.',
  '2023-05-05 15:01:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Stress Management Session');

INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Stress Management Session'),
  'assistant',
  'It sounds like you''re under a lot of pressure. Let''s explore some coping strategies.',
  '2023-05-05 15:02:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'lenteraina2025@gmail.com') AND title = 'Stress Management Session');

INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'john.doe@example.com') AND title = 'Coping with Change'),
  'user',
  'I''m having trouble adjusting to a new city.',
  '2023-06-02 12:01:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'john.doe@example.com') AND title = 'Coping with Change');

INSERT INTO public.messages (conversation_id, role, content, created_at)
SELECT
  (SELECT id FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'john.doe@example.com') AND title = 'Coping with Change'),
  'assistant',
  'Moving can be challenging. What aspects are you finding most difficult?',
  '2023-06-02 12:02:00+00'
WHERE EXISTS (SELECT 1 FROM public.conversations WHERE user_id = (SELECT id FROM public.users WHERE email = 'john.doe@example.com') AND title = 'Coping with Change');