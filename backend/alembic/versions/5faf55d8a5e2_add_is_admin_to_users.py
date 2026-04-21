"""add is_admin to users

Revision ID: 5faf55d8a5e2
Revises: 9dbee11c9463
Create Date: 2026-04-14 14:40:50.992000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "5faf55d8a5e2"
down_revision: Union[str, Sequence[str], None] = "9dbee11c9463"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column(
            "is_admin",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
    )


def downgrade() -> None:
    op.drop_column("users", "is_admin")