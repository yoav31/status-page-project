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
