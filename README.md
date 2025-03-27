# test-devops-task

## Описание проекта

Проект представляет собой инфраструктуру для развертывания веб-приложения на Flask с использованием Docker и инструментов DevOps. Реализовано автоматическое развертывание, логирование, мониторинг, балансировка нагрузки и механизм отката (rollback).

## Выполненные задачи

### 1. Развертывание веб-приложения в контейнерах (Docker)
- Разработано простое веб-приложение на Flask, которое отвечает `"Hello, DevOps!"`.
- Создан `Dockerfile` для сборки образа Flask-приложения.
- Приложение запускается в контейнере с Flask и автоматически перезапускается в случае сбоя.
- Добавлена поддержка нескольких реплик (`docker-compose.yml` → `deploy.replicas`).

### 2. Настройка балансировки нагрузки (Nginx)
- В качестве балансировщика нагрузки используется Nginx.
- Конфигурация Nginx (`nginx.conf`) проксирует запросы к Flask-приложению.
- Nginx доступен на порту `2727` и распределяет трафик между репликами приложения.

### 3. Настройка системы логирования (Fluentd + Loki)
- Все логи от Flask и Nginx собираются через **Fluentd**.
- Fluentd передает логи в **Loki**, который используется в связке с **Grafana**.
- Для проверки логов можно отправить тестовое сообщение:
  ```bash
  echo '{"tag": "flask.logs", "message": "test log"}' | nc -u -w1 localhost 24224

### 4. Настройка мониторинга (Prometheus + Grafana)

Веб-приложение предоставляет метрики в формате Prometheus через `prometheus-flask-exporter`.

- Prometheus собирает метрики с Flask-приложения
- Grafana подключается к Prometheus и визуализирует данные

#### Добавление Prometheus в Grafana
1. Войти в Grafana: [http://localhost:3000](http://localhost:3000)
2. Перейти в `Configuration → Data Sources`
3. Нажать `Add data source` → выбрать `Prometheus`
4. В поле URL указать: `http://prometheus:9090`
5. Нажать `Save & Test`

#### Проверка метрик
1. Открыть Prometheus: [http://localhost:9090](http://localhost:9090)
2. Ввести `flask_http_request_total` и нажать `Execute`
3. В Grafana можно построить дашборды с метриками

### 5. Настройка сбора логов в Grafana (Loki)

- Loki используется для хранения логов
- Fluentd передает логи в Loki
- Grafana подключается к Loki и позволяет просматривать логи

#### Добавление Loki в Grafana
1. Войти в Grafana: [http://localhost:3000](http://localhost:3000)
2. Перейти в `Configuration → Data Sources`
3. Нажать `Add data source` → выбрать `Loki`
4. В поле URL указать: `http://loki:3100`
5. Нажать `Save & Test`

#### Проверка логов
1. Перейти в Grafana → `Explore`
2. Выбрать источник данных `Loki`
3. Ввести `{job="flask.logs"}` и запустить поиск

### 6. Автоматизация деплоя (CI/CD через GitHub Actions)

В `.github/workflows/` настроен workflow для автоматического деплоя:
- При пуше в ветку `feature` выполняется деплой на staging
- При пуше в `main` происходит деплой на production

### 7. Механизм отката (rollback)

В случае ошибки можно откатиться на предыдущий образ:
```bash
docker-compose pull && docker-compose up -d
