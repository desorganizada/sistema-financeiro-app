FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia requirements.txt
COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o conteúdo de backend para /app/backend (preserva estrutura)
COPY backend/ ./backend/

# Ajusta o PYTHONPATH para incluir /app/backend
ENV PYTHONPATH=/app/backend

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Inicia a partir do módulo correto
CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8080}"]