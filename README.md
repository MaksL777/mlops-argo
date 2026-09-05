# Домашнє завдання №3: Розгортання Argo CD та налаштування GitOps

## Мета проєкту

Розгортання Argo CD у кластері AWS EKS за допомогою Terraform та налаштування автоматичного GitOps-деплою (через ApplicationSet) демо-застосунку Nginx.

## Посилання на GitOps-репозиторій

https://github.com/MaksL777/mlops-argo

---

## Інструкція з розгортання

### 1. Запуск Terraform

Для встановлення Argo CD в існуючий EKS-кластер перейдіть у директорію з конфігурацією Terraform (argocd/) та виконайте команди:

    terraform init
    terraform apply -auto-approve

_Примітка: для роботи на t3.micro використано оптимізований файл argocd-values.yaml (вимкнено dex/notifications, знижено ліміти пам'яті)._

### 2. Перевірка роботи Argo CD

Щоб переконатися, що всі компоненти Argo CD успішно запущені:

    aws eks --region us-east-1 update-kubeconfig --name mlops-eks-cluster
    kubectl get pods -n infra-tools

Усі поди повинні мати статус Running.

### 3. Доступ до Argo CD UI

Для доступу до вебінтерфейсу Argo CD прокиньте порт:

    kubectl port-forward svc/argocd-server -n infra-tools 8080:443

Відкрийте https://localhost:8080
Логін: admin
Пароль (отримання початкового пароля):

    kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

### 4. Перевірка GitOps-деплою (ApplicationSet)

GitOps налаштовано за допомогою файлу applicationset.yaml. Для перевірки того, що Argo CD підхопив репозиторій і створив застосунки, виконайте:

    kubectl get applications -n infra-tools

Очікуваний результат: застосунки application та infra-tools у статусі Synced / Healthy.

### 5. Перевірка застосунку Nginx

Перевірка створеного Deployment та Pods:

    kubectl get deploy -n application
    kubectl get pods -n application

Для доступу до вебсервера Nginx виконайте port-forward:

    kubectl -n application port-forward deployment/demo-nginx 8081:80

Відкрийте у браузері http://localhost:8081. Має відобразитися стартова сторінка "Welcome to nginx!".

---

УВАГА: Після завершення перевірки не забудьте видалити ресурси, щоб уникнути зайвих витрат (у такому порядку):

    cd argocd
    terraform destroy -auto-approve
    cd ../eks
    terraform destroy -auto-approve
    cd ../vpc
    terraform destroy -auto-approve
