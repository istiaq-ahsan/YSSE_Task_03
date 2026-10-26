# YSSE Portal — PostgreSQL Database Documentation

**Task:** Software & App Engineering Wing — Task 03  
**Database:** PostgreSQL (Supabase)  
**Backend:** Node.js, Express, `pg`  
**Reviewed:** 26 October 2026

## 1. Purpose and scope

The database supports the YSSE Portal's program listings, opportunities, application pipeline, events, editorial content, and user profile data. The schema in this document is based on the six existing tables and constraints inspected in the supplied Supabase SQL Editor output. `sql/01_schema.sql` recreates that structure in a new/empty `public` schema, with indexes for common list and join queries. It does not drop or overwrite existing production data.

## 2. Entity relationship overview

```mermaid
erDiagram
    OPPORTUNITIES ||--o{ APPLICATIONS : receives
    USERS {
        bigint id PK
        text email UK
        jsonb user_data
    }
    OPPORTUNITIES {
        bigint id PK
        text title
        text type
        date deadline
        text status
    }
    APPLICATIONS {
        bigint id PK
        bigint opportunity_id FK
        text applicant_uid
        text full_name
        text email
        text status
    }
    PROGRAMS {
        uuid id PK
        text title
        text mode
        integer enrolled
        integer seats
    }
    EVENTS {
        integer id PK
        varchar title
        date date
        integer registered
        integer seats
    }
    ARTICLES {
        integer id PK
        varchar title
        varchar author
        varchar status
    }
    OPPORTUNITIES ||--o{ APPLICATIONS : "opportunity_id"
```

**Implemented relational link:** `applications.opportunity_id` references `opportunities.id` with `ON DELETE CASCADE`. An opportunity can have many applications; each application belongs to one opportunity.

**Important limitation:** `applications.applicant_uid` stores the Firebase Authentication UID as text, but it does not reference `users.id`. The `users` table currently stores `email` and a JSONB `user_data` object, and does not have a dedicated Firebase UID column. Thus, the schema does not enforce a database-level relationship between an application and a user profile.

`programs`, `events`, and `articles` are standalone content tables in the current schema. Event attendance is represented by the `registered` count; there is no event-registration table in the inspected schema.

## 3. Table documentation

### `users`
Stores profile information received from the frontend/backend user service.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `BIGINT` | Primary key; sequence-generated |
| `email` | `TEXT` | Required and unique |
| `user_data` | `JSONB` | Required; flexible profile data such as name/role |
| `created_at` | `TIMESTAMPTZ` | Defaults to `NOW()`; nullable in current schema |

The backend normalizes email to lowercase on save and uses `ON CONFLICT (email)` to update `user_data` for an existing email.

### `opportunities`
Stores grants, internships, fellowships, and other opportunities.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `BIGINT` | Primary key; sequence-generated |
| `title` | `TEXT` | Required title |
| `type` | `TEXT` | Required opportunity category |
| `amount` | `TEXT` | Required; defaults to empty string (allows descriptive/non-numeric funding text) |
| `deadline` | `DATE` | Required application deadline |
| `description` | `TEXT` | Required details |
| `eligibility` | `TEXT` | Required; defaults to empty string |
| `application_url` | `TEXT` | Required; defaults to empty string |
| `status` | `TEXT` | Defaults to `open`; allowed: `open`, `closed` |
| `created_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |
| `updated_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |

The backend lists opportunities newest first and uses `status = 'open'` when accepting applications.

### `applications`
Stores a user's submission to an opportunity and the review status.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `BIGINT` | Primary key; sequence-generated |
| `opportunity_id` | `BIGINT` | Required foreign key to `opportunities.id`; cascade delete |
| `applicant_uid` | `TEXT` | Required Firebase UID of applicant |
| `full_name` | `TEXT` | Required applicant name |
| `email` | `TEXT` | Required contact email |
| `phone` | `TEXT` | Required phone number |
| `institution` | `TEXT` | Required institution |
| `department` | `TEXT` | Required department |
| `semester` | `TEXT` | Required semester/year label |
| `cv_url` | `TEXT` | Required; defaults to empty string |
| `linkedin_url` | `TEXT` | Required; defaults to empty string |
| `motivation` | `TEXT` | Required application motivation |
| `status` | `TEXT` | Defaults to `pending`; allowed: `pending`, `reviewing`, `accepted`, `rejected` |
| `created_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |
| `updated_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |

