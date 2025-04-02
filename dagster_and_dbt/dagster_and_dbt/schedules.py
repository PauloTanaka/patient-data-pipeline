import dagster as dg

from .jobs import ingest_patient_job

patient_update_schedule = dg.ScheduleDefinition(
    job=ingest_patient_job,
    cron_schedule="0 0 5 * *",
)