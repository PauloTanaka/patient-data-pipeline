from datetime import datetime
from dagster_and_dbt.constants import minio_invalid_emails_path

def test_get_invalid_emails_path():
    today_str = datetime.today().strftime("%Y-%m-%d")
    expected = f"logs/{today_str}/invalid_emails.csv"
    assert minio_invalid_emails_path() == expected