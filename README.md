# staydesk

`staydesk` is a full-stack internship project with:

- an ASP.NET Core 8 backend API in [Backend](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Backend)
- a Flutter admin client in [Frontend](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Frontend)

The current product shape is a room and booking management dashboard. The branding has been normalized to `staydesk`, but parts of the domain model still use hotel-style naming to avoid risky structural changes.

## Stack

- Backend: ASP.NET Core, Entity Framework Core, Pomelo MySQL, JWT auth, Swagger
- Frontend: Flutter, Provider, Shared Preferences, HTTP
- Database: MySQL

## Repo Layout

```text
HRAMS/
├── Backend/
│   ├── Controllers/
│   ├── Data/
│   ├── DTOs/
│   ├── Helpers/
│   ├── Migrations/
│   └── Models/
└── Frontend/
    ├── lib/
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── web/
    └── windows/
```

## What Works Today

- JWT-based admin login and registration
- Room listing, room availability lookup, room CRUD
- Booking listing, booking creation, booking updates, booking deletion
- Dashboard stats and a polished Flutter admin UI
- Seeded development data on first backend startup

## Gaps To Be Aware Of

- Generated .NET build artifacts are currently tracked in Git under `Backend/bin` and `Backend/obj`
- Auth and configuration are still development-oriented, not production-hardened
- The product model is closer to a booking dashboard prototype than a finished SaaS product
- There are no automated tests in the repository yet

## Backend Setup

1. Create a MySQL database. The current development config points to `hotel_management`.
2. Optionally copy [Backend/appsettings.Local.example.json](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Backend/appsettings.Local.example.json) to `Backend/appsettings.Local.json` and override the connection string and JWT secret locally.
3. Start the API from [Backend](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Backend):

```bash
dotnet run
```

The API runs on `http://localhost:5225` by default. Swagger is available in development, and a basic health endpoint is exposed at `/health`.

Seeded accounts:

- `admin` / `admin123`
- `demo` / `demo123`
- `manager` / `pass123`

## Frontend Setup

From [Frontend](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Frontend):

```bash
flutter pub get
flutter run
```

By default, the frontend calls `http://localhost:5225/api`.

To point it at another backend, pass a Dart define:

```bash
flutter run --dart-define=STAYDESK_API_BASE_URL=http://localhost:5225/api
```

## API Notes

- Auth endpoints: `/api/admin/login`, `/api/admin/register`
- Protected resource endpoints: `/api/rooms`, `/api/bookings`, `/api/dashboard/stats`
- Example request collections live in [Backend/API_ENDPOINTS.http](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Backend/API_ENDPOINTS.http) and [Backend/staydesk-backend.http](/Users/antonyjose/Desktop/Projects/Internship/HRAMS/HRAMS/Backend/staydesk-backend.http)

## Recommended Next Steps

- Add backend unit/integration tests around auth, bookings, and room status transitions
- Remove tracked build artifacts from Git history in a separate cleanup commit
- Replace development secrets and permissive CORS before any shared deployment
- Decide whether the product should remain room-based or be refactored into a true desk/workspace domain
