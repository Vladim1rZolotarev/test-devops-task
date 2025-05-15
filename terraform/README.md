# Инфраструктура как код (IaC) для проекта DevOps CV

Этот каталог содержит конфигурацию Terraform для автоматического создания инфраструктуры в Yandex Cloud.

## Предварительные требования

1. [Terraform](https://www.terraform.io/downloads.html) (версия >= 1.0.0)
2. [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart)
3. Аккаунт в Yandex Cloud с активированным платежным аккаунтом
4. SSH-ключи для доступа к создаваемым серверам

## Настройка

1. Создайте файл `terraform.tfvars` на основе примера:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Отредактируйте файл `terraform.tfvars`, указав свои значения:

```
# Yandex Cloud credentials
yc_token     = "YOUR_YANDEX_CLOUD_TOKEN"
yc_cloud_id  = "YOUR_CLOUD_ID"
yc_folder_id = "YOUR_FOLDER_ID"
yc_zone      = "ru-central1-a"

# Project settings
project_name = "devops-cv"
domain       = "your-domain.com"

# VM settings
vm_image_id = "fd8emvfmfoaordspe1jr"  # Ubuntu 20.04 LTS
vm_user     = "ubuntu"

# SSH keys
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"
```

## Использование

### Инициализация Terraform

```bash
terraform init
```

### Проверка плана развертывания

```bash
terraform plan
```

### Создание инфраструктуры

```bash
terraform apply
```

После успешного выполнения команды, Terraform выведет IP-адрес созданного сервера.

### Удаление инфраструктуры

```bash
terraform destroy
```

## Созданные ресурсы

- VPC сеть и подсеть
- Группа безопасности с необходимыми правилами
- Виртуальная машина с Ubuntu 20.04
- DNS-записи для домена
- Автоматическая настройка сервера и развертывание приложения

## Дополнительная информация

- Состояние Terraform хранится в S3-совместимом хранилище Yandex Object Storage
- Для доступа к серверу используется SSH-ключ, указанный в переменных
- Приложение автоматически разворачивается с помощью Docker Compose
