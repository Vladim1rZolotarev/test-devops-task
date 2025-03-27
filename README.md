# test-devops-task

## Описание проекта

`test-devops-task` — это DevOps-проект, демонстрирующий развертывание веб-приложения на Flask с использованием Docker, Nginx, Prometheus, Grafana, Fluentd и Loki.  

## Состав проекта

. ├── .github/workflows/       # Конфигурация GitHub Actions для CI/CD ├── app/                     # Исходный код Flask-приложения ├── docker-compose.yml        # Конфигурация Docker Compose ├── Dockerfile                # Инструкция сборки образа Flask-приложения ├── fluentd.conf              # Конфигурация Fluentd ├── loki-config.yml           # Конфигурация Loki ├── nginx.conf                # Конфигурация Nginx ├── prometheus.yml            # Конфигурация Prometheus ├── restart_docker_compose.sh # Скрипт для перезапуска сервисов └── README.md                 # Документация проекта

## Установка и запуск

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/Vladim1rZolotarev/test-devops-task.git
   cd test-devops-task

2. Запустите сервисы через Docker Compose:

docker-compose up --build


3. Доступ к сервисам:

Flask-приложение: http://localhost:5000

Nginx: http://localhost:2727

Prometheus: http://localhost:9090

Grafana: http://localhost:3000

Loki: http://localhost:3100




Описание сервисов

Flask-приложение

Расположение кода: app/

Сборка образа: выполняется через Dockerfile

Логирование: отправляет логи в Fluentd


Nginx

Конфигурация: nginx.conf

Проксирует запросы к Flask-приложению


Prometheus

Конфигурация: prometheus.yml

Собирает метрики из Flask-приложения


Grafana

Доступ: http://localhost:3000

Используется для визуализации метрик Prometheus


Fluentd

Конфигурация: fluentd.conf

Собирает логи от Flask и Nginx и передает в Loki


Loki

Конфигурация: loki-config.yml

Хранит и обрабатывает логи


Автоматизация (CI/CD)

Проект использует GitHub Actions для автоматического деплоя. Конфигурация находится в .github/workflows/.

Rollback и деплой

1. Откат на предыдущий образ:

docker-compose pull && docker-compose up -d


2. Деплой staging/production:

Ветка feature — staging

Ветка main — production

При пуше в ветку выполняется деплой через GitHub Actions


Переменные окружения

Перед запуском убедитесь, что заданы необходимые переменные в .env или в конфигурации контейнеров.

Дополнительно

Логирование и мониторинг: Prometheus и Grafana отслеживают метрики, а Fluentd и Loki собирают логи.

Безопасность: рекомендуется ограничить внешний доступ к сервисам.


Автор

Vladimir Zolotarev
