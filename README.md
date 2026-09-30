# ec2-python-deployment-v4sd"assgitd# EC2 Python Deployment V4

A production-style learning project demonstrating how to build, test, containerize, and continuously deploy a FastAPI CRUD application backed by MySQL to AWS EC2 using Docker Compose, GitHub Actions, and GitHub Container Registry (GHCR).

V4 builds on the DevOps concepts introduced in V3 while replacing the system-information application with a real API and database.

======================================================================
1. PROJECT OVERVIEW
======================================================================

V4 demonstrates the complete application lifecycle:

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


The goal is to understand the complete deployment process rather than
hiding the infrastructure behind managed services.


======================================================================
2. MAIN TECHNOLOGIES
======================================================================

Application:

- Python 3.12
- FastAPI
- Uvicorn
- Pydantic
- SQLAlchemy
- PyMySQL

Testing:

- pytest
- FastAPI TestClient
- isolated MySQL test database

Containers:

- Docker
- Docker Compose
- MySQL 8.0

CI/CD:

- GitHub Actions
- GitHub Container Registry (GHCR)
- SSH deployment

Cloud:

- AWS EC2
- AWS Security Groups


======================================================================
3. PROJECT STRUCTURE
======================================================================

ec2-python-deployment-v4/
|
+-- app/
|   +-- __init__.py
|   +-- main.py
|   +-- database.py
|   +-- models.py
|   +-- schemas.py
|   +-- crud.py
|
+-- tests/
|   +-- __init__.py
|   +-- conftest.py
|   +-- test_database.py
|   +-- test_items.py
|
+-- scripts/
|   |
|   +-- local/
|   |   +-- run.sh
|   |   +-- test.sh
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
+-- .gitignore
+-- README.md


======================================================================
4. API
======================================================================

Endpoints:

Method    Endpoint             Purpose
------    ------------------   --------------------------
GET       /                    Application information
GET       /health              Health check
POST      /items               Create item
GET       /items               List items
GET       /items/{id}          Get item
PUT       /items/{id}          Update item
DELETE    /items/{id}          Delete item


======================================================================
5. COMPLETE DEPLOYMENT PROCESS
======================================================================

This section describes the complete process from a fresh project to a
running application on AWS EC2.

The deployment process is:

1. Prepare GitHub repository
2. Prepare local development environment
3. Prepare application
4. Prepare MySQL
5. Prepare automated tests
6. Prepare Docker
7. Test Docker locally
8. Prepare AWS EC2
9. Configure EC2 Docker
10. Configure EC2 SSH access
11. Configure AWS Security Group
12. Configure GHCR
13. Configure GitHub Secrets
14. Configure GitHub Actions
15. Configure production Docker Compose
16. Push application
17. Run CI tests
18. Build Docker image
19. Push image to GHCR
20. Deploy image to EC2
21. Verify containers
22. Verify API
23. Test CRUD
24. Verify database persistence


======================================================================
6. STEP 1 - PREPARE GITHUB REPOSITORY
======================================================================

Create the repository on GitHub.

Example:

ec2-python-deployment-v4

Clone it locally:

git clone https://github.com/YOUR_USERNAME/ec2-python-deployment-v4.git

Enter the project:

cd ~/Repositeries/ec2-python-deployment-v4

IMPORTANT:

The GitHub repository already exists, so do NOT run:

git init

and do NOT run:

git remote add origin ...

The repository already has its GitHub remote.


======================================================================
7. STEP 2 - PREPARE LOCAL PYTHON ENVIRONMENT
======================================================================

Check Python:

python3 --version

The project uses Python 3.12.

The project scripts automatically create the virtual environment.

Run:

./scripts/local/test.sh

The script:

1. Checks Python
2. Creates .venv if necessary
3. Activates .venv
4. Upgrades pip
5. Installs requirements.txt
6. Runs pytest


======================================================================
8. STEP 3 - PREPARE LOCAL MYSQL
======================================================================

Create the development database:

CREATE DATABASE v4_app;

Create the application user:

CREATE USER 'v4user'@'localhost'
IDENTIFIED BY 'YOUR_PASSWORD';

Grant permissions:

GRANT ALL PRIVILEGES
ON v4_app.*
TO 'v4user'@'localhost';

Apply:

FLUSH PRIVILEGES;

Test the connection:

mysql -u v4user -p

Then:

USE v4_app;


======================================================================
9. STEP 4 - PREPARE TEST DATABASE
======================================================================

Create a separate test database:

CREATE DATABASE v4_app_test;

Grant permissions:

GRANT ALL PRIVILEGES
ON v4_app_test.*
TO 'v4user'@'localhost';

Apply:

FLUSH PRIVILEGES;

Tests must not use the normal development database.

The test suite uses:

v4_app_test


======================================================================
10. STEP 5 - TEST APPLICATION LOCALLY
======================================================================

Run:

./scripts/local/test.sh

Expected result:

9 passed

Then run the API:

./scripts/local/run.sh

Application:

http://127.0.0.1:8000

Swagger:

http://127.0.0.1:8000/docs

Health:

http://127.0.0.1:8000/health


======================================================================
11. STEP 6 - TEST CRUD LOCALLY
======================================================================

Create an item:

POST /items

Example:

{
  "name": "Laptop",
  "description": "Development laptop",
  "price": 1500
}

Read:

GET /items

Read one:

GET /items/{id}

Update:

PUT /items/{id}

Delete:

DELETE /items/{id}

Verify:

GET /items/{id}

Expected after deletion:

404 Not Found


======================================================================
12. STEP 7 - PREPARE DOCKER
======================================================================

Check Docker:

docker --version

Check Compose:

docker compose version

Build the application:

docker compose build

Start:

docker compose up

Or run in background:

docker compose up -d

Check:

docker compose ps

Logs:

docker compose logs


======================================================================
13. STEP 8 - TEST DOCKER LOCALLY
======================================================================

The local Docker architecture is:

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


Only FastAPI exposes a host port.

MySQL does NOT expose port 3306 to the host.

The API connects internally using:

mysql:3306


Check:

docker compose ps

Test:

curl http://127.0.0.1:8000/health

Expected:

{
  "status": "healthy"
}


======================================================================
14. STEP 9 - TEST DOCKER CRUD
======================================================================

Open:

http://127.0.0.1:8000/docs

Test:

POST /items
GET /items
GET /items/{id}
PUT /items/{id}
DELETE /items/{id}

If all CRUD operations work through Docker, the application is ready
for cloud deployment.


======================================================================
15. STEP 10 - PREPARE AWS EC2
======================================================================

Create or use an EC2 instance.

Recommended learning configuration:

Operating System:

Ubuntu

Architecture:

x86_64

Region:

YOUR_AWS_REGION

Example:

us-east-1

Make sure the EC2 instance has enough disk space for:

- Docker
- Docker images
- MySQL
- application logs
- database volume


======================================================================
16. STEP 11 - PREPARE SSH KEY
======================================================================

Create or use an EC2 SSH key.

Example:

my-key.pem

Never commit the key.

Never put it inside the Git repository.

Set permissions:

chmod 400 ~/path/to/my-key.pem

IMPORTANT:

Never paste a private SSH key into GitHub, README files, chat,
source code, or Git.


======================================================================
17. STEP 12 - PREPARE EC2 CONFIGURATION
======================================================================

Create:

scripts/aws/ec2.conf

Example:

AWS_REGION="us-east-1"
EC2_INSTANCE_ID="YOUR_INSTANCE_ID"
EC2_USER="ubuntu"
EC2_KEY="$HOME/path/to/YOUR-KEY.pem"

Add this file to .gitignore:

scripts/aws/ec2.conf

The configuration contains machine-specific information and the
location of the private SSH key.


======================================================================
18. STEP 13 - TEST EC2 CONNECTION
======================================================================

Make the script executable:

chmod +x scripts/aws/ec2.sh

Check EC2:

./scripts/aws/ec2.sh status

Get IP:

./scripts/aws/ec2.sh ip

SSH:

