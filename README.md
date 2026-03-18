# Cloud-Native Status Page Deployment
A highly available, decoupled Status Page application deployed on AWS using a modern Cloud-Native and Infrastructure as Code (IaC) approach. 
This project demonstrates a complete DevOps lifecycle, from containerization to infrastructure provisioning and Kubernetes orchestration, ensuring security, scalability, and high availability.

## Architecture Overview
![Status Page Architecture](./photos/Cloud_Architecture.png)
The application is built using a Microservices-style pattern based on a single mutable Docker image, orchestrated via Kubernetes, and backed by fully managed AWS services.

* **Frontend/Web Tier:** Handled by Kubernetes Pods running Gunicorn, exposed to the internet via an AWS Application Load Balancer (ALB).
* **Asynchronous Processing:** Background tasks and scheduling are decoupled using `rqworker` and `rqscheduler`, running in dedicated Kubernetes Pods.
* **Data Tier:** Relational data is stored securely in AWS RDS (PostgreSQL), while task queues and caching are managed by AWS ElastiCache (Redis).
* **Static Assets:** Logos, CSS, and UI assets are offloaded to an AWS S3 Bucket to reduce Pod load and improve performance.

## Key DevOps & Cloud Features
* **Infrastructure as Code (IaC):** AWS infrastructure is provisioned and managed using **Terraform**.
* **Zero-Trust Security:** Strict AWS Security Groups are implemented. The Database and Cache tiers are completely isolated in private subnets and accept traffic *only* from the Application Security Group.
* **Container Orchestration:** Deployed on Amazon EKS (Elastic Kubernetes Service).
* **Resource Efficiency:** Utilizes a single Docker `Dockerfile` for the entire stack. Kubernetes deployment manifests override the container `command` entrypoint to dynamically assign roles (App, Worker, Scheduler) without bloating the ECR registry.

##  Technologies Used
* **Cloud Provider:** AWS (EKS, RDS, ElastiCache, S3, ECR, ALB, VPC)
* **Infrastructure as Code:** Terraform
* **Containerization:** Docker
* **Orchestration:** Kubernetes (kubectl)
* **Application Stack:** Python, Django, Redis Queue (RQ), Gunicorn

##  Infrastructure Components 
* **VPC:** Custom VPC (10.0.0.0/16) with public/private subnets across 2 AZs
* Public Subnets: 10.0.1.0/24, 10.0.2.0/24 (for Load Balancers and NAT Gateway)
* Private Subnets: 10.0.21.0/24, 10.0.12.0/24 (for application nodes)
* Private Subnets: 10.0.11.0/24, 10.0.22.0/24 (for RDS and Elasticache)
* **Application Load Balancer (ALB):** Managed traffic routing for the application
    * Routing: Distributes incoming HTTP/HTTPS traffic across multiple target groups
    * Health Checks: Automatic monitoring of instance/pod availability
* **Internet Gateway (IGW):** Provides internet connectivity to public subnets
* **NAT Gateway:** Single NAT Gateway with Elastic IP for private subnet internet access
* **Amazon EKS Cluster:** Managed Kubernetes (v1.35) with 3 SPOT worker nodes (t3.medium)
    * Private subnets deployment for enhanced security
    * Auto Scaling Group with desired: 3, min: 2, max: 4
* **Amazon ECR:** Fully managed Docker container registry
    * Private repositories for secure image storage
    * Automated cleanup of old or unused images to optimize costs
    * Image scanning enabled for vulnerability detection
* **Amazon RDS for PostgreSQL:** Managed relational database service
    * Engine: PostgreSQL 15 (High-performance open-source database)
    * Multi-AZ deployment for failover and high availability
    * Isolated within private subnets
* **S3 Bucket:** Secure and scalable object storage
    * Hosted application assets and static files
    * S3 Block Public Access enabled
    * Policy: Restricted access via IAM roles and Bucket Policies
* **Amazon ElastiCache (Redis):** Fully managed in-memory data store
    * Used as a high-performance caching layer and session store
    * Sub-millisecond latency for real-time data access
    * Clustered mode enabled for seamless horizontal scaling
    * Automated snapshots for data durability and recovery

## Prerequisites
* AWS CLI 
* Terraform 
* Kubectl
* Docker
* Git

## Repository Structure
* `/Terraform-files/` - Contains all Terraform (`.tf`) files to provision the AWS infrastructure (VPC, EKS, RDS, ElastiCache, S3, Security Groups).
* `/EKS-deployments-files/` - Contains Kubernetes manifests (`deployment.yaml`, `service.yaml`) for the Web App, Worker, and Scheduler.
* `/statuspage/` - Application source code and `Dockerfile`.

## Deployment Guide

### 1. GitHub Repository Setup
clone the repository
```bash
git clone https://github.com/yoav31/status-page-project.git
cd status-page-project
```
### 2. Provision Infrastructure
Navigate to the Terraform directory and deploy the AWS resources (not forget to edit the names):
```bash
cd Terraform-files
terraform init
terraform plan
terraform apply
cd ..
```
### 3. CI/CD Configuration 
Run Jenkins Container:
```bash
sudo systemctl start docker
docker run -d \
    -p 8080:8080 -p 50000:50000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v jenkins_home:/var/jenkins_home \
    --name jenkins-server jenkins/jenkins:lts
```
### 4. CI/CD Configuration 
Run Jenkins as a Container:
```bash
sudo systemctl start docker
docker run -d \
    -p 8080:8080 -p 50000:50000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v jenkins_home:/var/jenkins_home \
    --name jenkins-server jenkins/jenkins:lts   
```
### 5. Initial Jenkins Setup
1. **Start Jenkins:** Run the `docker run` command provided above.
2. **Unlock Jenkins:** Use `docker logs jenkins-server` to get the admin password.
3. **Create Job:** * Click **New Item** -> **Pipeline**.
   * Name it `status-page-pipeline`.
4. **Link Jenkinsfile:** * Under **Pipeline**, paste your `Jenkinsfile` code.
5. **Run:** The **Build Now** button will now be available on the left sidebar.

### 6. Deploy Application 
Option A: automatic deployment with Jenkins
```bash
git add .
git commit -m "Initial deployment configuration"
git push origin main  
```
Option B: manual initial deployment
```bash
cd status-page-project
chmod +x deploy.sh
./deploy.sh   
```











עדכון הגישה לקלאסטר (Kubeconfig)
הפקודה הזו "מלמדת" את ה-kubectl שלך איך לדבר עם הקלאסטר החדש:
aws eks update-kubeconfig --region us-east-1 --name yoav-terraform-eks

בנייה מחדש של ה־image
נניח שה־Dockerfile שלך נמצא בתיקייה status-page:

cd ~/status-page
docker build -t yoav_project_ecr:latest .

תגית לדחיפה ל־ECR
אם כבר יש לך repository ב־ECR:

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com
docker tag yoav_project_ecr:latest 992382545251.dkr.ecr.us-east-1.amazonaws.com/yoav_project_ecr:latest

דחיפה ל־ECR

docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/yoav_project_ecr:latest

עדכון ה־Deployment ב־K8s
אחרי הדחיפה, בצע rollout restart כדי שהפודים ישתמשו ב־image החדש:

kubectl rollout restart deployment status-page-app
kubectl get pods -w

בדיקה
ודא שהפודים חדשים רצים ו־CrashLoopBackOff נעלם:

kubectl get pods
kubectl logs <pod-name>



kubectl get svc        כדי לגשת לכתובת האינטרנט של האתר:

