# Тестовое задание для вакансии DevOps Junior / Сайт CV

## Описание проекта

Данный проект был создан в рамках тестового задания на позицию DevOps Junior в компанию [ООО «Интеллектика»](https://intellectika.ru/), чтобы проверить мои навыки в области автоматизации, настройки CI/CD, мониторинга и обеспечения надёжности инфраструктуры. ***Но в процесе выполнения я так увлёкся, что на базе созданной инфраструктуры реализовал свой сайт CV.***
Сам проект представляет собой инфраструктуру для развертывания веб-приложения с использованием Docker и инструментов DevOps. Реализовано автоматическое развертывание, логирование, мониторинг, балансировка нагрузки и механизм отката (rollback).

## Структура проекта

```
test-devops-task/
   ├── .github/                 # Директория GitHub Actions для CI/CD
     ├── workflows/             # Директория workflows
       ├── ci-cd.yml            # Конфигурация CI/CD
   ├── app/                     # Директория WEB-приложения
     ├── static/                # Директория CSS стилей
       ├── styles.css           # CSS стили ждя WEB-приложения
     ├── templates/             # Директория CSS стилей
       ├── styles.css           # CSS стили ждя WEB-приложения
     ├── main.py                # Код Flask-приложения
     ├── requirements.txt       # Зависимости для подгрузки библиотек
   ├── Dockerfile               # Сборка Flask-приложения
   ├── README.md                # Документация проекта
   ├── docker-compose.yml       # Конфигурация контейнеров
   ├── fluentd.conf             # Конфигурация Fluentd
   ├── loki-config.yml          # Конфигурация Loki
   ├── nginx.conf               # Конфигурация Nginx
   └── prometheus.yml           # Конфигурация Prometheus
```

## Выполненные задачи

### 1. Развертывание WEB-приложения
- Разработано WEB-приложение, представляющее собой Сайт СV (Python + Flask - бэкенд, HTML + CSS - фронтенд).
- Создан `Dockerfile` для сборки образа WEB-приложения.
- Собранный образ опубликован на [DockerHub](https://hub.docker.com/repository/docker/vladim1rzolotarev/flask-app/general).
- Запуск контейнера осуществляется на [VDS Yandex Cloud](http://89.169.153.58:2727/).
- Приложение имеет возможность масщтабирования и репликации через DockerCompose.
- Для балансировки нагрузки между репликациями используется Nginx
- Конфигурация Nginx (`nginx.conf`) проксирует запросы к Flask.
- Nginx распределяет трафик между репликами приложения.

### 2. Автоматический деплой на staging/production окружение

Для реализации автоматического деплоя и отката в проекте используется `GitHub Actions`.

#### Автоматический деплой включает следующие этапы:
1. Определение окружения:
   - Для ветки `master` используется тег `latest` и окружение `production`
   - Для ветки `feature` - тег `staging` и окружение `staging`
2. Автоматическая сборка и публикация образа на DockerHub:
   ```bash
   docker build -t $DOCKER_IMAGE:$TAG .
   docker push $DOCKER_IMAGE:$TAG
   ```
3. Деплой на сервер:
   - Подключение по SSH к целевому серверу
   - Остановка текущих контейнеров
   - Запуск новых контейнеров с новым образом
   - Проверка успешного запуска контейнеров (если проверка не прошла запускается Rollback)

### 3. Реализация механизма отката (Rollback)

Автоматический откат срабатывает при следующих условиях:
- Если контейнеры не запустились успешно в течение 10 секунд
- Если основной job `deploy` завершился с ошибкой

#### Процесс отката включает следующие этапы:
1. Загрузка предыдущего стабильного образа (с тегом `rollback`)
   ```bash
   docker pull vladim1rzolotarev/flask-app:rollback
   ```
2. Перезапись тега текущего образа
   ```bash
   docker tag vladim1rzolotarev/flask-app:rollback vladim1rzolotarev/flask-app:$TAG
   ```
3. Перезапуск контейнеров с последнего стабильного образа
   ```bash
   docker compose down
   docker compose up -d
   ```

### 4. Реализация интсрументов для сбора данных и мониторинга (Prometheus + Grafana)

Для обеспечения мониторинга в проекте используются в связке `Prometheus` и `Grafana`:
- Prometheus собирает метрики с WEB-приложения через `prometheus-flask-exporter`
- Grafana подключается к Prometheus и визуализирует данные

#### Процесс просмотра данных Prometheus в Grafana:
1. Войти в [Grafana](http://89.169.153.58:3000)
2. Перейти в `Configuration → Data Sources`
3. Нажать `Add data source` → выбрать `Prometheus`
4. В поле URL указать: `http://prometheus:9090`
5. Нажать `Save & Test`
6. После чего в Grafana можно построить дашборды с метриками

### 3. Настройка системы логирования (Fluentd + Loki)
- Все логи от Flask и Nginx собираются через **Fluentd**.
- Fluentd передает логи в **Loki**, который используется в связке с **Grafana**.
- Для проверки логов можно отправить тестовое сообщение:
```bash
  echo '{"tag": "flask.logs", "message": "test log"}' | nc -u -w1 localhost 24224
```

### 5. Настройка сбора логов (Loki + Grafana)

- Fluentd передает логи в Loki
- Loki используется для хранения логов
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




### 9. Установка и запуск
Клонируйте репозиторий:
```bash
git clone https://github.com/Vladim1rZolotarev/test-devops-task.git
cd test-devops-task
```
Запустите сервисы через Docker Compose:
```bash
docker-compose up --build -d
```

### 10. Доступ к сервисам:
WEB-приложение/CV сайт (проксируется через Nginx): `http://localhost:2727`
Grafana (метрики и логи): `http://localhost:3000``

### 11. Описание сервисов
####Flask-приложение
Запускается в контейнере, принимает HTTP-запросы

Включает экспорт метрик Prometheus

Nginx (балансировщик нагрузки)
Перенаправляет запросы на реплики Flask-приложения

Работает на порту 2727

Prometheus (мониторинг)
Сборщик метрик, получает данные от Flask-приложения

Grafana (дашборды)
Визуализирует метрики Prometheus

Для входа используется логин admin и пароль admin (по умолчанию)

Fluentd (логирование)
Собирает логи Flask и Nginx, передает их в Loki

Loki (хранение логов)
Сохраняет логи, доступные через Grafana

Настройка томов для хранения данных
Чтобы Grafana, Loki и Fluentd сохраняли данные после перезапуска, используются Docker volumes.

Конфигурация в docker-compose.yml:

```yaml
Copy
services:
  grafana:
    volumes:
      - grafana_data:/var/lib/grafana
  loki:
    volumes:
      - loki_data:/loki
  fluentd:
    volumes:
      - fluentd_logs:/fluentd/log

volumes:
  grafana_data:
  loki_data:
  fluentd_logs:
```
Автоматический деплой (CI/CD)
Настроенный workflow в GitHub Actions:

Push в feature → деплой на staging

Push в main → деплой на production

Rollback (откат на предыдущую версию):
bash
Copy
docker-compose pull && docker-compose up -d
Автор
Vladimir Zolotarev
