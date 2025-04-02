# Standard library
import io
from io import BytesIO

# Third-party libraries
import pandas as pd
from sqlalchemy import text
from dagster import op, job, graph, get_dagster_logger

# Internal modules
from dagster_and_dbt.resources import get_minio_client, get_postgres_engine
from dagster_and_dbt.assets import run_dbt
from dagster_and_dbt.constants import (
    PATIENT_CSV_FILE,
    MINIO_BUCKET_NAME,
    RAW_PATIENT_TABLE,
    minio_invalid_emails_path,
)

logger = get_dagster_logger()

@op
def extract_patient_csv_file_from_minio() -> pd.DataFrame:
    client = get_minio_client()

    logger.info(f"Downloading {PATIENT_CSV_FILE} from bucket {MINIO_BUCKET_NAME}...")
    response = client.get_object(MINIO_BUCKET_NAME, PATIENT_CSV_FILE)
    csv_bytes = response.read()

    encodings = ['utf-8', 'latin-1', 'ascii', 'ISO-8859-1']
    df = None
    for encoding in encodings:
        try:
            decoded_str = csv_bytes.decode(encoding)
            df = pd.read_csv(BytesIO(decoded_str.encode(encoding)), dtype=str, encoding=encoding)
            logger.info(f"Successfully decoded file using '{encoding}' encoding.")
            break
        except UnicodeDecodeError:
            logger.warning(f"Failed to decode using '{encoding}'. Trying next encoding...")

    if df is None:
        raise ValueError("Unable to decode file with any of the tested encodings.")

    logger.info(f"File {PATIENT_CSV_FILE} loaded successfully with {len(df)} records.")
    return df

@op
def filter_invalid_emails_and_save_to_minio(df: pd.DataFrame) -> pd.DataFrame:
    email_regex = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
    df_invalid = df[~df['email'].fillna('').str.match(email_regex, na=False)]

    if not df_invalid.empty:
        logger.warning(f"{len(df_invalid)} records with invalid email found. Example: {df_invalid['email'].head(1).values[0]}")
        
        minio_client = get_minio_client()
        csv_buffer = io.BytesIO()
        df_invalid.to_csv(csv_buffer, index=False)
        csv_buffer.seek(0)

        object_name = minio_invalid_emails_path()
        minio_client.put_object(
            bucket_name=MINIO_BUCKET_NAME,
            object_name=object_name,
            data=csv_buffer,
            length=csv_buffer.getbuffer().nbytes,
            content_type="application/csv"
        )

        logger.info(f"Invalid emails saved to MinIO at {object_name}")

    df_valid = df[df['email'].fillna('').str.match(email_regex, na=False)]
    return df_valid


@op
def load_valid_records_to_postgres(df: pd.DataFrame) -> str:
    engine = get_postgres_engine()

    try:
        logger.info(f"Loading data into table {RAW_PATIENT_TABLE}...")
        with engine.begin() as conn:
            conn.execute(text(f"TRUNCATE TABLE {RAW_PATIENT_TABLE}"))
        df.to_sql("raw_patient", engine, schema="staging", if_exists="append", index=False)
        logger.info("Load completed successfully.")
    except Exception as e:
        logger.error(f"Error while loading data into PostgreSQL: {e}")
        raise

    return f"Inserted {len(df)} valid records into {RAW_PATIENT_TABLE}"

@op
def run_dbt_models(after_load: str) -> None:
    run_dbt()

@graph
def ingest_patient_graph():
    df = extract_patient_csv_file_from_minio()
    df_valid = filter_invalid_emails_and_save_to_minio(df)
    result = load_valid_records_to_postgres(df_valid)
    run_dbt_models(result)

@job
def ingest_patient_job():
    ingest_patient_graph()