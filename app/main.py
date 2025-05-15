import os
import logging
from flask import Flask, render_template, jsonify
from prometheus_flask_exporter import PrometheusMetrics
from flask_caching import Cache
import redis

# Настройка логирования
log_dir = 'logs'
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f"{log_dir}/flask-app.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Конфигурация кэширования с Redis
cache_config = {
    "CACHE_TYPE": "redis",
    "CACHE_REDIS_HOST": "redis",
    "CACHE_REDIS_PORT": 6379,
    "CACHE_REDIS_DB": 0,
    "CACHE_DEFAULT_TIMEOUT": 300
}
app.config.from_mapping(cache_config)
cache = Cache(app)

# Проверка соединения с Redis
try:
    redis_client = redis.Redis(host='redis', port=6379, db=0)
    redis_client.ping()
    logger.info("Успешное подключение к Redis")
except redis.ConnectionError:
    logger.error("Не удалось подключиться к Redis")

visit_counter = metrics.counter(
    'visit_counter', 'Number of visits to the resume page',
    labels={'status': lambda resp: resp.status_code}
)

@app.route("/")
@visit_counter
@cache.cached(timeout=60)  # Кэширование на 60 секунд
def home():
    logger.info("Запрос к главной странице")
    return render_template('index.html')

@app.route("/health")
def health():
    # Проверка соединения с Redis
    try:
        redis_client.ping()
        redis_status = "ok"
    except:
        redis_status = "error"
        
    health_data = {
        "status": "ok",
        "redis": redis_status,
        "version": "1.0.1"
    }
    
    return jsonify(health_data)

if __name__ == "__main__":
    logger.info("Запуск Flask-приложения")
    app.run(host="0.0.0.0", port=5000, debug=False)
