Here is the professionally formatted GitHub README, with the **content kept unchanged** and only the presentation/Markdown structure improved.

# EC2 Python Deployment V4

A production-style learning project demonstrating how to build, test, authenticate, containerize, and continuously deploy a FastAPI CRUD application backed by MySQL to AWS EC2 using Docker Compose, GitHub Actions, and GitHub Container Registry (GHCR).

V4 builds on the DevOps concepts introduced in V3 while replacing the system-information application with a real API, database, automated tests, and JWT authentication.

---

## 1. Project Overview

V4 demonstrates the complete application lifecycle:

```text
Developer Laptop
       |
       | git push
       v
GitHub Repository
       |
       v
GitHub Actions
       |
       +-- Run automated tests
       |
       +-- Build Docker image
       |
       +-- Push image to GHCR
       |
       +-- SSH deployment
              |
              v
          AWS EC2
              |
          Docker Compose
              |
       +------+------+
       |             |
       v             v
    FastAPI        MySQL
      API          Database
```

The application also includes JWT authentication:

```text
User
 |
 | Register / Login
 v
FastAPI
 |
 +-- Argon2 password hashing
 |
 +-- JWT token
 |
 v
Protected CRUD API
```

The goal is to understand the complete deployment process rather than hiding the infrastructure behind managed services.

---

## 2. Main Technologies

### Application

* Python 3.12
* FastAPI
* Uvicorn
* Pydantic
* SQLAlchemy
* PyMySQL

### Authentication

* JWT
* python-jose
* pwdlib
* Argon2 password hashing
* OAuth2 password flow

### Testing

* pytest
* FastAPI TestClient
* isolated MySQL test database
* authentication test fixtures

### Containers

* Docker
* Docker Compose
* MySQL 8.0

### CI/CD

* GitHub Actions
* GitHub Container Registry (GHCR)
* SSH deployment

### Cloud

* AWS EC2
* AWS Security Groups
* AWS CLI

---

## 3. Project Structure

```text
ec2-python-deployment-v4/
|
+-- app/
|   +-- __init__.py
|   +-- main.py
|   +-- database.py
|   +-- models.py
|   +-- schemas.py
|   +-- crud.py
|   +-- auth.py
|   +-- auth_routes.py
|   +-- auth_schemas.py
|   +-- user_models.py
|
+-- tests/
|   +-- __init__.py
|   +-- conftest.py
|   +-- test_database.py
|   +-- test_items.py
|   +-- test_auth.py
|   +-- test_main.py
|
+-- scripts/
|   |
|   +-- local/
|   |   +-- run_local.sh
|   |   +-- run_docker.sh
|   |
|   +-- aws/
|   |   +-- ec2.sh
|   |   +-- ec2.conf
|   |
|   +-- init_db.py
|
+-- config/
|
+-- .github/
|   +-- workflows/
|       +-- ci.yml
|
+-- Dockerfile
+-- .dockerignore
+-- docker-compose.yml
+-- docker-compose.prod.yml
+-- requirements.txt
+-- .env
+-- .env.example
+-- .gitignore
+-- README.md
```

---

## 4. API

### Endpoints

| Method   | Endpoint         | Purpose                 |
| -------- | ---------------- | ----------------------- |
| `GET`    | `/`              | Application information |
| `GET`    | `/health`        | Health check            |
| `POST`   | `/auth/register` | Register user           |
| `POST`   | `/auth/login`    | Login and receive JWT   |
| `POST`   | `/items`         | Create item             |
| `GET`    | `/items`         | List items              |
| `GET`    | `/items/{id}`    | Get item                |
| `PUT`    | `/items/{id}`    | Update item             |
| `DELETE` | `/items/{id}`    | Delete item             |

The `/items` endpoints require authentication.

A valid JWT must be supplied:

```text
Authorization: Bearer <JWT>
```

Without a valid token:

```text
401 Unauthorized
```

---

## 5. Complete Deployment Process

This section describes the complete process from a fresh project to a running authenticated application on AWS EC2.

The deployment process is:

1. Prepare GitHub repository
2. Prepare local development environment
3. Prepare application
4. Prepare MySQL
5. Prepare authentication
6. Prepare test database
7. Prepare automated tests
8. Prepare Docker
9. Test application locally
10. Test Docker locally
11. Prepare AWS EC2
12. Configure EC2 Docker
13. Configure EC2 SSH access
14. Configure AWS Security Group
15. Configure GHCR
16. Configure GitHub Secrets
17. Configure JWT secret
18. Configure GitHub Actions
19. Configure production Docker Compose
20. Push application
21. Run CI tests
22. Build Docker image
23. Push image to GHCR
24. Deploy image to EC2
25. Verify containers
26. Verify API
27. Test authentication
28. Test CRUD
29. Verify database persistence