The unique constraint `(opportunity_id, applicant_uid)` prevents one Firebase UID from submitting twice for the same opportunity. The application service joins to `opportunities` to display opportunity titles and deadlines.

### `programs`
Stores learning and development programs.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `UUID` | Primary key; defaults to `gen_random_uuid()` |
| `title` | `TEXT` | Required program name |
| `description` | `TEXT` | Required program description |
| `duration` | `TEXT` | Required duration label (e.g. `8 weeks`) |
| `mode` | `TEXT` | Defaults to `Online`; allowed: `Online`, `Offline`, `Hybrid` |
| `enrolled` | `INTEGER` | Defaults to `0`; must be between zero and `seats` |
| `seats` | `INTEGER` | Defaults to `30`; must be at least `1` |
| `status` | `TEXT` | Defaults to `open`; allowed: `open`, `closed` |
| `image_color` | `TEXT` | Defaults to a Tailwind gradient token used by the UI |
| `created_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |
| `updated_at` | `TIMESTAMPTZ` | Required; defaults to `NOW()` |

The database checks that `enrolled <= seats`. The current service updates `updated_at` only if explicitly added to its update query; the supplied program update query does not update that timestamp.

### `events`
Stores event details and a simple registration count.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `INTEGER` | Primary key; sequence-generated |
| `title` | `VARCHAR` | Required event title |
| `description` | `TEXT` | Nullable; default empty string |
| `type` | `VARCHAR` | Required; defaults to `Workshop` |
| `date` | `DATE` | Required event date |
| `mode` | `VARCHAR` | Required; defaults to `Offline` |
| `registered` | `INTEGER` | Required; defaults to `0` |
| `seats` | `INTEGER` | Required; defaults to `50` |
| `status` | `VARCHAR` | Required; defaults to `upcoming` |
| `image_color` | `VARCHAR` | Required; defaults to a Tailwind gradient token |
| `created_at` | `TIMESTAMP` | Nullable; defaults to current timestamp |
| `updated_at` | `TIMESTAMP` | Nullable; defaults to current timestamp |

The inspected schema does not currently enforce `registered >= 0`, `registered <= seats`, a valid event status, or a valid mode. These would be reasonable future constraints, but they are intentionally not silently added to the recreation script because this document records the current implementation.

### `articles`
Stores blog/editorial content.

| Column | Type | Rules / meaning |
|---|---|---|
| `id` | `INTEGER` | Primary key; sequence-generated |
| `title` | `VARCHAR` | Required title |
| `category` | `VARCHAR` | Required; defaults to `General` |
| `author` | `VARCHAR` | Required author label |
| `content` | `TEXT` | Required; defaults to empty string |
| `excerpt` | `TEXT` | Required; defaults to empty string |
| `read_time` | `VARCHAR` | Required; defaults to `1 min read` |
| `status` | `VARCHAR` | Required; defaults to `draft`; allowed: `published`, `draft`, `archived` |
| `published_at` | `TIMESTAMP` | Nullable; set when published |
| `created_at` | `TIMESTAMP` | Required; defaults to current timestamp |
| `updated_at` | `TIMESTAMP` | Required; defaults to current timestamp |

The public article service returns only rows where `status = 'published'`, sorted by publication time. Management endpoints can list and edit articles.

## 4. Data types, constraints, and naming choices

- Primary keys are named `id`; PostgreSQL sequences back the integer/bigint IDs, while programs use UUIDs.
- Foreign key columns use the referenced table's ID type (`applications.opportunity_id BIGINT` to `opportunities.id BIGINT`).
- `TEXT` is used for descriptive fields and URLs; `DATE` is used for deadlines/event dates; timestamps track creation and updates.
- `JSONB` keeps flexible user profile attributes in `users.user_data`.
- `NOT NULL`, `DEFAULT`, `UNIQUE`, `CHECK`, and `FOREIGN KEY` constraints enforce the rules currently present in the inspected schema.
- Most application timestamps use `TIMESTAMPTZ`, while `articles` and `events` use `TIMESTAMP WITHOUT TIME ZONE`. This is an existing inconsistency worth considering in a future migration, not an automatic change in this task.

## 5. Backend integration

The backend creates a PostgreSQL connection pool in `src/config/db.js` using `DATABASE_URL` and optional `DATABASE_SSL=true`. Services use parameterized `pool.query()` calls.

| Resource | Backend mount path | Key operations in supplied code |
|---|---|---|
| Users | `/users` | list, lookup by email, create/update profile |
| Opportunities | `/opportunities` | list, read, create, update, delete |
| Applications | `/applications` | submit, list current applicant's applications, admin list, status update |
| Programs | `/api/programs` | list/read public; create/update/delete require Firebase token |
| Events | `/api/events` | list/read public; create/update/delete require Firebase token |
| Articles | `/api/blog` | public published list/read; management list/create/update/delete require Firebase token |

Firebase ID tokens are verified by `verifyFirebaseToken` on routes that use the middleware. Important security review finding: in the supplied code, opportunity write routes and user routes do not apply that middleware, and the application admin routes only verify a Firebase token without a role check in the route itself. Do not treat token verification alone as administrator authorization. Before production, protect write/admin routes with server-side role/claim authorization and validate user roles on the server.

## 6. Setup instructions

### Supabase
1. Open the project's Supabase SQL Editor.
2. For a fresh database, run `sql/01_schema.sql`.
3. Run `sql/02_sample_data.sql` to insert demonstration records.
4. Run queries from `sql/03_test_queries.sql` and check the returned rows/constraints.
5. If applying this to the already-populated project database, do not run this as a migration blindly. The table definitions already exist; use the test queries only, and apply future schema changes through deliberate migrations.

### Node.js backend
1. Install a supported Node.js version and npm.
2. From the backend folder, run `npm install`.
3. Configure environment variables in a local `.env` file (never commit secrets):

```env
PORT=3000
DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DATABASE
DATABASE_SSL=true
# Configure Firebase Admin credentials according to src/config/firebaseAdmin.js
```

4. Run `npm run dev` for watch mode or `npm start` for normal local startup.
5. Open `http://localhost:3000/`; a successful response indicates the API process is running. Startup also executes `SELECT 1` against PostgreSQL.

