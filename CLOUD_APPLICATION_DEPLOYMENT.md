# Production Cloud Deployment Guide: Linux, AWS, and Azure

This walkthrough outlines how to deploy the three-tier banking application workload and presentations onto production-grade Linux servers and within the AWS and Azure cloud architectures defined in your Terraform IaC.

---

## 🐧 Part 1: Deploying on a Linux (Ubuntu) Server

This step configures the Flask backend and React static files to run on a standalone Linux Virtual Machine (such as an AWS EC2 or Azure VM).

### 1. Install System Dependencies
Update package registries and install Python, Node.js, PostgreSQL, and Nginx:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv nodejs npm nginx postgresql postgresql-contrib git
```

### 2. Configure PostgreSQL Database
Log in to PostgreSQL and create the database schema:

```bash
sudo -i -u postgres psql
# In the psql prompt:
CREATE DATABASE bank_workload;
CREATE USER lesile WITH PASSWORD 'SecurePassword123';
GRANT ALL PRIVILEGES ON DATABASE bank_workload TO lesile;
\q

# Seed the schema:
psql -U lesile -d bank_workload -h localhost -f app/db/schema.sql
```

### 3. Deploy the Flask API as a systemd Service
Using Gunicorn as the WSGI server, run the API in the background:

```bash
# Create virtual environment and install dependencies
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt gunicorn
deactivate

# Create systemd service file
sudo nano /etc/systemd/system/bank-api.service
```

Paste the following configuration:
```ini
[Unit]
Description=Bank Workload Flask API
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/miva_final_project_mutlicloud/app
ExecStart=/home/ubuntu/miva_final_project_mutlicloud/app/.venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 api.app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

Start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start bank-api
sudo systemctl enable bank-api
```

### 4. Deploy React Frontend via Nginx
Build the static assets and configure Nginx:

```bash
cd ../dashboard
npm install
npm run build

# Copy build to Nginx serving directory
sudo cp -r dist/* /var/www/html/
```

Configure Nginx reverse proxy to forward `/api/*` requests to the Flask server:
```bash
sudo nano /etc/nginx/sites-available/default
```

Modify the `location /` blocks:
```nginx
server {
    listen 80 default_server;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

---

## ☁️ Part 2: AWS Enterprise Production Deployment

To align with the Zero Trust network design, the application is deployed into the AWS Hub VPC subnets as follows:

```
[Internet] -> [Application Load Balancer] (Web Subnet)
                    |
              (HTTPS port 443)
                    v
    [EC2 Auto-Scaling Group instances] (Private App Subnet)
                    |
              (PostgreSQL port 5432)
                    v
    [Amazon RDS PostgreSQL Instance] (Private DB Subnet)
```

### 1. Database Tier (RDS)
* Deploy **Amazon RDS for PostgreSQL** inside the Private DB subnets.
* Associate it with the DB Security Group, allowing ingress on port 5432 only from the App Security Group.

### 2. Application Tier (EC2 & Launch Templates)
* Create an AWS Launch Template with an Ubuntu AMI. Set the User Data script to clone the repo, install python/gunicorn, and start the systemd service (pointing the database connection string environment variable to the RDS endpoint).
* Provision an **Auto Scaling Group** in the private App subnets using this template.

### 3. Web Tier (ALB)
* Deploy an **Application Load Balancer (ALB)** in the public Web subnets.
* Bind an SSL certificate via AWS Certificate Manager (ACM) to the ALB listener on port 443.
* Set the target group to route traffic to port 8443 on the App Auto Scaling Group.

---

## ☁️ Part 3: Azure Enterprise Production Deployment

Equivalently, the Azure deployment utilizes native SaaS/PaaS blocks inside the VNet:

```
[Internet] -> [Application Gateway] (Web Subnet)
                    |
              (HTTPS port 443)
                    v
    [Virtual Machine Scale Sets - VMSS] (Private App Subnet)
                    |
              (PostgreSQL port 5432)
                    v
  [Azure Database for PostgreSQL Flexible] (Private DB Subnet)
```

### 1. Database Tier (Azure Database for PostgreSQL)
* Provision **Azure Database for PostgreSQL (Flexible Server)** inside the DB subnet.
* Configure virtual network integration (VNet Peering) to isolate the database. Set firewall rules to accept connections only from the App subnet CIDR range (`192.168.18.0/24`).

### 2. Application Tier (VMSS)
* Create an **Azure Virtual Machine Scale Set (VMSS)** in the App subnet.
* Use custom script extensions or cloud-init to automate database credentials lookup from **Azure Key Vault** and run the Gunicorn daemon.

### 3. Web Tier (Azure Application Gateway)
* Deploy **Azure Application Gateway (AppGW)** in the Web subnet.
* Configure a listener on port 443 with HTTPS certs, and set the HTTP backend routing rule to forward traffic to the VMSS pool on port 8443.