---

## 6. Step 1 - Prepare GitHub Repository

Create the repository on GitHub.

Example:

```text
ec2-python-deployment-v4
```

Clone it locally:

```bash
git clone https://github.com/YOUR_USERNAME/ec2-python-deployment-v4.git
```

Enter the project:

```bash
cd ~/Repositeries/ec2-python-deployment-v4
```

> **IMPORTANT:**
> The GitHub repository already exists, so do NOT run:
>
> ```bash
> git init
> ```
>
> and do NOT run:
>
> ```bash
> git remote add origin ...
> ```
>
> The repository already has its GitHub remote.

---

## 7. Step 2 - Prepare Local Python Environment

Check Python:

```bash
python3 --version
```

The project uses Python 3.12.

The local scripts automatically create the virtual environment when necessary.

Run:

```bash
./scripts/local/run_local.sh
```

The script prepares the local Python environment and starts FastAPI.

For automated tests:

```bash
pytest -v
```

The project currently uses:

```text
14 passed
```

---

## 8. Step 3 - Prepare Local MySQL

Create the development database:

```sql
CREATE DATABASE v4_app;
```

Create the application user:

```sql
CREATE USER 'v4user'@'localhost'
IDENTIFIED BY 'YOUR_PASSWORD';
```

Grant permissions:

```sql
GRANT ALL PRIVILEGES
ON v4_app.*
TO 'v4user'@'localhost';
```

Apply:

```sql
FLUSH PRIVILEGES;
```

Test the connection:

```bash
mysql -u v4user -p
```

Then:

```sql
USE v4_app;
```

The local application database is used when running FastAPI directly on the laptop.

---

## 9. Step 4 - Prepare Test Database

Create a separate test database:

```sql
CREATE DATABASE v4_app_test;
```

Grant permissions:

```sql
GRANT ALL PRIVILEGES
ON v4_app_test.*
TO 'v4user'@'localhost';
```

Apply:

```sql
FLUSH PRIVILEGES;
```

Tests must not use the normal development database.

The test suite uses:

```text
v4_app_test
```

This prevents automated tests from accidentally modifying normal development data.

---

## 10. Step 5 - Prepare JWT Authentication

V4 now includes JWT authentication.

The authentication flow is:

```text
Register
   |
   v
Username + Password
   |
   v
Argon2 password hash
   |
   v
MySQL users table
```

Login:

```text
Username + Password
   |
   v
Verify password
   |
   v
Create JWT
   |
   v
Return access token
```

Protected request:

```text
Client
   |
   | Authorization: Bearer JWT
   v
FastAPI
   |
   v
Validate JWT
   |
   v
Protected CRUD endpoint
```

The JWT implementation is located in:

```text
app/auth.py
```

Authentication routes:

```text
app/auth_routes.py
```

Authentication schemas:

```text
app/auth_schemas.py
```

User database model:

```text
app/user_models.py
```

---

## 11. Step 6 - Prepare JWT Secret

Generate a secure random secret:

```bash
openssl rand -hex 32
```

Create the local environment file:

```bash
cp .env.example .env
```

Edit `.env`:

```text
JWT_SECRET_KEY=YOUR_GENERATED_SECRET
```

The `.env` file must never be committed to Git.

The JWT secret is used by FastAPI to sign and verify JWT tokens.

The application uses:

```text
Algorithm:
HS256

Default token lifetime:
30 minutes
```

---

## 12. Step 7 - Test Application Locally

Run:

```bash
./scripts/local/run_local.sh
```

Application:

```text
http://127.0.0.1:8000
```

Swagger:

```text
http://127.0.0.1:8000/docs
```

Health:

```text
http://127.0.0.1:8000/health
```

The local application uses the local MySQL database.

Stop the application with:

```text
CTRL+C
```

---

## 13. Step 8 - Test Authentication Locally

Open:

```text
http://127.0.0.1:8000/docs
```

Register:

```text
POST /auth/register
```

Example:

```json
{
  "username": "saman",
  "password": "password123"
}
```

Login:

```text
POST /auth/login
```

The login endpoint returns:

```json
{
  "access_token": "JWT_TOKEN",
  "token_type": "bearer"
}
```

Copy the token into Swagger using:

