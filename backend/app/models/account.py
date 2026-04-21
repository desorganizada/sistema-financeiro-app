from sqlalchemy import Column, Integer, String, ForeignKey
from app.db.database import Base


class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    type = Column(String, nullable=False)  # corrente, cartão, carteira
    currency = Column(String, nullable=False, default="BRL")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)