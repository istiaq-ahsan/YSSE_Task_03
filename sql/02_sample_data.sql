-- YSSE Portal sample data. Uses stable sample labels to avoid adding duplicates on reruns.
-- Run 01_schema.sql first. Sample data only; change dates/records as needed.

INSERT INTO public.opportunities
    (title, type, amount, deadline, description, eligibility, application_url, status)
SELECT 'YSSE Virtual Internship — Software & App Engineering', 'Internship', 'Unpaid / Learning opportunity', DATE '2027-01-15',
       'A sample opportunity for students interested in software and application engineering.',
       'University students with relevant interest and availability.', '', 'open'
WHERE NOT EXISTS (
    SELECT 1 FROM public.opportunities WHERE title = 'YSSE Virtual Internship — Software & App Engineering'
);

INSERT INTO public.opportunities
    (title, type, amount, deadline, description, eligibility, application_url, status)
SELECT 'Youth Entrepreneurship Fellowship', 'Fellowship', 'Mentorship and training', DATE '2027-02-10',
       'A sample fellowship focused on youth-led social entrepreneurship.',
       'Young people interested in social impact.', '', 'open'
WHERE NOT EXISTS (
    SELECT 1 FROM public.opportunities WHERE title = 'Youth Entrepreneurship Fellowship'
);

INSERT INTO public.applications
    (opportunity_id, applicant_uid, full_name, email, phone, institution, department, semester,
     cv_url, linkedin_url, motivation, status)
SELECT o.id, 'sample-firebase-uid-001', 'Demo Applicant', 'demo.applicant@example.com', '+8801000000000',
       'Example University', 'Computer Science and Engineering', '6th Semester', '', '',
       'I want to learn through practical projects and contribute to the team.', 'pending'
FROM public.opportunities o
WHERE o.title = 'YSSE Virtual Internship — Software & App Engineering'
  AND NOT EXISTS (
      SELECT 1 FROM public.applications a
      WHERE a.opportunity_id = o.id AND a.applicant_uid = 'sample-firebase-uid-001'
  );

INSERT INTO public.programs
    (title, description, duration, mode, enrolled, seats, status, image_color)
SELECT 'Social Entrepreneurship Bootcamp', 'A sample program to develop social enterprise ideas.', '8 weeks', 'Hybrid', 12, 30, 'open', 'from-emerald-500 to-teal-600'
WHERE NOT EXISTS (SELECT 1 FROM public.programs WHERE title = 'Social Entrepreneurship Bootcamp');

INSERT INTO public.programs
    (title, description, duration, mode, enrolled, seats, status, image_color)
SELECT 'Digital Skills for Impact', 'A sample program covering practical digital skills for impact projects.', '6 weeks', 'Online', 8, 25, 'open', 'from-blue-500 to-indigo-600'
WHERE NOT EXISTS (SELECT 1 FROM public.programs WHERE title = 'Digital Skills for Impact');

INSERT INTO public.events
    (title, description, type, date, mode, registered, seats, status, image_color)
SELECT 'YSSE Community Orientation', 'A sample introductory event for community members.', 'Orientation', DATE '2027-01-20', 'Online', 18, 50, 'upcoming', 'from-emerald-500 to-teal-600'
WHERE NOT EXISTS (SELECT 1 FROM public.events WHERE title = 'YSSE Community Orientation');

INSERT INTO public.events
    (title, description, type, date, mode, registered, seats, status, image_color)
SELECT 'Social Impact Workshop', 'A sample workshop on identifying and validating community problems.', 'Workshop', DATE '2027-02-05', 'Offline', 22, 40, 'upcoming', 'from-cyan-500 to-blue-600'
WHERE NOT EXISTS (SELECT 1 FROM public.events WHERE title = 'Social Impact Workshop');

INSERT INTO public.articles
    (title, category, author, content, excerpt, read_time, status, published_at)
SELECT 'Getting Started with Social Entrepreneurship', 'Entrepreneurship', 'YSSE Editorial Team',
       'This sample article introduces social entrepreneurship and the role of community-centered problem solving.',
       'An introduction to building ventures that address social problems.', '2 min read', 'published', CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM public.articles WHERE title = 'Getting Started with Social Entrepreneurship');

INSERT INTO public.articles
    (title, category, author, content, excerpt, read_time, status, published_at)
SELECT 'Planning a Community Project', 'Guides', 'YSSE Editorial Team',
       'This draft sample article outlines steps for identifying a community need, defining outcomes, and planning activities.',
       'A practical starting point for planning a community initiative.', '3 min read', 'draft', NULL
WHERE NOT EXISTS (SELECT 1 FROM public.articles WHERE title = 'Planning a Community Project');

INSERT INTO public.users (email, user_data)
VALUES ('demo.user@example.com', '{"name":"Demo User","role":"client","sample":true}'::jsonb)
ON CONFLICT (email) DO NOTHING;