```text
Authorize
```

Then enter:

```text
Bearer <JWT>
```

The protected `/items` endpoints can now be used.

---

## 14. Step 9 - Test CRUD Locally

After authentication, test:

```text
POST /items
```

Example:

```json
{
  "name": "Laptop",
  "description": "Development laptop",
  "price": 1500
}
```

Read:

```text
GET /items
```

Read one:

```text
GET /items/{id}
```

Update:

```text
PUT /items/{id}
```

Delete:

```text
DELETE /items/{id}
```

Verify:

```text
GET /items/{id}
```

Expected after deletion:

```text
404 Not Found
```

---

## 15. Step 10 - Run Automated Tests

Run:

```bash
pytest -v
```

The current test suite covers:

```text
Application
Database
Authentication
Registration
Login
Invalid credentials
JWT authentication
Protected endpoints
CRUD
```

Current result:

```text
14 passed
```

There is currently one non-blocking warning related to the Starlette/httpx test client.

The warning does not cause the tests to fail.

---

## 16. Step 11 - Prepare Docker

Check Docker:

```bash
docker --version
```

Check Compose:

```bash
docker compose version
```

Build the application:

```bash
docker compose build
```

Start:

```bash
docker compose up
```

Or run in background:

```bash
docker compose up -d
```

Check:

```bash
docker compose ps
```

Logs:

```bash
docker compose logs
```

---

## 17. Step 12 - Test Docker Locally

The local Docker architecture is:

```text
Host
 |
 | TCP 8000
 v
FastAPI container
 |
 | Docker network
 v
MySQL container
 |
 v
mysql_data volume
```

Only FastAPI exposes a host port.

MySQL does NOT expose port 3306 to the host.

The API connects internally using:

```text
mysql:3306
```

The recommended local Docker command is:

```bash
./scripts/local/run_docker.sh
```

Check:

```bash
docker compose ps
```

Test:

```bash
curl http://127.0.0.1:8000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

Swagger:

```text
http://127.0.0.1:8000/docs
```

---

## 18. Step 13 - Test Docker Authentication and CRUD

Open:

```text
http://127.0.0.1:8000/docs
```

Test:

```text
POST   /auth/register
POST   /auth/login
```

Authorize with the returned JWT.

Then test:

```text
POST   /items
GET    /items
GET    /items/{id}
PUT    /items/{id}
DELETE /items/{id}
```

If authentication and CRUD work through Docker, the application is ready for cloud deployment.

---

## 19. Step 14 - Prepare AWS EC2

Create or use an EC2 instance.

Recommended learning configuration:

**Operating System:**

```text
Ubuntu
```

**Architecture:**

```text
x86_64
```

**Region:**

```text
YOUR_AWS_REGION
```

Example:

```text
us-east-1
```

Make sure the EC2 instance has enough disk space for:

* Docker
* Docker images
* MySQL
* application logs
* database volume

---

## 20. Step 15 - Prepare SSH Key

Create or use an EC2 SSH key.

Example:

```text
my-key.pem
```

Never commit the key.

Never put it inside the Git repository.

Set permissions:

```bash
chmod 400 ~/path/to/my-key.pem
```

> **IMPORTANT:**
> Never paste a private SSH key into GitHub, README files, chat, source code, or Git.

---

## 21. Step 16 - Prepare EC2 Configuration

Create:

```text
scripts/aws/ec2.conf
```

Example:

```bash
AWS_REGION="us-east-1"

EC2_INSTANCE_ID="YOUR_INSTANCE_ID"

EC2_USER="ubuntu"

