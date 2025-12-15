# LENTERA Environment Configuration
# Copy this file to .env and fill in your actual values

# -----------------
# Supabase Configuration
# -----------------
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# -----------------
# Backend API Configuration
# -----------------
API_BASE_URL=http://localhost:8000
WEBSOCKET_URL=ws://localhost:8000/ws

# -----------------
# AI Services Configuration
# -----------------
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:latest
WHISPER_MODEL=base
TTS_ENGINE=piper

# -----------------
# Gamification Configuration
# -----------------
POINTS_MOOD_ENTRY=10
POINTS_CHAT_SESSION=20
POINTS_BOOKING_COMPLETE=50
POINTS_TRIVIA_CORRECT=5
POINTS_DAILY_LOGIN=5
LEVEL_UP_THRESHOLD=100
MAX_LEVEL=50

# -----------------
# Payment Gateway Configuration
# -----------------
PAYMENT_SERVER_KEY=your-payment-server-key
PAYMENT_CLIENT_KEY=your-payment-client-key
PAYMENT_ENVIRONMENT=sandbox

# -----------------
# Storage Configuration
# -----------------
STORAGE_BUCKET_AVATARS=avatars
STORAGE_BUCKET_MOOD_AUDIO=mood-audio
STORAGE_BUCKET_PROFILE_IMAGES=profile-images

# -----------------
# Feature Flags
# -----------------
ENABLE_GAMIFICATION=true
ENABLE_VIDEO_CALL=true
ENABLE_AVATAR_SHOP=true
ENABLE_PEER_CHAT=true
ENABLE_TRIVIA=true
ENABLE_MOOD_INSIGHTS=true

# -----------------
# App Configuration
# -----------------
APP_NAME=LENTERA
APP_VERSION=1.0.0
DEFAULT_LANGUAGE=id
SESSION_TIMEOUT=60
MAX_MESSAGE_LENGTH=1000
CHAT_HISTORY_LIMIT=100
VOICE_CALL_MAX_DURATION=30

# -----------------
# Development Only
# -----------------
DEBUG_MODE=false
LOG_LEVEL=info
USE_MOCK_DATA=false
