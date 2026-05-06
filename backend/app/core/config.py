# app/core/config.py

import os
from dotenv import load_dotenv

load_dotenv()

# Banco de dados
DATABASE_URL = os.getenv("DATABASE_URL")

# 🔧 IMPORTANTE: Use a mesma SECRET_KEY em todo lugar
SECRET_KEY = os.getenv("SECRET_KEY", "sua-chave-secreta-muito-segura-aqui-mude-para-producao")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

# Token expiration
ACCESS_TOKEN_EXPIRE_HOURS = int(os.getenv("ACCESS_TOKEN_EXPIRE_HOURS", "24"))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "30"))

# API de câmbio
EXCHANGE_API_BASE_URL = os.getenv("EXCHANGE_API_BASE_URL", "https://api.frankfurter.dev/v1")

# Mantém compatibilidade
ACCESS_TOKEN_EXPIRE_MINUTES = ACCESS_TOKEN_EXPIRE_HOURS * 60

# 🔧 Exporta as variáveis diretamente
__all__ = [
    "DATABASE_URL",
    "SECRET_KEY",
    "ALGORITHM",
    "ACCESS_TOKEN_EXPIRE_HOURS",
    "REFRESH_TOKEN_EXPIRE_DAYS",
    "ACCESS_TOKEN_EXPIRE_MINUTES",
    "EXCHANGE_API_BASE_URL",
]