SSH_KEY="/path/to/YOUR-KEY.pem"
```

Add this file to `.gitignore`:

```text
scripts/aws/ec2.conf
```

The configuration contains machine-specific information and the location of the private SSH key.

---

## 22. Step 17 - Test EC2 Connection

Make the script executable:

```bash
chmod +x scripts/aws/ec2.sh
```

Check EC2:

```bash
./scripts/aws/ec2.sh status
```

Get IP:

```bash
./scripts/aws/ec2.sh ip
```

SSH:

```bash
./scripts/aws/ec2.sh ssh
```

---

## 23. Step 18 - Prepare EC2 Docker

From the laptop:

```bash
./scripts/aws/ec2.sh setup
```

The setup process should ensure:

* Docker installed
* Docker service enabled
* Docker service running
* Docker Compose available
* ubuntu user can run Docker
* application directory exists

The application directory is:

```text
/home/ubuntu/v4-app
```

---

## 24. Step 19 - Verify Docker on EC2

SSH:

```bash
./scripts/aws/ec2.sh ssh
```

Check Docker:

```bash
docker --version
```

Check Compose:

```bash
docker compose version
```

Check Docker access:

```bash
docker ps
```

Check Docker service:

```bash
sudo systemctl status docker
```

If `docker ps` gives permission errors, check:

```bash
id -nG
```

The ubuntu user should be in:

```text
docker
```

---

## 25. Step 20 - Configure AWS Security Group

The EC2 security group must allow SSH:

```text
TCP 22
```

For the API:

```text
TCP 8000
```

For learning/testing, port 8000 may temporarily use:

```text
0.0.0.0/0
```

A more restricted rule is preferable:

```text
YOUR_PUBLIC_IP/32
```

Do NOT expose:

```text
TCP 3306
```

MySQL must remain private.

---

## 26. Step 21 - Production Architecture

Production architecture:

```text
Internet
 |
 | TCP 8000
 v
AWS EC2
 |
 +-----------------------------+
 |                             |
 | Docker                      |
 |                             |
 |   +---------------------+   |
 |   | FastAPI             |   |
 |   | Port 8000           |   |
 |   +----------+----------+   |
 |              |              |
 |              | mysql:3306   |
 |              v              |
 |   +---------------------+   |
 |   | MySQL               |   |
 |   | Port 3306 internal  |   |
 |   +----------+----------+   |
 |              |              |
 |        mysql_data volume    |
 +-----------------------------+
```

Authentication is handled by FastAPI:

```text
Client
 |
 v
FastAPI
 |
 +-- JWT authentication
 |
 +-- Protected CRUD
 |
 v
MySQL
```

---

## 27. Step 22 - Prepare Production Compose

The production file is:

```text
docker-compose.prod.yml
```

It defines:

* FastAPI container
* MySQL container
* MySQL persistent volume
* health check
* restart policy
* internal Docker networking
* JWT environment variable

The API image is supplied by:

```text
IMAGE_NAME
```

Example:

```text
ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4
```

The production environment also contains:

```text
JWT_SECRET_KEY
```

The JWT secret is stored in the EC2 `.env` file created by GitHub Actions.

---

## 28. Step 23 - Prepare GHCR

GitHub Actions builds and pushes the Docker image to:

```text
GitHub Container Registry
```

Example:

```text
ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4
```

For the simple learning deployment, the package can be public so EC2 can pull it without authentication.

For private packages, EC2 needs GHCR authentication.

---

## 29. Step 24 - Prepare GitHub Secrets

Add these repository secrets:

```text
EC2_HOST

EC2_USER

EC2_SSH_KEY

JWT_SECRET_KEY
```

Example:

**EC2_HOST:**

```text
EC2 public IP or hostname
```

**EC2_USER:**

```text
ubuntu
```

**EC2_SSH_KEY:**

```text
contents of the private SSH key
```

**JWT_SECRET_KEY:**

```text
generated JWT signing secret
```

Never print the private key.

Never print the JWT secret.

GitHub automatically masks secret values in workflow logs.

---

## 30. Step 25 - Prepare GitHub Actions

The workflow is:

```text
.github/workflows/ci.yml
```

Pipeline:

```text
Push
 |
 v
Run Tests
 |
 | success
 v
Build Docker Image
 |
 v
Push to GHCR
 |
 v
Deploy to EC2
```

The test job runs before the image is built.

The deployment job only runs after a successful image build.

---

## 31. Step 26 - Test GitHub Actions

Before deploying, commit and push:

```bash
git status

git add .

git commit -m "feat: deploy V4 application"

