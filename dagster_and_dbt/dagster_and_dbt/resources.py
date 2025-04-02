import os
from dagster import resource
from minio import Minio
from sqlalchemy import create_engine

@resource
def get_minio_client():
    """Returns a configured MinIO client"""
    return Minio(
        endpoint=os.getenv("MINIO_ENDPOINT", "localhost:9000"),
        access_key=os.getenv("MINIO_ACCESS_KEY", "admin"),
        secret_key=os.getenv("MINIO_SECRET_KEY", "admin123"),
        secure=False
    )

@resource
def get_postgres_engine():
    """Returns a SQLAlchemy engine to connect to PostgreSQL"""
    db_user = os.getenv("POSTGRES_USER", "postgres")
    db_password = os.getenv("POSTGRES_PASSWORD", "admin")
    db_host = os.getenv("POSTGRES_HOST", "localhost")
    db_port = os.getenv("POSTGRES_PORT", "5432")
    db_name = os.getenv("POSTGRES_DB", "promptly")

    db_url = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    return create_engine(db_url)
