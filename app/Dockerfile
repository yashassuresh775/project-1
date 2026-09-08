FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=5 \
  CMD curl -fsS http://127.0.0.1:5000/api/health || exit 1

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
