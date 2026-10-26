# YSSE Portal — Demo Website Documentation

## 1. Project overview

YSSE Portal is a web application concept for Youth School for Social Entrepreneurs. It brings organizational information and opportunities into one interface, including programs, events, articles/resources, departments, opportunity listings, and application tracking. The supplied frontend is branded for YSSE, while several package names and some starter-template messages still use the original HackStart naming; these are implementation cleanup items.

## 2. Main features visible in the codebase

### Public-facing pages
- Home page with hero/feature sections, featured programs, upcoming events, resources/articles, and calls to action.
- About and Departments pages.
- Program list and program detail pages.
- Opportunity list, opportunity details, and application form pages.
- Event list and event detail pages.
- Blog/article list and article detail pages.
- Contact page.

### Authentication and dashboards
- Firebase-based login/register/forgot-password pages and shared auth context.
- Protected route components and role-based frontend route groups for client, moderator/merchant, and admin experiences.
- Client application tracking.
- Moderator pages for managing programs, opportunities, events, and blog articles.
- Admin pages for dashboard, users, applications, and content.
- Shared dashboard/profile/settings views, responsive layout components, theme context, loading/error/empty states, toast notifications, and reusable UI components.

### Backend-backed capabilities in supplied code
- PostgreSQL data access for users, opportunities, applications, programs, events, and articles.
- REST endpoints for listing/reading and management actions.
- Firebase ID-token verification on selected routes.
- Application uniqueness per opportunity/applicant and application status workflow.
- Public article endpoint filters to published content.

The existence of a page/component does not guarantee that every workflow is fully tested end-to-end. See the pending work section.

## 3. Technologies

| Area | Technologies observed |
|---|---|
| Frontend | React 19, Vite 8, React Router DOM 7 |
| Styling | Tailwind CSS 3, custom CSS |
| Forms/data | React Hook Form, Axios, TanStack React Query, Redux Toolkit |
| Authentication | Firebase client SDK; Firebase Admin in backend |
| UI/animation | Framer Motion, Lucide React, Sonner, custom reusable components |
| Backend | Node.js, Express 5, CommonJS modules |
| Database | PostgreSQL hosted through Supabase, `pg` connection pool, Supabase JS dependency present |
| Tooling | ESLint, Vite build tooling |

Note: the supplied frontend README appears to be inherited from a starter and mentions React 18 / Router v6, while `package.json` specifies React 19 / Router v7. Prefer the package manifest as the dependency source of truth and update the README when convenient.

## 4. Project structure

### Frontend (`frontend/src`)
- `pages/public/` — public home, about, departments, programs, opportunities, events, blog, and contact pages.
- `pages/auth/` — login, registration, and password recovery.
- `pages/dashboard/` — shared, client, moderator, and admin dashboard pages.
- `components/` — common components, department components, forms, home sections, layout, feedback, and UI primitives.
- `services/` — API service modules for users, applications, programs, opportunities, events, articles, and home content.
- `lib/` — Axios setup and Firebase/user helpers.
- `context/`, `hooks/`, `providers/` — authentication/theme state and reusable hooks.
- `routes/` — React Router setup and frontend route guards.
- `data/` — mock data for selected views/content.
- `assets/` — YSSE logos, hero/section images, and icons.

### Backend (`backend`)
- `index.js` — loads environment configuration, checks PostgreSQL connectivity, starts local HTTP server, and exports the app for hosting environments.
- `src/app.js` — Express app, CORS/JSON middleware, health check, route mounts, 404 response, and error handler.
- `src/config/db.js` — PostgreSQL pool.
- `src/config/firebaseAdmin.js` — Firebase Admin initialization.
- `src/middleware/` — Firebase token verification and centralized error handling.
- `src/modules/<resource>/` — controllers, routes, and services for users, opportunities, applications, programs, events, and blog articles.

## 5. Local setup

### Prerequisites
- Node.js and npm.
- Access to the Supabase PostgreSQL database.
- Firebase project configuration for frontend login and Firebase Admin credentials for backend token verification.

### Backend
```bash
cd backend
npm install
```
Create a `.env` file with the backend environment variables:

```env
PORT=3000
DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DATABASE
DATABASE_SSL=true
```
Configure Firebase Admin credentials according to `src/config/firebaseAdmin.js`. Do not commit credentials or `.env`.

