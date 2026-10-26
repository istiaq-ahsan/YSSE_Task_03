# YSSE Portal — Task 03 Deliverables

This folder contains the deliverables for the Software & App Engineering Wing Task 03.

## Files
- `DATABASE_DOCUMENTATION.md` — database requirement summary, table/column explanations, relationships, backend integration, assumptions, setup, and verification status.
- `DEMO_WEBSITE_DOCUMENTATION.md` — project overview, features, tech stack, structure, setup, implemented/pending work, submission checklist, and a ClickUp progress note.
- `sql/01_schema.sql` — schema recreation script based on the supplied live schema metadata.
- `sql/02_sample_data.sql` — repeatable sample data for the six tables.
- `sql/03_test_queries.sql` — schema checks, record counts, relationship joins, and sample queries.

## Recommended order
1. Read the verification warning in `DATABASE_DOCUMENTATION.md`.
2. If using a fresh test database, execute `sql/01_schema.sql`, then `sql/02_sample_data.sql`, then `sql/03_test_queries.sql`.
3. If using the existing Supabase database, do **not** rerun schema creation unnecessarily. Run the inspection and read queries only, and capture results for submission.
4. Complete the checklist in `DEMO_WEBSITE_DOCUMENTATION.md` and paste the progress note into ClickUp.

## Important
The scripts and documentation are prepared from the codebase and the schema/constraint output provided in the conversation. They have not been executed against the live Supabase database because database credentials were not supplied. The SQL schema file is for a fresh schema, not a production migration.
