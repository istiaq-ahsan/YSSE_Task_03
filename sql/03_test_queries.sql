-- YSSE Portal database verification queries

-- 1. List tables and columns.
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 2. List constraints.
SELECT conrelid::regclass AS table_name, conname, contype,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, contype;

-- 3. Count records in each core table.
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM public.users
UNION ALL SELECT 'opportunities', COUNT(*) FROM public.opportunities
UNION ALL SELECT 'applications', COUNT(*) FROM public.applications
UNION ALL SELECT 'programs', COUNT(*) FROM public.programs
UNION ALL SELECT 'events', COUNT(*) FROM public.events
UNION ALL SELECT 'articles', COUNT(*) FROM public.articles
ORDER BY table_name;

-- 4. Demonstrate the applications -> opportunities foreign-key relationship.
SELECT a.id AS application_id, a.full_name, a.status AS application_status,
       o.id AS opportunity_id, o.title AS opportunity_title, o.deadline
FROM public.applications a
JOIN public.opportunities o ON o.id = a.opportunity_id
ORDER BY a.created_at DESC;

-- 5. Applicant tracking view: all applications for one Firebase UID.
SELECT a.id, a.full_name, a.status, a.created_at, o.title AS opportunity_title, o.deadline
FROM public.applications a
JOIN public.opportunities o ON o.id = a.opportunity_id
WHERE a.applicant_uid = 'sample-firebase-uid-001'
ORDER BY a.created_at DESC;

-- 6. Publicly visible opportunities.
SELECT id, title, type, amount, deadline, status
FROM public.opportunities
WHERE status = 'open' AND deadline >= CURRENT_DATE
ORDER BY deadline;

-- 7. Available programs and remaining seats.
SELECT id, title, mode, enrolled, seats, seats - enrolled AS remaining_seats
FROM public.programs
WHERE status = 'open'
ORDER BY title;

-- 8. Upcoming events.
SELECT id, title, type, date, mode, registered, seats
FROM public.events
WHERE date >= CURRENT_DATE
ORDER BY date;

-- 9. Published articles only (matches public blog service behavior).
SELECT id, title, category, author, published_at
FROM public.articles
WHERE status = 'published'
ORDER BY published_at DESC NULLS LAST, id DESC;

-- 10. Validate the enrollment CHECK constraint (expected to fail if uncommented).
-- UPDATE public.programs SET enrolled = seats + 1
-- WHERE title = 'Social Entrepreneurship Bootcamp';

-- 11. Validate duplicate application protection (expected to fail if uncommented).
-- INSERT INTO public.applications
-- (opportunity_id, applicant_uid, full_name, email, phone, institution, department, semester, motivation)
-- SELECT id, 'sample-firebase-uid-001', 'Duplicate Demo', 'duplicate@example.com', '010', 'Example University', 'CSE', '6th', 'Test'
-- FROM public.opportunities WHERE title = 'YSSE Virtual Internship — Software & App Engineering';
