import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
load_dotenv()
# Remove o load_dotenv() em produção (usaremos secrets do Fly.io)
DATABASE_URL = os.getenv("DATABASE_URL")

# Ajusta URL do Fly.io se necessário
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Configuração otimizada para produção
engine = create_engine(
    DATABASE_URL,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,       # Verifica conexão antes de usar
    pool_recycle=3600         # Recicla conexões a cada 1 hora
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()