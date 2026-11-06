from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Amar Dokan API"
    api_v1_prefix: str = "/api/v1"
    database_url: str = "sqlite:///./amar_dokan.db"
    secret_key: str = "amar_dokan_super_secret_jwt_key_at_least_32_bytes_long"
    access_token_expire_minutes: int = 60 * 24 * 7  # 7 days for development convenience
    refresh_token_expire_days: int = 30
    cors_origins: str = "*"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    @property
    def cors_origin_list(self) -> list[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
