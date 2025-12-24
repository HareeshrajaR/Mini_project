-- Migration: Add exam_date to seating_arrangements and enforce that the same seat in the same room cannot be used more than once on the same date.
-- DB: PostgreSQL (Supabase)
-- sqlfluff: dialect=postgres

-- 1) Add column if it doesn't already exist
ALTER TABLE seating_arrangements ADD COLUMN IF NOT EXISTS exam_date DATE;

-- 2) Backfill from exams for rows that are currently NULL (safe to re-run)
UPDATE seating_arrangements sa
SET exam_date = e.exam_date
FROM exams e
WHERE sa.exam_id = e.id
  AND sa.exam_date IS NULL;

-- 3) Remove any duplicates that would violate the unique constraint (keep the smallest id)
-- Use a CTE with row_number to deterministically keep the first row per (room_id, seat_number, exam_date)
WITH duplicates AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY room_id, seat_number, exam_date ORDER BY id) AS rn
  FROM seating_arrangements
)
DELETE FROM seating_arrangements
WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);

-- 4) Make column NOT NULL (assumes backfill completed)
ALTER TABLE seating_arrangements ALTER COLUMN exam_date SET NOT NULL;

-- 5) Add unique index on (room_id, exam_date, seat_number) if it doesn't already exist
CREATE UNIQUE INDEX IF NOT EXISTS seating_room_date_seat_unique_idx ON seating_arrangements (room_id, exam_date, seat_number);
