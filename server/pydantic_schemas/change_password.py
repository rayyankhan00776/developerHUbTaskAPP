# pydantic_schemas/change_password.py
from pydantic import BaseModel, EmailStr

class ChangePasswordRequest(BaseModel):
    email: EmailStr
    current_password: str
    new_password: str
