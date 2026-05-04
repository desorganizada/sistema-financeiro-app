from sqlalchemy.orm import Session
from app.models.monthly_closure import MonthlyClosure


def is_month_closed(db: Session, user_id: int, year: int, month: int) -> bool:
    closure = (
        db.query(MonthlyClosure)
        .filter(
            MonthlyClosure.user_id == user_id,
            MonthlyClosure.year == year,
            MonthlyClosure.month == month,
        )
        .first()
    )
    return closure is not None