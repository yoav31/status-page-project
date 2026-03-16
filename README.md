# ☁️ Cloud-Native Status Page Deployment

A highly available, decoupled Status Page application deployed on AWS using a modern Cloud-Native and Infrastructure as Code (IaC) approach. 

This project demonstrates a complete DevOps lifecycle, from containerization to infrastructure provisioning and Kubernetes orchestration, ensuring security, scalability, and high availability.

## 🏗️ Architecture Overview
![Status Page Architecture](./photos/Cloud_Architecture.png)
The application is built using a Microservices-style pattern based on a single mutable Docker image, orchestrated via Kubernetes, and backed by fully managed AWS services.

* **Frontend/Web Tier:** Handled by Kubernetes Pods running Gunicorn, exposed to the internet via an AWS Application Load Balancer (ALB).
* **Asynchronous Processing:** Background tasks and scheduling are decoupled using `rqworker` and `rqscheduler`, running in dedicated Kubernetes Pods.
* **Data Tier:** Relational data is stored securely in AWS RDS (PostgreSQL), while task queues and caching are managed by AWS ElastiCache (Redis).
* **Static Assets:** Logos, CSS, and UI assets are offloaded to an AWS S3 Bucket to reduce Pod load and improve performance.

## 🚀 Key DevOps & Cloud Features
* **Infrastructure as Code (IaC):** 100% of the AWS infrastructure is provisioned and managed using **Terraform**.
* **Zero-Trust Security:** Strict AWS Security Groups are implemented. The Database and Cache tiers are completely isolated in private subnets and accept traffic *only* from the Application Security Group.
* **Container Orchestration:** Deployed on Amazon EKS (Elastic Kubernetes Service).
* **Resource Efficiency:** Utilizes a single Docker `Dockerfile` for the entire stack. Kubernetes deployment manifests override the container `command` entrypoint to dynamically assign roles (App, Worker, Scheduler) without bloating the ECR registry.

## 🛠️ Technologies Used

* **Cloud Provider:** AWS (EKS, RDS, ElastiCache, S3, ECR, ALB, VPC)
* **Infrastructure as Code:** Terraform
* **Containerization:** Docker
* **Orchestration:** Kubernetes (kubectl)
* **Application Stack:** Python, Django, Redis Queue (RQ), Gunicorn

## 📂 Repository Structure

* `/Terraform-files/` - Contains all Terraform (`.tf`) files to provision the AWS infrastructure (VPC, EKS, RDS, ElastiCache, S3, Security Groups).
* `/EKS-deployments-files/` - Contains Kubernetes manifests (`deployment.yaml`, `service.yaml`) for the Web App, Worker, and Scheduler.
* `/statuspage/` - Application source code and `Dockerfile`.

## ⚙️ Deployment Guide

### 1. Provision Infrastructure
Navigate to the Terraform directory and deploy the AWS resources:
```bash
cd Terraform-files
terraform init
terraform plan
terraform apply


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

