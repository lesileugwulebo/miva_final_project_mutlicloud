# AWS-Azure Multi-Cloud Network Deployment Walkthrough

This guide details the step-by-step process for deploying the version-controlled Terraform codebase onto live Amazon Web Services (AWS) and Microsoft Azure environments, configuring dynamic BGP routing, and verifying tunnel encryption.

---

## 📋 Prerequisites

Before beginning the deployment, ensure your local environment has the following CLI tools installed and authenticated:

1. **Terraform CLI** (v1.5.0+)
2. **AWS CLI** (v2.0+) — configured via `aws configure`
3. **Azure CLI** (v2.50.0+) — logged in via `az login`

> [!WARNING]
> Running these Terraform configurations will provision real resources (Transit Gateway, Virtual WAN, VPN Gateways, subnets) that incur cloud charges. Ensure you clean up resources using the **Teardown** steps when finished.

---

## 🚀 Deployment Steps

### Step 1: Configure Cloud Access and Subscriptions
Ensure your CLI sessions are mapped to the correct accounts and subscriptions:

```powershell
# Verify AWS credentials
aws sts get-caller-identity

# Select the target Azure Subscription
az account list --output table
az account set --subscription "Your-Subscription-Name-Or-ID"
```

### Step 2: Initialize Terraform Modules
Navigate to the `terraform/` directory and run initialization. This downloads the AWS and Azure provider plugins and binds the module hierarchy:

```powershell
cd terraform
terraform init
```

### Step 3: Run Dry-Run Plan
Generate a plan to verify that resource blocks conform to your local subscription permissions and variable inputs:

```powershell
terraform plan -out=tfplan
```

### Step 4: Execute Deployment Apply
Deploy the secure network infrastructure. Terraform automatically compiles the resource DAG (Directed Acyclic Graph) to prevent circular dependencies between the cloud gateways:

```powershell
terraform apply tfplan
```

#### What happens during execution:
1. **Azure Resource Group & Network Layer** is created first.
2. **Azure Virtual WAN & VPN Hub Gateway** are provisioned (takes ~15-20 minutes).
3. **AWS VPC & Subnets** are provisioned.
4. **AWS Transit Gateway** and Customer Gateway are created, pointing to Azure's newly allocated VPN Gateway public IP.
5. **AWS VPN Attachment** is established, exporting the AWS Tunnel public IPs.
6. **Azure VPN Site** and Connection are configured with the AWS Tunnel IPs to establish the link.

---

## 🔒 Verification & Handshake Validation

Once the Terraform output completes, follow these validation checks:

### 1. Check VPN Tunnel Connection Status

```powershell
# Query AWS VPN Connection state
aws ec2 describe-vpn-connections --query "VpnConnections[*].VpcAttachments[*].State"
```

In the Azure Portal, navigate to **Virtual WAN -> VPN Sites -> aws-vpn-site** and confirm that the connectivity state is marked as **Connected / Active**.

### 2. Verify Dynamic eBGP Route Exchange
Check that route propagation has populated both routing tables dynamically without manual static routing:

* **On AWS**: Go to **VPC Console -> Route Tables** and check the private subnet route table. You should see a propagated BGP route pointing to `192.168.16.0/20` (Azure VNet) with the target as the Transit Gateway.
* **On Azure**: Run the command below to inspect active routes on the Virtual WAN Hub:

```powershell
az network vhub get-effective-routes --name "multicloud-virtual-hub" --resource-group "multicloud-rg" --output table
```

### 3. Verify IPsec Encryption in Transit
During simulation or live traffic testing, run a packet capture (`tcpdump` / Wireshark) on the endpoints to confirm that only encrypted packets are exchanged:

```bash
# Verify only Encapsulating Security Payload (ESP / IP protocol 50) and IKE (UDP ports 500/4500) traffic is traversing the link
sudo tcpdump -i any -n "proto esp or port 500 or port 4500"
```

---

## 🧹 Teardown & Clean Up

To avoid recurring billing, destroy all created components once your verification testing and thesis compilation is complete:

```powershell
# Navigate to the terraform folder and run destroy
cd terraform
terraform destroy --auto-approve
```

> [!CAUTION]
> Ensure the destroy process completes fully. Double-check the AWS Console for any lingering Customer Gateways / Transit Gateways, and the Azure Portal for active resource groups under `multicloud-rg`.
