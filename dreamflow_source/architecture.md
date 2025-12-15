# LENTERA Architecture Documentation

## Overview
LENTERA adalah aplikasi kesehatan mental berbasis AI yang menyediakan layanan konseling melalui voice call, text chat, mood tracking, dan booking psikolog profesional.

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.6+
- **State Management**: Provider (ready for integration)
- **Navigation**: go_router
- **Local Storage**: shared_preferences
- **HTTP Client**: dio (ready for API integration)
- **WebSocket**: web_socket_channel (ready for voice call)
- **Audio**: flutter_sound, record (ready for voice features)
- **UI**: Google Fonts (Inter), Custom theme with therapeutic colors

### Backend (Future Integration)
- FastAPI untuk AI processing
- Supabase untuk database, auth, dan real-time features
- Ollama untuk LLM
- Whisper untuk Speech-to-Text
- Piper/XTTS untuk Text-to-Speech

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart               # Theme configuration dengan warna therapeutic
├── nav.dart                 # Navigation setup
│
├── models/                  # Data models
│   ├── user.dart
│   ├── mood_entry.dart
│   ├── psychologist.dart
│   └── conversation.dart
│
├── services/                # Business logic & data management
│   ├── mood_service.dart
│   ├── psychologist_service.dart
│   └── conversation_service.dart
│
├── components/              # Reusable UI components
│   ├── mood_card.dart
│   └── psychologist_card.dart
│
└── screens/                 # Application screens
    ├── home_page.dart       # Main screen with bottom navigation
    ├── mood_entry_screen.dart
    ├── psychologists_screen.dart
    ├── voice_call_screen.dart
    └── trivia_screen.dart
```

## Features Implemented

### 1. Home Screen
- Greeting berdasarkan waktu
- Quick actions (Check Mood, Chat AI)
- Feature cards untuk akses cepat ke fitur utama
- Bottom navigation dengan 4 tab (Home, Mood, Chat, Profile)

### 2. Mood Tracker
- Rating mood 1-5 dengan emoji
- Tag emosi (12 pilihan)
- Journal text opsional
- Penyimpanan lokal dengan shared_preferences
- Sample data untuk demonstrasi

### 3. Psychologist Booking
- List psikolog dengan specialization
- Filter (All, Available)
- Detail psikolog (rating, price, bio)
- Booking dialog (UI ready, backend pending)
- Sample data 4 psikolog

### 4. Voice Call AI
- UI simulasi voice call
- Animated visual feedback
- Controls (Mute, Speaker, End Call)
- Ready untuk integrasi WebSocket

### 5. Daily Trivia
- Multiple choice questions
- Immediate feedback
- Explanations untuk setiap jawaban
- Progress tracking
- 3 sample questions tentang mental health

## Design System

### Color Palette
**Light Mode:**
- Primary: #7C6FBA (Soft purple - calm & healing)
- Secondary: #FF9B7B (Warm coral - emotional warmth)
- Tertiary: #6BBAA7 (Soft teal - balance)
- Background: #FAF9FF (Clean & spacious)

**Dark Mode:**
- Primary: #BDB4E8 (Soft purple glow)
- Secondary: #FFB39D (Warm coral adjusted)
- Tertiary: #8DD4C0 (Soft teal)
- Background: #1C1B1F (Deep calming dark)

### Typography
- Font Family: Inter (Google Fonts)
- Hierarchy yang jelas dengan size yang konsisten
- Spacing 1.5x untuk readability

### Spacing
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

### Border Radius
- sm: 8px
- md: 12px
- lg: 16px
- xl: 24px

## Data Flow

### Current (Local Storage)
1. Services load dari shared_preferences
2. Jika tidak ada data, gunakan sample data
3. Write operations save ke shared_preferences
4. UI updates dari service calls

### Future (Backend Integration)
1. Authentication via Supabase Auth
2. Real-time data via Supabase Realtime
3. Voice call via WebSocket ke FastAPI
4. AI responses dari Ollama/LLM pipeline

## Navigation Routes

- `/` - Home (Bottom Navigation Root)
- `/mood-entry` - Mood Entry Screen (Full screen dialog)
- `/psychologists` - Psychologist List
- `/voice-call` - Voice Call Screen (Full screen dialog)
- `/trivia` - Daily Trivia

## State Management

Current: Local state dengan StatefulWidget
Future: Provider untuk global state (user, auth, real-time data)

## Next Steps untuk Full Implementation

### Phase 1 (Current) ✅
- [x] Setup project structure
- [x] Implement theme & design system
- [x] Create core screens dengan UI
- [x] Local data management
- [x] Navigation setup

### Phase 2 (Backend Integration)
- [ ] Setup Supabase project
- [ ] Implement authentication
- [ ] Connect to Supabase database
- [ ] Real-time chat implementation
- [ ] Setup FastAPI backend

### Phase 3 (AI Features)
- [ ] WebSocket voice call integration
- [ ] STT/TTS implementation
- [ ] LLM conversation flow
- [ ] RAG untuk contextual responses

### Phase 4 (Advanced Features)
- [ ] Payment integration untuk booking
- [ ] Push notifications
- [ ] Analytics & mood insights
- [ ] Offline mode optimization

## Notes
- Semua screens sudah responsive dan support dark mode
- UI mengikuti prinsip accessible design
- Code structure siap untuk scaling
- Sample data untuk demonstrasi tanpa backend