git push origin main
```

GitHub Actions should execute:

1. Test
2. Build
3. Push
4. Deploy

---

## 32. Step 27 - GitHub Actions Test Job

The test job starts MySQL 8.0 as a GitHub Actions service.

It runs:

```bash
pytest -v
```

Expected:

```text
14 passed
```

The test job must pass before the Docker image is built.

The tests include authentication and protected CRUD operations.

---

## 33. Step 28 - Build Docker Image

After tests pass, GitHub Actions builds:

```text
Dockerfile
```

The image contains:

* Python runtime
* Python dependencies
* FastAPI application
* authentication code
* database initialization script

The container starts by creating database tables and then starts Uvicorn.

---

## 34. Step 29 - Push Image to GHCR

GitHub Actions pushes the image to:

```text
ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4
```

The deployment uses:

```text
latest
```

and SHA-based tags.

---

## 35. Step 30 - Deploy to EC2

GitHub Actions connects through SSH.

The deployment process:

1. Creates SSH configuration
2. Connects to EC2
3. Creates `~/v4-app`
4. Copies `docker-compose.prod.yml`
5. Creates production `.env`
6. Writes `JWT_SECRET_KEY`
7. Validates the environment file
8. Validates Docker Compose
9. Pulls the GHCR image
10. Starts Docker Compose
11. Displays container status

The remote directory is:

```text
/home/ubuntu/v4-app
```

The production environment file is:

```text
/home/ubuntu/v4-app/.env
```

The `.env` file is protected with restrictive permissions.

---

## 36. Step 31 - Verify Deployment

From the laptop:

```bash
./scripts/aws/ec2.sh app-status
```

Expected:

```text
v4_api
v4_mysql
```

Both should be running.

Check logs:

```bash
./scripts/aws/ec2.sh logs
```

---

## 37. Step 32 - Verify FastAPI

Open:

```text
http://EC2_PUBLIC_IP:8000
```

Expected:

```json
{
  "message": "Hello, World!",
  "version": "4.0.0"
}
```

Health:

```text
http://EC2_PUBLIC_IP:8000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

---

## 38. Step 33 - Open Swagger

Open:

```text
http://EC2_PUBLIC_IP:8000/docs
```

Swagger should show:

```text
GET     /
GET     /health

POST    /auth/register
POST    /auth/login

POST    /items
GET     /items
GET     /items/{id}
PUT     /items/{id}
DELETE  /items/{id}
```

The item endpoints require JWT authentication.

---

## 39. Step 34 - Test Production Authentication

Register:

```text
POST /auth/register
```

Example:

```json
{
  "username": "saman",
  "password": "password123"
}
```

Login:

```text
POST /auth/login
```

Expected response:

```json
{
  "access_token": "JWT_TOKEN",
  "token_type": "bearer"
}
```

Authorize in Swagger.

Then use:

```text
POST /items
```

and the other protected endpoints.

Test an unauthenticated request as well.

Expected:

```text
401 Unauthorized
```

---

## 40. Step 35 - Test Production CRUD

Create:

```text
POST /items
```

Example:

```json
{
  "name": "AWS Laptop",
  "description": "Created on EC2",
  "price": 1500
}
```

Read:

```text
GET /items
```

Read one:

```text
GET /items/{id}
```

Update:

```text
PUT /items/{id}
```

Example:

```json
{
  "name": "AWS Developer Laptop",
  "description": "Updated on EC2",
  "price": 1800
}
```

Delete:

```text
DELETE /items/{id}
```

Verify:

```text
GET /items/{id}
```

Expected:

```text
404 Not Found
```

---

## 41. Step 36 - Test Database Persistence

Create an item.

Then restart the application:

```bash
./scripts/aws/ec2.sh restart
```

Check:

```bash
./scripts/aws/ec2.sh app-status
```

Then:

```text
GET /items
```

The data should still exist.

Why?

Because MySQL uses:

```text
mysql_data
```

Docker volume.

Restarting containers does not delete the volume.

---

## 42. Step 37 - Final End-to-End Test

The final test is:

```text
Laptop
 |
 | git push
 v
GitHub
 |
 v
GitHub Actions
 |
 +-- pytest
 |
 +-- Docker build
 |
 +-- GHCR push
 |
 +-- SSH
      |
      v
     EC2
      |
      v
Docker Compose
      |
      +-- FastAPI
      |
      +-- MySQL
             |
             v
        JWT Authentication
             |
             v
          CRUD API
```

A successful V4 deployment means every stage above works.

---

## 43. Local Commands

Run application directly:

```bash
./scripts/local/run_local.sh
```

Run application with Docker:

```bash
./scripts/local/run_docker.sh
```

Run tests:

```bash
pytest -v
```

Docker start:

```bash
docker compose up -d
```

Docker stop:

```bash
docker compose down
```

Docker rebuild:

```bash
docker compose up --build
```

Docker status:

```bash
docker compose ps
```

Docker logs:

```bash
docker compose logs
```

API logs:

```bash
docker compose logs api
```

MySQL logs:

```bash
docker compose logs mysql
```

---

## 44. EC2 Commands

Status:

```bash
./scripts/aws/ec2.sh status
```

IP:

```bash
./scripts/aws/ec2.sh ip
```

Start:

```bash
./scripts/aws/ec2.sh start
```

Stop:

```bash
./scripts/aws/ec2.sh stop
```