./scripts/aws/ec2.sh ssh


======================================================================
19. STEP 14 - PREPARE EC2 DOCKER
======================================================================

From the laptop:

./scripts/aws/ec2.sh setup

The setup process should ensure:

- Docker installed
- Docker service enabled
- Docker service running
- Docker Compose available
- ubuntu user can run Docker
- application directory exists


======================================================================
20. STEP 15 - VERIFY DOCKER ON EC2
======================================================================

SSH:

./scripts/aws/ec2.sh ssh

Check Docker:

docker --version

Check Compose:

docker compose version

Check Docker access:

docker ps

Check Docker service:

sudo systemctl status docker

If docker ps gives permission errors, check:

id -nG

The ubuntu user should be in:

docker


======================================================================
21. STEP 16 - CONFIGURE AWS SECURITY GROUP
======================================================================

The EC2 security group must allow SSH:

TCP 22

For the API:

TCP 8000

For learning/testing, port 8000 may temporarily use:

0.0.0.0/0

A more restricted rule is preferable:

YOUR_PUBLIC_IP/32

Do NOT expose:

TCP 3306

MySQL must remain private.


======================================================================
22. STEP 17 - PRODUCTION ARCHITECTURE
======================================================================

Production architecture:

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


======================================================================
23. STEP 18 - PREPARE PRODUCTION COMPOSE
======================================================================

The production file is:

docker-compose.prod.yml

It defines:

- FastAPI container
- MySQL container
- MySQL persistent volume
- health check
- restart policy
- internal Docker networking

The API image is supplied by:

IMAGE_NAME

Example:

ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4


======================================================================
24. STEP 19 - PREPARE GHCR
======================================================================

GitHub Actions builds and pushes the Docker image to:

GitHub Container Registry

Example:

ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4

For the simple learning deployment, the package can be public so EC2
can pull it without authentication.

For private packages, EC2 needs GHCR authentication.


======================================================================
25. STEP 20 - PREPARE GITHUB SECRETS
======================================================================

Add these repository secrets:

EC2_HOST
EC2_USER
EC2_SSH_KEY

Example:

EC2_HOST
    EC2 public IP or hostname

EC2_USER
    ubuntu

EC2_SSH_KEY
    contents of the private SSH key

Never print the private key.

GitHub automatically masks secret values in workflow logs.


======================================================================
26. STEP 21 - PREPARE GITHUB ACTIONS
======================================================================

The workflow is:

.github/workflows/ci.yml

Pipeline:

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


======================================================================
27. STEP 22 - TEST GITHUB ACTIONS
======================================================================

Before deploying, commit and push:

git status

git add .

git commit -m "feat: deploy V4 application"

git push origin main

GitHub Actions should execute:

1. Test
2. Build
3. Push
4. Deploy


======================================================================
28. STEP 23 - GITHUB ACTIONS TEST JOB
======================================================================

The test job starts MySQL 8.0 as a GitHub Actions service.

It runs:

pytest -v

Expected:

9 passed

The test job must pass before the Docker image is built.


======================================================================
29. STEP 24 - BUILD DOCKER IMAGE
======================================================================

After tests pass, GitHub Actions builds:

Dockerfile

The image contains:

- Python runtime
- Python dependencies
- FastAPI application
- database initialization script


======================================================================
30. STEP 25 - PUSH IMAGE TO GHCR
======================================================================

GitHub Actions pushes the image to:

ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4

The deployment uses:

latest

and SHA-based tags.


======================================================================
31. STEP 26 - DEPLOY TO EC2
======================================================================

GitHub Actions connects through SSH.

The deployment process:

1. Creates SSH configuration
2. Connects to EC2
3. Creates ~/v4-app
4. Copies docker-compose.prod.yml
5. Pulls the GHCR image
6. Starts Docker Compose
7. Displays container status

The remote directory is:

/home/ubuntu/v4-app


======================================================================
32. STEP 27 - VERIFY DEPLOYMENT
======================================================================

From the laptop:

./scripts/aws/ec2.sh app-status

Expected:

v4_api
v4_mysql

Both should be running.

