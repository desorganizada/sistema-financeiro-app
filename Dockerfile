FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Define o diretório de trabalho como /app/backend
WORKDIR /app/backend

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia o requirements.txt da pasta backend
COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o conteúdo da pasta backend para o diretório atual (/app/backend)
COPY backend/ .

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Comando de inicialização simples e direto
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]