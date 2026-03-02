<div align="center">
    <img alt="Status Page" src="https://cdn.herrtxbias.net/status-page/logo_gray/logo_small.png"></a>
</div>
<br />
<p align="center">
    <a href="https://github.com/Status-Page/Status-Page"><img alt="GitHub license" src="https://img.shields.io/github/license/Status-Page/Status-Page"></a>
    <a href="https://github.com/Status-Page/Status-Page/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/Status-Page/Status-Page"></a>
    <a href="https://github.com/Status-Page/Status-Page/network"><img alt="GitHub forks" src="https://img.shields.io/github/forks/Status-Page/Status-Page"></a>
    <a href="https://github.com/Status-Page/Status-Page/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/Status-Page/Status-Page"></a>
    <a href="https://github.com/Status-Page/Status-Page/releases"><img alt="GitHub latest releas" src="https://img.shields.io/github/release/Status-Page/Status-Page"></a>
    <a href="https://www.codacy.com/gh/Status-Page/Status-Page/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Status-Page/Status-Page&amp;utm_campaign=Badge_Grade"><img src="https://app.codacy.com/project/badge/Grade/250b53ad99ca432cbac8d761a975b34d"/></a>
</p>

# Overview
- Components
- Report incidents
- JSON API
- Metrics
- Two Factor Authentication
- Markdown support in incident / maintenance messages
- Subscriptions for Notifications
- Custom Plugins

# Requirements
| Dependency       | Minimum Version | Optional |
|------------------|-----------------|----------|
| Python           | 3.10            | no       |
| PostgreSQL       | 10              | no       |
| Redis            | 4.0             | no       |
| SMTP Mail Server | ---             | yes      |

# Installation & Updates
Please have a look at our [Documentation](https://docs.status-page.dev/).

## Versioning
We use semantic versioning. A version number has the following structure:
````
v 1 . 0 . 0
  ^   ^   ^
  |   |   |
  |   |   Patch (Bug fixes)
  |   |
  |   Minor (No breaking changes to the Software, e.g. adding new features)
  |
  Major (Breaking changes to the Software)
````

## Documentation
You can find the Documentation [here](https://docs.status-page.dev/).

## Other Licenses and Acknowledgements
### Tailwind UI
We are using Tailwind UI Components in this App. You are **NOT** allowed to reuse these Components in your own App!

See their [License](https://www.notion.so/Tailwind-UI-License-644418bb34ad4fa29aac9b82e956a867) for more information.

### NetBox
As you may have noticed, the base structure for many parts of the app is derived
from [NetBox](https://github.com/netbox-community/netbox), this made development much easier.
=======
# final-project-DevOps-


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

