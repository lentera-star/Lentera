-- Pending migrations to reconcile remote schema with local definitions

-- Ensure psychologists.rating exists for filtering/sorting and future analytics
ALTER TABLE IF EXISTS psychologists
  ADD COLUMN IF NOT EXISTS rating NUMERIC(3, 2) NOT NULL DEFAULT 4.5 CHECK (rating >= 0 AND rating <= 5);

-- Create composite index for availability and rating (supports list sorting/filtering)
CREATE INDEX IF NOT EXISTS idx_psychologists_available_rating
  ON psychologists(is_available, rating DESC);
