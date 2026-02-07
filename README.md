# Django Boilerplate

A minimal Django 6 starter project with:
- custom `User` model (`app.User`)
- environment-based settings via `.env`
- SQLite for local development
- Docker and Docker Compose support

The current URL configuration includes the Django admin at `/admin/`.

## Requirements

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (recommended for dependency management)
- Docker + Docker Compose (optional, for containerized setup)

## Local Setup

1. Copy environment variables:

```bash
cp .env.sample .env
```

2. Install dependencies:

```bash
uv sync
```

3. Run migrations:

```bash
uv run python manage.py migrate
```

4. Start the development server:

```bash
uv run python manage.py runserver 0.0.0.0:8080
```

5. Open the app:

- Admin: http://localhost:8080/admin/

## Docker Setup

1. Copy environment variables:

```bash
cp .env.sample .env
```

2. Build and run containers:

```bash
docker compose -f compose.yml up --build
```

The app will be available at:
- http://localhost:8080/

## Useful Commands

```bash
# Create a superuser
uv run python manage.py createsuperuser

# Run tests
uv run python manage.py test

# Apply new migrations
uv run python manage.py makemigrations
uv run python manage.py migrate
```
