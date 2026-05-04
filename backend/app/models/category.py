from sqlalchemy import Column, Integer, String, ForeignKey
from app.db.database import Base


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    type = Column(String, nullable=False)  # income, expense, investment
    group_name = Column(String, nullable=True)  # fixa, variavel, extra, adicional
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)