Reboot:

```bash
./scripts/aws/ec2.sh reboot
```

SSH:

```bash
./scripts/aws/ec2.sh ssh
```

Setup:

```bash
./scripts/aws/ec2.sh setup
```

Application status:

```bash
./scripts/aws/ec2.sh app-status
```

Application logs:

```bash
./scripts/aws/ec2.sh logs
```

Application restart:

```bash
./scripts/aws/ec2.sh restart
```

Application stop:

```bash
./scripts/aws/ec2.sh app-stop
```

---

## 45. EC2 Manual Troubleshooting

SSH:

```bash
./scripts/aws/ec2.sh ssh
```

Docker version:

```bash
docker --version
```

Compose version:

```bash
docker compose version
```

Docker containers:

```bash
docker ps
```

All containers:

```bash
docker ps -a
```

Docker service:

```bash
sudo systemctl status docker
```

Docker service logs:

```bash
sudo journalctl -u docker
```

Docker group:

```bash
id -nG
```

---

## 46. Production Troubleshooting

Application status:

```bash
cd ~/v4-app

docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  ps
```

Application logs:

```bash
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  logs --tail=100 api
```

MySQL logs:

```bash
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  logs --tail=100 mysql
```

All logs:

```bash
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  logs --tail=100
```

Pull latest image:

```bash
IMAGE_NAME=ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4 \
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  pull
```

Start:

```bash
IMAGE_NAME=ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4 \
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  up -d
```

Restart:

```bash
docker compose \
  --env-file .env \
  -f docker-compose.prod.yml \
  restart
```

---

## 47. Problem - Docker App Could Not Import App

Error:

```text
ModuleNotFoundError: No module named 'app'
```

Cause:

The Python module path inside the Docker container did not include:

```text
/app
```

Fix:

Add to Dockerfile:

```dockerfile
ENV PYTHONPATH=/app
```

Rebuild:

```bash
docker compose build
```

Start:

```bash
docker compose up
```

---

## 48. Problem - Local MySQL Port Conflict

The Ubuntu laptop already had MySQL running on:

```text
3306
```

Docker MySQL attempted to use the same host port.

Fix:

Do not expose MySQL to the host.

FastAPI connects internally using:

```text
mysql:3306
```

Only FastAPI exposes:

```text
8000:8000
```

---

## 49. Problem - Tests Used Development Database

Cause:

Tests were using the normal application database.

Risk:

Tests could modify development data.

Fix:

Create:

```text
v4_app_test
```

Use:

```text
tests/conftest.py
```

The tests override FastAPI's database dependency and use the isolated test database.

---

## 50. Problem - MySQL Missing in GitHub Actions

Cause:

GitHub Actions does not automatically provide MySQL.

Fix:

Use a MySQL service:

```yaml
mysql:
  image: mysql:8.0
```

The CI test environment therefore has its own MySQL instance.

---

## 51. Problem - Deployment File Not Found

Error:

```text
docker-compose.prod.yml not found
```

Cause:

GitHub Actions jobs run on separate fresh runners.

The deploy job had not checked out the repository.

Fix:

Add:

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

to the deploy job.

---

## 52. Problem - Docker Permission Denied

Error:

```text
permission denied while trying to connect to the Docker daemon socket
```

Cause:

The ubuntu user was not in the Docker group.

Fix:

```bash
sudo usermod -aG docker $USER
```

Exit:

```bash
exit
```

Reconnect.

Verify:

```bash
docker ps
```

If necessary:

```bash
id -nG
```

---

## 53. Problem - Docker Compose Package Conflict

Error:

```text
trying to overwrite:
/usr/libexec/docker/cli-plugins/docker-compose
```

Cause:

Conflicting Docker Compose packages were installed.

Packages involved included:

```text
docker-compose-v2
```

and:

```text
docker-compose-plugin
```

Repair:

```bash
sudo dpkg --configure -a

sudo apt-get -f install -y
```

Remove conflicting package when required:

```bash
sudo apt-get remove -y docker-compose-v2
```

Then verify:

```bash
docker compose version
```

---

## 54. Problem - Docker Compose Command Unknown

Error:

```text
docker: unknown command: docker compose
```

Cause:

Docker was installed but the Compose CLI plugin was unavailable.

Verify:

```bash
docker compose version
```

Install/configure Docker Compose using the package source appropriate for the EC2 Ubuntu/Docker installation.

Verify again:

```bash
docker compose version
```

---

## 55. Problem - Exit Code 125