```bash
npm run dev
# or
npm start
```
Visit `http://localhost:3000/` for the API health-check response.

### Frontend
```bash
cd frontend
npm install
```
Copy `.env.example` to `.env`, set `VITE_API_URL=http://localhost:3000`, and confirm Firebase frontend configuration. Then run:

```bash
npm run dev
npm run build
```

Use the deployed backend URL in `VITE_API_URL` when testing a deployed frontend. Any `VITE_*` value is bundled for browser access and must not contain secrets.

## 6. Current implementation and known gaps

### Implemented in the supplied source
- Public route structure for the main organizational content pages.
- Forms and pages for programs, opportunities, events, articles, and applications.
- PostgreSQL services for all six tables found in the Supabase schema.
- Firebase authentication integration and selected backend routes protected by ID-token verification.
- Application status values: pending, reviewing, accepted, rejected.
- Content statuses for opportunities, programs, and articles enforced by database checks.

### Pending work / items to verify
- **End-to-end test:** confirm each frontend API service uses the correct backend URL and endpoint, and verify create/read/update/delete flows against the deployed database.
- **Authorization:** frontend role guards improve navigation but are not security controls. The supplied opportunity write routes and user routes are not protected by Firebase middleware; application admin endpoints verify a token but do not visibly check an admin role. Add server-side role authorization before production use.
- **User relationship:** application records store Firebase UID as text, while `users` has no dedicated Firebase UID column or FK link.
- **Event registration:** events currently have a numeric `registered` counter but no per-person registration table in the observed schema.
- **Input validation:** add consistent server-side validation and sensible database checks for events and all write operations.
- **Timestamp consistency:** `events` and `articles` use timestamps without time zone while other tables mostly use `TIMESTAMPTZ`; update timestamps are not automatically refreshed by a database trigger.
- **API naming/config cleanup:** package names and health-check text still say HackStart; the frontend example app name also says HackStart. Update only after confirming final branding/deployment requirements.
- **Frontend README:** its listed React/Router versions and starter structure do not fully match the current package and YSSE implementation.
- **Testing:** backend `npm test` is currently a placeholder that exits with “no test specified”; add automated API/service tests. The SQL test script should be run in Supabase and screenshots/results recorded.
- **Duplicate route:** the frontend router currently registers the contact route twice; remove the duplicate after checking navigation behavior.
- **Data/mock verification:** some mock-data files remain, so each public section should be checked to establish whether it is API-backed or still uses demo data.

## 7. Database deliverables

See `DATABASE_DOCUMENTATION.md` and the `sql/` folder in this Task 03 package:
- `01_schema.sql` — recreates the six reported tables and their reported constraints in a new schema, plus query-oriented indexes.
- `02_sample_data.sql` — inserts repeatable demo rows for each entity and a related application.
- `03_test_queries.sql` — schema inspection, counts, joins, and common listing queries.

These scripts are prepared but have not been executed against the live Supabase database from this environment. Run them only as directed in the database documentation; do not recreate tables on the existing database unnecessarily.

## 8. Submission checklist

- [ ] Run/verify SQL scripts in a fresh test database or use read-only test queries on the current database.
- [ ] Capture screenshots of the Supabase schema/constraints and selected query results.
- [ ] Run frontend `npm run build` and fix any build errors.
- [ ] Start backend and verify `GET /` health check.
- [ ] Verify at least one joined application/opportunity query and one content listing query.
- [ ] Add repository/deployment links to ClickUp.
- [ ] Record completed work, known gaps, test evidence, and next actions in ClickUp.

## 9. ClickUp progress note (copy/paste)

**Task 03 — Database Design & Demo Website Documentation**

Reviewed the YSSE Portal frontend/backend codebase and the current Supabase PostgreSQL schema. Prepared database documentation, a schema recreation script, repeatable sample data, and test queries. Documented the six current tables (`users`, `opportunities`, `applications`, `programs`, `events`, `articles`), constraints, the applications-to-opportunities relationship, backend endpoints, local setup, implemented features, and known gaps. Remaining verification: execute the SQL queries in Supabase, run frontend build/backend health checks, capture evidence, confirm API flows, and add repository/deployment links.

**Status:** Documentation and SQL deliverables prepared; live database and end-to-end verification still pending.
