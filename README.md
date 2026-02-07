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

### Job Flow

Jobs run in this order:
- `automated-test-job` -> `scan-vuln-job` -> `build-scan-container-job`

All jobs run on `ubuntu-22.04` in the `development` environment.

### Stage Details

1. `automated-test-job` (quality + test gate)
- `actions/checkout@v3`
- `astral-sh/setup-uv@v5`
- Dependency install: `uv sync --frozen`
- Lint: `uv run pylint --recursive=y .`
- Tests + coverage:
  - `uv run coverage erase`
  - `uv run coverage run ./manage.py test`
  - `uv run coverage report`
  - `uv run coverage html -d coverage`
  - `uv run coverage xml`
- SonarQube scan: `sonarsource/sonarqube-scan-action@master`
- Artifact uploaded: `coverage` (HTML coverage output directory)

2. `scan-vuln-job` (dependency + source security scan)
- Dependency export: `uv export --format requirements-txt --output-file requirements.txt`
- Package audit: `pip-audit -r requirements.txt`
- OWASP scan: `dependency-check/Dependency-Check_Action@main`
- Filesystem security scan: `aquasecurity/trivy-action@master` (`scan-type: fs`)
- Artifacts uploaded:
  - `Dependency-Check-Report` (`reports/dependency-check-report.html`)
  - `trivy-fs-vulnerability-assessment-report` (`trivy-fs-results.sarif`)

3. `build-scan-container-job` (image build + image security scan + publish)
- Docker metadata/tags: `docker/metadata-action@v4`
- Build setup: `docker/setup-buildx-action@v2`
- Build image for scan: `docker/build-push-action@v3` (`load: true`, `push: false`)
- Image scan: `aquasecurity/trivy-action@master` (container image SARIF output)
- Artifact uploaded:
  - `trivy-container-vulnerability-assessment-report` (`trivy-container-results.sarif`)
- Push image: `docker/build-push-action@v3` with `if: github.event_name != 'pull_request'`

### PR vs Main Behavior

- Pull requests:
  - Run tests, quality checks, dependency/source/image scans
  - Build image for scanning
  - Do not push image to registry
- Push to `main`:
  - Runs the same checks/scans
  - Pushes image tags (`latest`, `sha-<commit>`, long SHA), if registry auth is configured

### Required Secrets / Notes

- `SONAR_TOKEN` is required for the SonarQube step.
- Docker registry login is required before image push if your registry needs authentication.
- Vulnerability scan steps currently use `exit-code: 0`, so findings are reported but do not fail the workflow.
- This workflow is currently CI/security-focused; there is no deployment step defined.

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
