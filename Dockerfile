FROM python:alpine
WORKDIR /app

# Установка необходимых пакетов
RUN apk add --no-cache curl

# Создание директории для логов
RUN mkdir -p /app/logs && chmod 777 /app/logs

# Копирование файлов приложения
COPY app/ app/
COPY app/requirements.txt .

# Установка зависимостей
RUN pip install --no-cache-dir -r requirements.txt

# Настройка переменных окружения
ENV PYTHONUNBUFFERED=1

# Запуск приложения с несколькими рабочими процессами
CMD ["gunicorn", "--workers=4", "--threads=2", "--access-logfile=/app/logs/gunicorn-access.log", "--error-logfile=/app/logs/gunicorn-error.log", "--bind=0.0.0.0:5000", "app.main:app"]
