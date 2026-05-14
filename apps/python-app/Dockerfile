FROM python:3.6-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

# VULN: running as root (no USER directive)
CMD ["python", "app.py"]