GitHub Actions:

```text
Process completed with exit code 125
```

Useful error:

```text
unknown shorthand flag: 'f' in -f
```

Cause:

```text
docker compose
```

was not available on EC2.

Docker interpreted the command incorrectly.

Fix:

Install/configure Docker Compose.

Verify:

```bash
docker compose version
```

Then rerun deployment.

---

## 56. Problem - GitHub Actions Logs Appeared Empty

Sometimes the GitHub Actions web interface may fail to display logs correctly.

Before changing a working workflow:

1. Refresh the browser
2. Try another browser
3. Try private/incognito mode
4. Open the individual job step
5. Download the workflow logs if necessary

Do not assume an empty UI means the workflow produced no output.

---

## 57. Problem - Laptop Works but Phone Cannot Connect

Cause:

The EC2 Security Group may only allow the laptop's public IP.

The phone may use a different public IP.

Check:

```text
AWS EC2
-> Instance
-> Security
-> Security Groups
-> Inbound rules
```

Allow:

```text
TCP 8000
```

For temporary testing:

```text
0.0.0.0/0
```

More restrictive:

```text
YOUR_PUBLIC_IP/32
```

---

## 58. Problem - MySQL Should Not Be Public

Never solve API connectivity problems by opening:

```text
3306
```

to:

```text
0.0.0.0/0
```

Correct:

```text
Internet
 |
 v
EC2 :8000
 |
 v
FastAPI
 |
 v
Docker network
 |
 v
MySQL :3306
```

---

## 59. Problem - JWT Secret Not Configured

If the application reports that:

```text
JWT_SECRET_KEY
```

is missing, check the local `.env` file.

For local development:

```text
.env
```

should contain:

```text
JWT_SECRET_KEY=YOUR_GENERATED_SECRET
```

Generate a new secret:

```bash
openssl rand -hex 32
```

For production, the JWT secret is supplied through the GitHub Actions secret:

```text
JWT_SECRET_KEY
```

GitHub Actions creates:

```text
/home/ubuntu/v4-app/.env
```

on EC2 during deployment.

Never commit the production `.env`.

---

## 60. GitHub Troubleshooting

Check recent commits:

```bash
git log --oneline --decorate -10
```

Check status:

```bash
git status
```

Check workflow file:

```bash
git show HEAD:.github/workflows/ci.yml
```

Check production Compose file:

```bash
git show HEAD:docker-compose.prod.yml
```

Check tracked production file:

```bash
git ls-files docker-compose.prod.yml
```

Push:

```bash
git push origin main
```

---

## 61. Docker Troubleshooting Checklist

If the API does not start:

1. Check containers:

```bash
docker compose ps
```

2. Check API logs:

```bash
docker compose logs api
```

3. Check MySQL:

```bash
docker compose logs mysql
```

4. Check Compose:

```bash
docker compose version
```

5. Rebuild:

```bash
docker compose up --build
```

6. If necessary, reset:

```bash
docker compose down -v
docker compose up --build
```

> **Be careful:**
>
> ```bash
> docker compose down -v
> ```
>
> removes the local MySQL volume and therefore deletes the local database data.

---

## 62. EC2 Deployment Checklist

Before deployment:

```text
[ ] EC2 exists

[ ] EC2 is running

[ ] SSH key works

[ ] ec2.conf is configured

[ ] Docker installed

[ ] Docker Compose installed

[ ] Docker service running

[ ] ubuntu can run Docker

[ ] Security Group allows SSH

[ ] Security Group allows TCP 8000

[ ] MySQL port 3306 is NOT public

[ ] GHCR package exists

[ ] GitHub Secrets configured

[ ] JWT_SECRET_KEY configured

[ ] docker-compose.prod.yml committed

[ ] ci.yml committed

[ ] .env is not committed
```

---

## 63. CI/CD Checklist

Push to main.

Verify:

```text
[ ] GitHub Actions starts

[ ] MySQL service starts

[ ] pytest passes

[ ] Authentication tests pass

[ ] Docker image builds

[ ] GHCR login succeeds

[ ] Docker image pushes

[ ] SSH connection succeeds

[ ] docker-compose.prod.yml copies to EC2

[ ] Production .env is created

[ ] JWT_SECRET_KEY is available

[ ] Docker Compose configuration validates

[ ] GHCR image pulls

[ ] Docker Compose starts

[ ] v4_api is running

[ ] v4_mysql is running
```

---

## 64. Application Checklist

Verify:

