FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Define o diretório de trabalho como /app/backend
# Isso faz com que o Python veja a pasta "app" como um pacote
WORKDIR /app/backend

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia requirements.txt (está em backend/)
COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o conteúdo de backend/ para /app/backend
COPY backend/ .

# (Opcional) Garante que exista __init__.py na pasta app para ser reconhecida como pacote
# Se não existir, crie um vazio no repositório ou rode:
RUN touch app/__init__.py

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Comando correto: uvicorn app.main:app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]