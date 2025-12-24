-- Scheduled function to check and send exam notifications
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'check-exam-notifications', -- name of the job
  '0 8 * * *',              -- run at 8 AM every day
  $$
  SELECT net.http_post(
    url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/check-exam-notifications',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
  ) AS request_id;
  $$
);