Check logs:

./scripts/aws/ec2.sh logs


======================================================================
33. STEP 28 - VERIFY FASTAPI
======================================================================

Open:

http://EC2_PUBLIC_IP:8000

Expected:

{
  "message": "Hello, World!",
  "version": "4.0.0"
}

Health:

http://EC2_PUBLIC_IP:8000/health

Expected:

{
  "status": "healthy"
}


======================================================================
34. STEP 29 - OPEN SWAGGER
======================================================================

Open:

http://EC2_PUBLIC_IP:8000/docs

Swagger should show:

GET    /
GET    /health
POST   /items
GET    /items
GET    /items/{id}
PUT    /items/{id}
DELETE /items/{id}


======================================================================
35. STEP 30 - TEST PRODUCTION CRUD
======================================================================

Create:

POST /items

{
  "name": "AWS Laptop",
  "description": "Created on EC2",
  "price": 1500
}

Read:

GET /items

Read one:

GET /items/{id}

Update:

PUT /items/{id}

Example:

{
  "name": "AWS Developer Laptop",
  "description": "Updated on EC2",
  "price": 1800
}

Delete:

DELETE /items/{id}

Verify:

GET /items/{id}

Expected:

404 Not Found


======================================================================
36. STEP 31 - TEST DATABASE PERSISTENCE
======================================================================

Create an item.

Then restart the application:

./scripts/aws/ec2.sh restart

Check:

./scripts/aws/ec2.sh app-status

Then:

GET /items

The data should still exist.

Why?

Because MySQL uses:

mysql_data

Docker volume.

Restarting containers does not delete the volume.


======================================================================
37. STEP 32 - FINAL END-TO-END TEST
======================================================================

The final test is:

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
          CRUD API


A successful V4 deployment means every stage above works.


======================================================================
38. LOCAL COMMANDS
======================================================================

Run tests:

./scripts/local/test.sh

Run application:

./scripts/local/run.sh

Docker start:

docker compose up -d

Docker stop:

docker compose down

Docker rebuild:

docker compose up --build

Docker status:

docker compose ps

Docker logs:

docker compose logs

API logs:

docker compose logs api

MySQL logs:

docker compose logs mysql


======================================================================
39. EC2 COMMANDS
======================================================================

Status:

./scripts/aws/ec2.sh status

IP:

./scripts/aws/ec2.sh ip

Start:

./scripts/aws/ec2.sh start

Stop:

./scripts/aws/ec2.sh stop

Reboot:

./scripts/aws/ec2.sh reboot

SSH:

./scripts/aws/ec2.sh ssh

Setup:

./scripts/aws/ec2.sh setup

Application status:

./scripts/aws/ec2.sh app-status

Application logs:

./scripts/aws/ec2.sh logs

Application restart:

./scripts/aws/ec2.sh restart

Application stop:

./scripts/aws/ec2.sh app-stop


======================================================================
40. EC2 MANUAL TROUBLESHOOTING
======================================================================

SSH:

./scripts/aws/ec2.sh ssh

Docker version:

docker --version

Compose version:

docker compose version

Docker containers:

docker ps

All containers:

docker ps -a

Docker service:

sudo systemctl status docker

Docker service logs:

sudo journalctl -u docker

Docker group:

id -nG


======================================================================
41. PRODUCTION TROUBLESHOOTING
======================================================================

Application status:

cd ~/v4-app

docker compose -f docker-compose.prod.yml ps

Application logs:

docker compose -f docker-compose.prod.yml logs --tail=100 api

MySQL logs:

docker compose -f docker-compose.prod.yml logs --tail=100 mysql

All logs:

docker compose -f docker-compose.prod.yml logs --tail=100

Pull latest image:

IMAGE_NAME=ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4 \
docker compose -f docker-compose.prod.yml pull

Start:

IMAGE_NAME=ghcr.io/YOUR_USERNAME/ec2-python-deployment-v4 \
docker compose -f docker-compose.prod.yml up -d

Restart:

docker compose -f docker-compose.prod.yml restart


