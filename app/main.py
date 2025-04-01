from flask import Flask, render_template
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

visit_counter = metrics.counter(
    'visit_counter', 'Number of visits to the resume page',
    labels={'status': lambda resp: resp.status_code}
)


@app.route("/")
@visit_counter
def home():
    return render_template('index.html')


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
