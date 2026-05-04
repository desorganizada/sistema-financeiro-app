from sqlalchemy import Column, Integer, String, ForeignKey, Date, Numeric
from app.db.database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    description = Column(String, nullable=False)
    type = Column(String, nullable=False)  # income, expense, investment

    amount_original = Column(Numeric(12, 2), nullable=False)
    original_currency = Column(String, nullable=False, default="BRL")
    exchange_rate = Column(Numeric(12, 6), nullable=False, default=1)
    amount_converted = Column(Numeric(12, 2), nullable=False)

    date = Column(Date, nullable=False)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    account_id = Column(Integer, ForeignKey("accounts.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)