======================================================================
42. PROBLEM - DOCKER APP COULD NOT IMPORT APP
======================================================================

Error:

ModuleNotFoundError: No module named 'app'

Cause:

The Python module path inside the Docker container did not include
/app.

Fix:

Add to Dockerfile:

ENV PYTHONPATH=/app

Rebuild:

docker compose build

Start:

docker compose up


======================================================================
43. PROBLEM - LOCAL MYSQL PORT CONFLICT
======================================================================

The Ubuntu laptop already had MySQL running on:

3306

Docker MySQL attempted to use the same host port.

Fix:

Do not expose MySQL to the host.

FastAPI connects internally using:

mysql:3306

Only FastAPI exposes:

8000:8000


======================================================================
44. PROBLEM - TESTS USED DEVELOPMENT DATABASE
======================================================================

Cause:

Tests were using the normal application database.

Risk:

Tests could modify development data.

Fix:

Create:

v4_app_test

Use:

tests/conftest.py

The tests override FastAPI's database dependency and use the
isolated test database.


======================================================================
45. PROBLEM - MYSQL MISSING IN GITHUB ACTIONS
======================================================================

Cause:

GitHub Actions does not automatically provide MySQL.

Fix:

Use a MySQL service:

mysql:
  image: mysql:8.0

The CI test environment therefore has its own MySQL instance.


======================================================================
46. PROBLEM - DEPLOYMENT FILE NOT FOUND
======================================================================

Error:

docker-compose.prod.yml not found

Cause:

GitHub Actions jobs run on separate fresh runners.

The deploy job had not checked out the repository.

Fix:

Add:

- name: Checkout repository
  uses: actions/checkout@v4

to the deploy job.


======================================================================
47. PROBLEM - DOCKER PERMISSION DENIED
======================================================================

Error:

permission denied while trying to connect to the Docker daemon socket

Cause:

The ubuntu user was not in the Docker group.

Fix:

sudo usermod -aG docker $USER

Exit:

exit

Reconnect.

Verify:

docker ps

If necessary:

id -nG


======================================================================
48. PROBLEM - DOCKER COMPOSE PACKAGE CONFLICT
======================================================================

Error:

trying to overwrite:

/usr/libexec/docker/cli-plugins/docker-compose

Cause:

Conflicting Docker Compose packages were installed.

Packages involved included:

docker-compose-v2

and:

docker-compose-plugin

Repair:

sudo dpkg --configure -a

sudo apt-get -f install -y

Remove conflicting package when required:

sudo apt-get remove -y docker-compose-v2

Then verify:

docker compose version


======================================================================
49. PROBLEM - DOCKER COMPOSE COMMAND UNKNOWN
======================================================================

Error:

docker: unknown command: docker compose

Cause:

Docker was installed but the Compose CLI plugin was unavailable.

Verify:

docker compose version

Install/configure Docker Compose using the package source appropriate
for the EC2 Ubuntu/Docker installation.

Verify again:

docker compose version


======================================================================
50. PROBLEM - EXIT CODE 125
======================================================================

GitHub Actions:

Process completed with exit code 125

Useful error:

unknown shorthand flag: 'f' in -f

Cause:

docker compose was not available on EC2.

Docker interpreted the command incorrectly.

Fix:

Install/configure Docker Compose.

Verify:

docker compose version

Then rerun deployment.


======================================================================
51. PROBLEM - GITHUB ACTIONS LOGS APPEARED EMPTY
======================================================================

Sometimes the GitHub Actions web interface may fail to display logs
correctly.

Before changing a working workflow:

1. Refresh the browser
2. Try another browser
3. Try private/incognito mode
4. Open the individual job step
5. Download the workflow logs if necessary

Do not assume an empty UI means the workflow produced no output.


======================================================================
52. PROBLEM - LAPTOP WORKS BUT PHONE CANNOT CONNECT
======================================================================

Cause:

The EC2 Security Group may only allow the laptop's public IP.

The phone may use a different public IP.

Check:

AWS EC2
 -> Instance
 -> Security
 -> Security Groups
 -> Inbound rules

