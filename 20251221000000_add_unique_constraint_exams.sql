-- Migration: Add unique constraint on exams to support upsert on (subject_id, exam_date, start_time, room_id)
-- DB: PostgreSQL (Supabase)
-- sqlfluff: dialect=postgres

-- Remove duplicates that would violate the unique constraint (keep the earliest id)
DELETE FROM exams
WHERE id IN (
  SELECT a.id FROM exams a
  JOIN exams b ON a.subject_id = b.subject_id
    AND a.exam_date = b.exam_date
    AND a.start_time = b.start_time
    AND (a.room_id = b.room_id OR (a.room_id IS NULL AND b.room_id IS NULL))
  WHERE a.id > b.id
);

-- Add unique index on exams to support upsert on (subject_id, exam_date, start_time, room_id)
CREATE UNIQUE INDEX IF NOT EXISTS exams_unique_subject_date_time_room_idx ON exams (subject_id, exam_date, start_time, room_id);
