# Настройка мониторинга в Grafana

Этот документ содержит инструкции по настройке дашбордов Grafana для мониторинга инфраструктуры и приложения.

## Доступ к Grafana

Grafana доступна по адресу: https://zolotarev.tech:3000

Логин по умолчанию: `admin`
Пароль по умолчанию: `secure_password` (указан в docker-compose.yml)

## Настройка источников данных

### Prometheus

1. Перейдите в `Configuration → Data Sources`
2. Нажмите `Add data source` → выберите `Prometheus`
3. В поле URL укажите: `http://prometheus:9090`
4. Нажмите `Save & Test`

### Loki

1. Перейдите в `Configuration → Data Sources`
2. Нажмите `Add data source` → выберите `Loki`
3. В поле URL укажите: `http://loki:3100`
4. Нажмите `Save & Test`

## Импорт дашбордов

### Системный мониторинг (Node Exporter)

1. Перейдите в `+ → Import`
2. Введите ID дашборда: `1860` (Node Exporter Full)
3. Выберите источник данных Prometheus
4. Нажмите `Import`

### Мониторинг Nginx

1. Перейдите в `+ → Import`
2. Введите ID дашборда: `12708` (Nginx Prometheus)
3. Выберите источник данных Prometheus
4. Нажмите `Import`

### Мониторинг Redis

1. Перейдите в `+ → Import`
2. Введите ID дашборда: `763` (Redis Dashboard for Prometheus)
3. Выберите источник данных Prometheus
4. Нажмите `Import`

### Мониторинг Flask-приложения

1. Перейдите в `+ → Import`
2. Загрузите JSON-файл дашборда из `docs/dashboards/flask-app-dashboard.json`
3. Выберите источник данных Prometheus
4. Нажмите `Import`

## Создание пользовательского дашборда

Для создания собственного дашборда:

1. Перейдите в `+ → Dashboard`
2. Нажмите `Add new panel`
3. Настройте запрос к Prometheus, например:
   - Для мониторинга посещений: `sum(increase(visit_counter_total[1h]))`
   - Для мониторинга ошибок: `sum(increase(http_request_duration_seconds_count{status=~"5.."}[1h]))`
4. Настройте визуализацию (график, счетчик и т.д.)
5. Нажмите `Apply`

## Настройка оповещений

### Создание канала оповещений для Telegram

1. Перейдите в `Alerting → Notification channels`
2. Нажмите `New channel`
3. Выберите тип `Telegram`
4. Укажите Bot API Token и Chat ID
5. Нажмите `Test` для проверки
6. Нажмите `Save`

### Создание правила оповещения

1. Перейдите на дашборд
2. Выберите панель, для которой нужно создать оповещение
3. Нажмите `Edit`
4. Перейдите на вкладку `Alert`
5. Настройте условие срабатывания
6. Укажите канал оповещений
7. Нажмите `Save`

## Просмотр логов

1. Перейдите в `Explore`
2. Выберите источник данных `Loki`
3. Введите запрос, например:
   - Для логов Nginx: `{job="nginx-logs"}`
   - Для логов Flask: `{job="flask-logs"}`
4. Нажмите `Run query`

## Полезные запросы для Loki

### Поиск ошибок в логах Nginx

```
{job="nginx-logs"} |= "error" | json | status >= 400
```

### Поиск медленных запросов

```
{job="nginx-logs"} | json | request_time > 1
```

### Поиск ошибок в логах Flask

```
{job="flask-logs"} |= "ERROR"
