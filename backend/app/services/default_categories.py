from app.models.category import Category

DEFAULT_CATEGORIES = [
    {"name": "Salário", "type": "income", "group_name": None},
    {"name": "Freelance", "type": "income", "group_name": None},
    {"name": "Outras Receitas", "type": "income", "group_name": None},

    {"name": "Aluguel", "type": "expense", "group_name": "fixa"},
    {"name": "Condomínio", "type": "expense", "group_name": "fixa"},
    {"name": "Internet", "type": "expense", "group_name": "fixa"},
    {"name": "Energia", "type": "expense", "group_name": "fixa"},
    {"name": "Água", "type": "expense", "group_name": "fixa"},
    {"name": "Telefone", "type": "expense", "group_name": "fixa"},

    {"name": "Supermercado", "type": "expense", "group_name": "variavel"},
    {"name": "Transporte", "type": "expense", "group_name": "variavel"},
    {"name": "Combustível", "type": "expense", "group_name": "variavel"},
    {"name": "Lazer", "type": "expense", "group_name": "variavel"},
    {"name": "Restaurantes", "type": "expense", "group_name": "variavel"},
    {"name": "Saúde", "type": "expense", "group_name": "variavel"},
    {"name": "Educação", "type": "expense", "group_name": "variavel"},
    {"name": "Compras", "type": "expense", "group_name": "variavel"},

    {"name": "Emergências", "type": "expense", "group_name": "extra"},
    {"name": "Manutenção", "type": "expense", "group_name": "extra"},
    {"name": "Viagens", "type": "expense", "group_name": "extra"},

    {"name": "Aporte Mensal", "type": "investment", "group_name": None},
    {"name": "Reserva de Emergência", "type": "investment", "group_name": None},
]


def create_default_categories(db, user_id: int):
    categories = []

    for item in DEFAULT_CATEGORIES:
        category = Category(
            name=item["name"],
            type=item["type"],
            group_name=item["group_name"],
            user_id=user_id,
        )
        categories.append(category)

    db.add_all(categories)
    db.commit()