Allow:

TCP 8000

For temporary testing:

0.0.0.0/0

More restrictive:

YOUR_PUBLIC_IP/32


======================================================================
53. PROBLEM - MYSQL SHOULD NOT BE PUBLIC
======================================================================

Never solve API connectivity problems by opening:

3306

to:

0.0.0.0/0

Correct:

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


======================================================================
54. GITHUB TROUBLESHOOTING
======================================================================

Check recent commits:

git log --oneline --decorate -10

Check status:

git status

Check workflow file:

git show HEAD:.github/workflows/ci.yml

Check production Compose file:

git show HEAD:docker-compose.prod.yml

Check tracked production file:

git ls-files docker-compose.prod.yml

Push:

git push origin main


======================================================================
55. DOCKER TROUBLESHOOTING CHECKLIST
======================================================================

If the API does not start:

1. Check containers:

docker compose ps

2. Check API logs:

docker compose logs api

3. Check MySQL:

docker compose logs mysql

4. Check Compose:

docker compose version

5. Rebuild:

docker compose up --build

6. If necessary, reset:

docker compose down -v

docker compose up --build


======================================================================
56. EC2 DEPLOYMENT CHECKLIST
======================================================================

Before deployment:

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
[ ] docker-compose.prod.yml committed
[ ] ci.yml committed


======================================================================
57. CI/CD CHECKLIST
======================================================================

Push to main.

Verify:

[ ] GitHub Actions starts
[ ] MySQL service starts
[ ] pytest passes
[ ] Docker image builds
[ ] GHCR login succeeds
[ ] Docker image pushes
[ ] SSH connection succeeds
[ ] docker-compose.prod.yml copies to EC2
[ ] GHCR image pulls
[ ] Docker Compose starts
[ ] v4_api is running
[ ] v4_mysql is running


======================================================================
58. APPLICATION CHECKLIST
======================================================================

Verify:

[ ] GET /
[ ] GET /health
[ ] GET /docs
[ ] POST /items
[ ] GET /items
[ ] GET /items/{id}
[ ] PUT /items/{id}
[ ] DELETE /items/{id}

Then restart:

./scripts/aws/ec2.sh restart

Verify data persistence.


======================================================================
59. SECURITY NOTES
======================================================================

Never commit:

*.pem

Private SSH keys.

Never commit:

scripts/aws/ec2.conf

Never commit:

- AWS access keys
- GitHub tokens
- passwords
- production secrets
- database credentials

Use GitHub Secrets for CI/CD credentials:

EC2_HOST
EC2_USER
EC2_SSH_KEY


Do not expose:

3306

to the public internet.

For a real production system, improve security with:

- HTTPS
- reverse proxy
- domain name
- TLS certificates
- secret management
- private database networking
- restrictive Security Groups
- non-root containers
- database migrations
- backups
- monitoring
- centralized logging
- infrastructure as code


======================================================================
60. V4 DEVELOPMENT PROGRESSION
======================================================================

V4.1
FastAPI foundation
        |
        v
V4.2
MySQL + SQLAlchemy
        |
        v
V4.3
CRUD + isolated automated tests
        |
        v
V4.4
Docker Compose
        |
        v
V4.5
GitHub Actions + GHCR
        |
        v
V4.6
AWS EC2 deployment


======================================================================
61. FINAL ARCHITECTURE
======================================================================

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
                       +------------+------------+
                                    |
                              Docker network
                                    |
                              mysql_data volume


======================================================================
62. V4 STATUS
======================================================================

V4.1  FastAPI foundation             COMPLETE
V4.2  MySQL + SQLAlchemy             COMPLETE
V4.3  CRUD + automated tests         COMPLETE
V4.4  Docker Compose                 COMPLETE
V4.5  CI/CD + GHCR                   COMPLETE
V4.6  AWS EC2 deployment             COMPLETE


======================================================================
63. FINAL RESULT
======================================================================

V4 provides a complete learning-oriented DevOps pipeline:

FastAPI
   +
MySQL
   +
SQLAlchemy
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


V4 IS COMPLETE.