### Frontend
1. From the frontend folder, run `npm install`.
2. Copy `.env.example` to `.env` and set `VITE_API_URL=http://localhost:3000` for local development.
3. Ensure Firebase frontend configuration corresponds to the intended Firebase project.
4. Run `npm run dev`; use `npm run build` to verify a production bundle.

Never put the database connection string or Firebase Admin service-account credentials in frontend variables. Variables prefixed with `VITE_` are exposed to the browser.

## 7. Assumptions and recommended follow-up improvements

1. A Firebase UID is the identity used to associate applications with the applicant; it is currently stored as text in `applications.applicant_uid`.
2. Program enrollment and event registration are currently counters, not normalized participant-registration records.
3. Opportunity `amount` is text because values can be descriptive rather than purely numeric.
4. `users.user_data` is intentionally flexible JSONB in the current implementation.
5. Consider adding a `firebase_uid` column with a unique constraint to `users` and a safe migration strategy before adding a foreign key from applications.
6. Consider a separate `event_registrations` table if individual event registrations must be tracked, deduplicated, or linked to users.
7. Add event count/status/mode constraints and consistent timestamp-update behavior through a migration after confirming requirements.
8. Enforce moderator/admin authorization on the server, not only in frontend route guards.

## 8. Verification status

The schema and constraints listed in the introduction were supplied from live Supabase SQL Editor output. The scripts in this package were generated to match that reported structure and to provide sample-data/test-query workflows. They have **not** been executed against your live Supabase database from this environment because no database connection credentials were supplied. Execute the scripts in your Supabase SQL Editor and capture successful results for the final ClickUp progress record.
