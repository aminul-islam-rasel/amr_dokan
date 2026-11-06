import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from app.core.config import settings

logger = logging.getLogger(__name__)


class Base(DeclarativeBase):
    pass


def create_db_engine():
    db_url = settings.database_url
    if db_url.startswith("sqlite"):
        return create_engine(db_url, connect_args={"check_same_thread": False})
    try:
        # Attempt connection to Postgres with short timeout
        eng = create_engine(db_url, pool_pre_ping=True, connect_args={"connect_timeout": 2})
        with eng.connect():
            pass
        return eng
    except Exception as exc:
        logger.warning(
            "Could not connect to configured database (%s): %s. Falling back to local SQLite (sqlite:///./amar_dokan.db)",
            db_url,
            exc,
        )
        return create_engine("sqlite:///./amar_dokan.db", connect_args={"check_same_thread": False})


engine = create_db_engine()
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
