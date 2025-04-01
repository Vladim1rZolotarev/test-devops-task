FROM python:alpine
WORKDIR /app
COPY app/ app/
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app.main:app"]
