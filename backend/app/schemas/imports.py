from pydantic import BaseModel


class ImportCSVResponse(BaseModel):
    created_count: int
    skipped_count: int
    errors_count: int
    errors: list[str]


class ImportOFXResponse(BaseModel):
    created_count: int
    skipped_count: int
    errors_count: int
    errors: list[str]