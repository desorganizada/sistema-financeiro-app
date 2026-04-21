from app.db.database import Base, engine
from app.models.user import User
from app.models.account import Account
from app.models.category import Category
from app.models.transaction import Transaction
from app.models.budget import Budget


def init_db():
    Base.metadata.create_all(bind=engine)


if __name__ == "__main__":
    init_db()