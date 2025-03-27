# Используем официальный образ Python
FROM python:3.10-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы в контейнер
COPY app/ app/
COPY app/requirements.txt .

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Используем gunicorn для запуска
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app.main:app"]
