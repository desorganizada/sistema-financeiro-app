from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.auth import router as auth_router
from app.api.routes.accounts import router as accounts_router
from app.api.routes.categories import router as categories_router
from app.api.routes.transactions import router as transactions_router
from app.api.routes.dashboard import router as dashboard_router
from app.api.routes.budgets import router as budgets_router
from app.api.routes.imports import router as imports_router
from app.api.routes.monthly_closures import router as monthly_closures_router
from app.api.routes.exchange_rate import router as exchange_rate_router
from app.api.routes.users import router as users_router
from app.api.routes.category_rules import router as category_rules_router

app = FastAPI(title="Sistema Financeiro API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(accounts_router)
app.include_router(categories_router)
app.include_router(transactions_router)
app.include_router(dashboard_router)
app.include_router(budgets_router)
app.include_router(imports_router)
app.include_router(monthly_closures_router)
app.include_router(exchange_rate_router)
app.include_router(users_router)
app.include_router(category_rules_router)

@app.get("/")
def read_root():
    return {"message": "API do Sistema Financeiro rodando"}