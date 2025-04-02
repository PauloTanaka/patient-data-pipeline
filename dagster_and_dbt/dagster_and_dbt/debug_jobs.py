import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from dagster_and_dbt.jobs import ingest_patient_job

if __name__ == "__main__":
    result = ingest_patient_job.execute_in_process()
