# 3-Tier Workload & Dashboard Application Deployment Walkthrough

This guide details how to install, configure, and start the simulated 3-tier workload database, Python Flask REST API, and Vite React visual command center dashboard on a local workstation.

---

## 🛠️ System Architecture Overview

* **Database Tier:** Local SQLite database (`app/db/simulated_workload.db`) populated automatically with banking customer schemas and seeds.
* **Application Tier (Flask REST API):** Exposes transaction interfaces, lateral-access simulation routes, and automated thesis compiler endpoints. Runs on `http://localhost:5000/`.
* **Presentation Tier (React Frontend):** Dynamic command center displaying real-time latencies, speedometers, and the compiler dashboard. Runs on `http://localhost:5173/`.

---

## 🚀 Setup Steps

### Step 1: Clone and Configure Python Virtual Environment
Navigate to the root directory and configure Python. This isolates dependencies from your system-wide interpreter:

```powershell
# Create the virtual environment
python -m venv .venv

# Activate the virtual environment
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1
# On macOS/Linux:
source .venv/bin/activate
```

### Step 2: Install Python Dependencies
Install Flask, Flask-CORS, and python-docx libraries:

```powershell
pip install -r app/requirements.txt
```

### Step 3: Run the API Backend Server
Start the Flask application. This automatically seeds the database and begins listening for HTTP requests on port 5000:

```powershell
python app/api/app.py
```

* **Verify health:** Open a web browser or run curl to test health:
  ```powershell
  curl http://localhost:5000/api/health
  # Response should be: {"database":"connected","engine":"SQLite-simulated","status":"healthy"}
  ```

---

## 🖥️ Presentation Tier Setup (React Dashboard)

Open a **new terminal window** (keeping the Flask API running in the first one) to launch the frontend command center.

### Step 1: Install Node Dependencies
Navigate into the dashboard directory and install package requirements:

```powershell
cd dashboard
npm install
```

### Step 2: Launch Vite Development Server
Run Vite to compile and host the web dashboard locally:

```powershell
npm run dev
```

* **Access URL:** Open your browser and navigate to:
  👉 **`http://localhost:5173/`**

---

## 📈 Running Simulations & Thesis Compiling

Once both servers are running, access the dashboard at `http://localhost:5173/` to interact with:
1. **Traffic Simulator:** Click **Post Bank Transaction** to trigger REST commands. Click **Simulate Tunnel Failover** to initiate dynamic BGP recovery calculations.
2. **Thesis Compiler:** Type your supervisor and examiner details into the forms, review live latencies, and click **Compile Thesis Document** to assemble the final report.