```text
[ ] GET /

[ ] GET /health

[ ] GET /docs

[ ] POST /auth/register

[ ] POST /auth/login

[ ] JWT authorization works

[ ] POST /items

[ ] GET /items

[ ] GET /items/{id}

[ ] PUT /items/{id}

[ ] DELETE /items/{id}

[ ] Unauthorized requests return 401
```

Then restart:

```bash
./scripts/aws/ec2.sh restart
```

Verify data persistence.

---

## 65. Security Notes

Never commit:

```text
*.pem
```

Private SSH keys.

Never commit:

```text
scripts/aws/ec2.conf
```

Never commit:

```text
.env
```

Never commit:

* AWS access keys
* GitHub tokens
* passwords
* production secrets
* database credentials
* JWT secrets

Use GitHub Secrets for CI/CD credentials:

```text
EC2_HOST

EC2_USER

EC2_SSH_KEY

JWT_SECRET_KEY
```

Do not expose:

```text
3306
```

to the public internet.

Passwords are stored as Argon2 hashes rather than plaintext.

JWT signing uses the secret stored outside the source code.

For a real production system, improve security with:

* HTTPS
* reverse proxy
* domain name
* TLS certificates
* AWS Secrets Manager
* private database networking
* restrictive Security Groups
* non-root containers
* database migrations
* backups
* monitoring
* centralized logging
* infrastructure as code

---

## 66. V4 Development Progression

### V4.1

FastAPI foundation

```text
    |
    v
```

### V4.2

MySQL + SQLAlchemy

```text
    |
    v
```

### V4.3

CRUD + isolated automated tests

```text
    |
    v
```

### V4.4

Docker Compose

```text
    |
    v
```

### V4.5

GitHub Actions + GHCR

```text
    |
    v
```

### V4.6

AWS EC2 deployment

```text
    |
    v
```

### V4.7

JWT authentication

---

## 67. Final Architecture

```text
                    Developer

                        |

                        | git push

                        v

                 GitHub Repository

                        |

                        v

                GitHub Actions

                        |

         +--------------+--------------+

         |              |              |

         v              v              v

       Tests         Docker          Deploy

         |            Build             |

         |              |               |

         +--------------+               |

                        |               |

                        v               |

                       GHCR             |

                        |               |

                        +-------+-------+

                                |

                                | SSH

                                v

                          AWS EC2

                                |

                        Docker Compose

                                |

                   +------------+------------+

                   |                         |

                   v                         v

              FastAPI API                 MySQL

                :8000                    :3306

                   |                         |

                   | JWT                     |

                   v                         |

              Authentication                |

                   |                         |

                   +------------+------------+

                                |

                          Docker network

                                |

                          mysql_data volume
```

### Application Authentication Flow

```text
                 Client
                    |
                    v
             FastAPI /auth
                    |
          +---------+---------+
          |                   |
          v                   v
      Register              Login
          |                   |
          v                   v
      Argon2 hash        Verify password
          |                   |
          v                   v
        MySQL              Create JWT
                              |
                              v
                         Access Token
                              |
                              v
                     Authorization Header
                              |
                              v
                    Protected /items API
                              |
                              v
                            MySQL
```

---

## 68. V4 Status

```text
V4.1  FastAPI foundation             COMPLETE

V4.2  MySQL + SQLAlchemy             COMPLETE

V4.3  CRUD + automated tests         COMPLETE

V4.4  Docker Compose                 COMPLETE

V4.5  CI/CD + GHCR                   COMPLETE

V4.6  AWS EC2 deployment             COMPLETE

V4.7  JWT authentication             COMPLETE
```

Current automated test result:

```text
14 passed
```

---

## 69. Final Result

V4 provides a complete learning-oriented DevOps pipeline:

```text
FastAPI

+

MySQL

+

SQLAlchemy

+

JWT Authentication

+

Argon2 Password Hashing

+

Automated Tests

+

Docker

+

Docker Compose

+

GitHub Actions

+

GHCR

+

AWS EC2

+

SSH Deployment

+

Operational Scripts

=

Complete CI/CD Deployment Pipeline
```

The application can now be run in three environments:

```text
1. Directly on the Ubuntu laptop

2. Inside Docker on the Ubuntu laptop

3. Inside Docker on AWS EC2
```

Local direct execution:

```bash
./scripts/local/run_local.sh
```

Local Docker execution:

```bash
./scripts/local/run_docker.sh
```

AWS production management:

```bash
./scripts/aws/ec2.sh app-status
```

V4 IS COMPLETE.
