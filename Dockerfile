FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN pip install --no-cache-dir Flask requests flask-cors
COPY cxdengine.py .
EXPOSE 8080
CMD ["python", "cxdengine.py"]
