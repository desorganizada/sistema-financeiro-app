from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status, Form
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.imports import ImportCSVResponse, ImportOFXResponse
from app.services.import_service import import_transactions_from_csv
from app.services.import_ofx_service import import_transactions_from_ofx

router = APIRouter(prefix="/imports", tags=["Imports"])


@router.post("/csv", response_model=ImportCSVResponse)
async def import_csv_transactions(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not file.filename.endswith(".csv"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Envie um arquivo CSV válido"
        )

    content = await file.read()

    result = import_transactions_from_csv(db, current_user.id, content)
    return result


@router.post("/ofx", response_model=ImportOFXResponse)
async def import_ofx_transactions(
    file: UploadFile = File(...),
    account_id: int = Form(...),
    category_id: int = Form(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not file.filename.endswith(".ofx"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Envie um arquivo OFX válido"
        )

    content = await file.read()

    result = import_transactions_from_ofx(
        db=db,
        user_id=current_user.id,
        file_content=content,
        account_id=account_id,
        category_id=category_id,
    )
    return result