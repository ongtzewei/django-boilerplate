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

## GitHub Actions CI/CD Pipeline

This repository includes a workflow at:
- `.github/workflows/scan-build.yml`

### Trigger Events

The pipeline runs on:
- `push` to `main`
- `pull_request` events: `opened`, `synchronize`, `reopened`

### Pipeline Stages

The workflow runs 3 jobs in sequence:

1. `automated-test-job`
- Checks out code
- Installs `uv` and project dependencies (`uv sync --frozen`)
- Lints code with `pylint`
- Runs Django unit tests with coverage
- Generates coverage outputs (`coverage`, HTML, XML)
- Runs SonarQube scan
- Uploads `coverage` artifact

2. `scan-vuln-job` (depends on `automated-test-job`)
- Exports `requirements.txt` via `uv export`
- Runs dependency audit with `pip-audit`
- Runs OWASP Dependency Check
- Runs Trivy filesystem scan (`vuln`, `config`, `secret`)
- Uploads OWASP and Trivy FS scan artifacts

3. `build-scan-container-job` (depends on `scan-vuln-job`)
- Builds Docker image with Buildx
- Tags image as `latest`, `sha-<commit>`, and long SHA tag
- Runs Trivy container image scan
- Uploads Trivy container scan artifact
- Pushes Docker image only for non-PR events (`push`), if registry auth is configured

### Required Secrets / Notes

- `SONAR_TOKEN` is required for the SonarQube step.
- Docker registry login is required before image push if your registry needs authentication.
- Vulnerability scan steps currently use `exit-code: 0`, so findings are reported but do not fail the workflow.

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
