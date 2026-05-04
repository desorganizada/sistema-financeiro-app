from sqlalchemy import Column, Integer, ForeignKey, Numeric, DateTime
from sqlalchemy.sql import func
from app.db.database import Base


class MonthlyClosure(Base):
    __tablename__ = "monthly_closures"

    id = Column(Integer, primary_key=True, index=True)
    year = Column(Integer, nullable=False)
    month = Column(Integer, nullable=False)

    income = Column(Numeric(12, 2), nullable=False, default=0)
    expense = Column(Numeric(12, 2), nullable=False, default=0)
    investment = Column(Numeric(12, 2), nullable=False, default=0)
    balance = Column(Numeric(12, 2), nullable=False, default=0)

    transactions_count = Column(Integer, nullable=False, default=0)

    closed_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    