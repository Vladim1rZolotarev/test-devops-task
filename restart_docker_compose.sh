#!/bin/bash

cd /home/vladimir/test-devops-task/

# Остановка и удаление контейнеров
sudo docker compose down

# Сборка образов без использования кэша
sudo docker compose build --no-cache

# Запуск контейнеров в фоновом режиме
sudo docker compose up -d

echo "Docker containers have been restarted successfully."
