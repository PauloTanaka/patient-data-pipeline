from datetime import datetime

# Bucket used to store input and log files
MINIO_BUCKET_NAME = "csv-data"

# CSV source file in MinIO
PATIENT_CSV_FILE = "patient.csv"

# Table name in PostgreSQL where raw data is loaded
RAW_PATIENT_TABLE = "staging.raw_patient"

# Generates the path for the invalid emails CSV (grouped by date)
def minio_invalid_emails_path() -> str:
    today_str = datetime.today().strftime("%Y-%m-%d")
    return f"logs/{today_str}/invalid_emails.csv"