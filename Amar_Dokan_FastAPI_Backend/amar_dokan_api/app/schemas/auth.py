from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    full_name: Optional[str] = Field(default=None, max_length=120)
    name: Optional[str] = Field(default=None, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    phone_number: Optional[str] = Field(default=None, max_length=30)

    @model_validator(mode="after")
    def populate_aliases(self) -> "RegisterRequest":
        if not self.full_name and self.name:
            self.full_name = self.name
        elif not self.full_name:
            self.full_name = self.email.split("@")[0]
        if not self.phone and self.phone_number:
            self.phone = self.phone_number
        return self


class LoginRequest(BaseModel):
    email: Optional[str] = None
    username: Optional[str] = None
    phone: Optional[str] = None
    email_or_phone: Optional[str] = None
    password: str = Field(min_length=1, max_length=128)

    @model_validator(mode="after")
    def validate_identifier(self) -> "LoginRequest":
        ident = self.email or self.username or self.phone or self.email_or_phone
        if not ident or not ident.strip():
            raise ValueError("Email or phone number is required")
        return self

    @property
    def identifier(self) -> str:
        return (self.email or self.username or self.phone or self.email_or_phone or "").strip()


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=10)


class LogoutRequest(BaseModel):
    refresh_token: Optional[str] = None


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str
    new_password: str = Field(min_length=6, max_length=128)


class VerifyEmailRequest(BaseModel):
    email: EmailStr
    code: str


class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    name: str = ""
    phone: Optional[str] = None
    phone_number: Optional[str] = None
    role: str = "owner"
    is_email_verified: bool = True
    is_active: bool = True
    active_shop_id: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_name_and_phone(self) -> "UserResponse":
        if not self.name:
            self.name = self.full_name
        if not self.phone_number and self.phone:
            self.phone_number = self.phone
        elif not self.phone and self.phone_number:
            self.phone = self.phone_number
        return self


class AuthTokensModel(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class TokenResponse(BaseModel):
    token_type: str = "Bearer"
    access_token: str
    refresh_token: str
    access_expires_in: int
    user: UserResponse
    tokens: Optional[AuthTokensModel] = None

    @model_validator(mode="after")
    def set_tokens(self) -> "TokenResponse":
        if self.tokens is None:
            self.tokens = AuthTokensModel(
                access_token=self.access_token,
                refresh_token=self.refresh_token,
                token_type=self.token_type,
            )
        return self
