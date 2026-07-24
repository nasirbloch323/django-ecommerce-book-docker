# Django E-commerce Book Store  & Muti-Branch📚

A Django-based e-commerce web application for buying and selling books — fully containerized with Docker and integrated with a Jenkins CI/CD pipeline for automated build, test, and deployment.

---

## 🚀 Features

- Django-powered e-commerce backend
- Book catalog with `books` app
- User accounts and authentication (`accounts` app)
- Fully Dockerized for easy setup and deployment
- CI/CD pipeline via Jenkins Multibranch Pipeline
- Automatic build on `dev` branch, automatic deployment on `master` branch

---

## 🛠️ Tech Stack

- **Backend:** Python, Django
- **Containerization:** Docker, Docker Compose
- **CI/CD:** Jenkins (Multibranch Pipeline)
- **Version Control:** Git & GitHub

---

## 📂 Project Structure

```
django-ecommerce-book-docker/
├── books/              # Books app
├── accounts/           # User accounts app
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── manage.py
├── requirements.txt
└── README.md
```

---

## ⚙️ Getting Started (Local Setup with Docker)

### Prerequisites
- Docker
- Docker Compose

### Steps

1. Clone the repository
   ```bash
   git clone https://github.com/nasirbloch323/django-ecommerce-book-docker.git
   cd django-ecommerce-book-docker
   ```

2. Build and run the containers
   ```bash
   docker compose up --build
   ```

3. The app will be available at:
   ```
   http://localhost:8000
   ```

4. Stop the containers
   ```bash
   docker compose down
   ```

---

## 🔄 CI/CD Pipeline (Jenkins)

This project uses a **Jenkins Multibranch Pipeline** with the following branch strategy:

| Branch   | Action                                        |
|----------|------------------------------------------------|
| `dev`    | Build image + run Django checks/migration dry-run |
| `master` | Build image + deploy container + health check   |

### Pipeline Stages
1. **Checkout** – Pulls the latest code from the branch
2. **Build Image** – Builds the Docker image using `docker compose build`
3. **Django Checks** *(dev only)* – Runs `manage.py check` and migration dry-runs
4. **Deploy** *(master only)* – Stops old containers and deploys the new build
5. **Health Check** *(master only)* – Verifies the app is responding on port 8000

### GitHub Webhook
The pipeline is automatically triggered on every push via a configured GitHub webhook, so no manual builds are needed.

---

## 🧩 Jenkins Multibranch Pipeline Setup (Step-by-Step)

Follow these steps to set up the CI/CD pipeline from scratch on a new Jenkins server.

### 1. Install Required Plugins
Go to **Manage Jenkins → Plugins** and install:
- Pipeline / Pipeline: Multibranch
- Git plugin
- GitHub Branch Source plugin
- Docker Pipeline plugin
- Credentials plugin

### 2. Install Docker & Docker Compose on the Jenkins Server
Ensure `docker` and `docker compose` are available on the machine/agent running the builds:
```bash
docker --version
docker compose version
```

Give the Jenkins user permission to run Docker:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

> If Jenkins itself runs inside a container, mount the Docker socket:
> ```yaml
> volumes:
>   - /var/run/docker.sock:/var/run/docker.sock
> ```

### 3. Add GitHub Credentials in Jenkins
Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

- **Kind:** Username with password
- **Username:** your GitHub username
- **Password:** a GitHub Personal Access Token (PAT) — not your GitHub password
- **ID:** e.g. `github-creds`

To generate a PAT:
GitHub → **Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token**
Scopes required: `repo`, `admin:repo_hook`

### 4. Create the Multibranch Pipeline Job
- Jenkins Dashboard → **New Item**
- Enter a name, select **Multibranch Pipeline** → OK
- Under **Branch Sources**, click **Add source → GitHub**
  - **Credentials:** select the credential created in Step 3
  - **Repository HTTPS URL:**
    ```
    https://github.com/nasirbloch323/django-ecommerce-book-docker.git
    ```
- Under **Build Configuration**, keep script path as `Jenkinsfile` (default)
- Set **Scan Multibranch Pipeline Triggers** → check **Periodically if not otherwise run** (or rely on the webhook — see below)
- Save

Jenkins will automatically scan the repo and create a sub-job for each branch (`master`, `dev`) that contains a `Jenkinsfile`.

### 5. Configure GitHub Webhook (for automatic triggers)
On the repository:
`https://github.com/nasirbloch323/django-ecommerce-book-docker` → **Settings → Webhooks → Add webhook**

- **Payload URL:**
  ```
  http://<your-jenkins-server-ip>:8080/github-webhook/
  ```
- **Content type:** `application/json`
- **Which events:** Just the push event (or add Pull Requests too)
- **Active:** ✅ checked
- Click **Add webhook**

> Make sure the Jenkins server's port (default `8080`) is open in the firewall / AWS Security Group so GitHub can reach it.

### 6. Verify the Setup
- Push a commit to `dev` or `master`
- Go to GitHub → **Webhooks → Recent Deliveries** to confirm a `200` response was received
- Check Jenkins → the Multibranch job should trigger automatically and start building the corresponding branch

### 7. Branch Behavior Summary
| Branch   | Trigger        | Pipeline Action                                  |
|----------|----------------|---------------------------------------------------|
| `dev`    | Push / Webhook | Build image → run Django checks & migration dry-run |
| `master` | Push / Webhook | Build image → deploy container → health check     |

---

## 📌 Notes

- Make sure Docker and Docker Compose are installed on the Jenkins agent/server.
- The Jenkins user must have permission to run Docker commands.
- Environment variables (if any) should be configured via `.env` or Jenkins credentials — not committed to the repo.

---

## 🤝 Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Push to your branch and open a Pull Request

---

## 📄 License

This project is open-source and available for learning purposes.
