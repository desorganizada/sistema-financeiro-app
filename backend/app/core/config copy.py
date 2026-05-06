import os
from dotenv import load_dotenv

load_dotenv()

# Banco de dados
DATABASE_URL = os.getenv("DATABASE_URL")

# Segurança - JWT
SECRET_KEY = os.getenv("SECRET_KEY", "sua-chave-secreta-muito-segura-aqui-mude-para-producao")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

# 🔧 ALTERADO: Agora usa HORAS em vez de MINUTOS para maior duração
ACCESS_TOKEN_EXPIRE_HOURS = int(os.getenv("ACCESS_TOKEN_EXPIRE_HOURS", "24"))  # 24 horas
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "30"))  # 30 dias

# API de câmbio
EXCHANGE_API_BASE_URL = os.getenv("EXCHANGE_API_BASE_URL", "https://api.frankfurter.dev/v1")

# 🔧 Adicionado: Configurações do CORS
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:8000,http://127.0.0.1:8000").split(",")

# 🔧 Adicionado: Timeouts
CONNECTION_TIMEOUT = int(os.getenv("CONNECTION_TIMEOUT", "30"))

# ==================== Configurações para compatibilidade ====================
# Mantém as variáveis existentes para não quebrar outros arquivos
ACCESS_TOKEN_EXPIRE_MINUTES = ACCESS_TOKEN_EXPIRE_HOURS * 60  # Converte horas para minutos

# Cria um objeto Settings para compatibilidade com o código existente
class Settings:
    def __init__(self):
        self.DATABASE_URL = DATABASE_URL
        self.SECRET_KEY = SECRET_KEY
        self.ALGORITHM = ALGORITHM
        self.ACCESS_TOKEN_EXPIRE_MINUTES = ACCESS_TOKEN_EXPIRE_MINUTES
        self.EXCHANGE_API_BASE_URL = EXCHANGE_API_BASE_URL
        self.ALLOWED_ORIGINS = ALLOWED_ORIGINS
        self.CONNECTION_TIMEOUT = CONNECTION_TIMEOUT


settings = Settings()