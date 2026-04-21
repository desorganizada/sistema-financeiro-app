from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.category_rule import (
    CategoryRuleCreate,
    CategoryRuleUpdate,
    CategoryRuleResponse,
)
from app.services.category_rule_service import (
    create_category_rule,
    get_category_rules,
    get_category_rule_by_id,
    update_category_rule,
    delete_category_rule,
)

router = APIRouter(prefix="/category-rules", tags=["Category Rules"])


@router.post("/", response_model=CategoryRuleResponse, status_code=status.HTTP_201_CREATED)
def create_new_category_rule(
    payload: CategoryRuleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rule, error = create_category_rule(db, current_user.id, payload)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return rule


@router.get("/", response_model=list[CategoryRuleResponse])
def list_category_rules(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_category_rules(db, current_user.id)


@router.put("/{rule_id}", response_model=CategoryRuleResponse)
def edit_category_rule(
    rule_id: int,
    payload: CategoryRuleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rule = get_category_rule_by_id(db, current_user.id, rule_id)

    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Regra não encontrada",
        )

    updated_rule, error = update_category_rule(db, current_user.id, rule, payload)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return updated_rule


@router.delete("/{rule_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_category_rule(
    rule_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rule = get_category_rule_by_id(db, current_user.id, rule_id)

    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Regra não encontrada",
        )

    delete_category_rule(db, rule)
    return