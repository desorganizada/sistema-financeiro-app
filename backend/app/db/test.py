# test_db.py
from app.db.database import engine

try:
    connection = engine.connect()
    print("Conectado com sucesso!")
    connection.close()
except Exception as e:
    print("Erro:", e)