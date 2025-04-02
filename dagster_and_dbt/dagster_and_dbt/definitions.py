import dagster as dg
from dagster_dbt import DbtCliResource

from .jobs import ingest_patient_job
from .schedules import patient_update_schedule
from .assets import run_dbt

all_jobs = [ingest_patient_job] 
all_schedules = [patient_update_schedule]
dbt_resource = DbtCliResource(
    project_dir="dagster_and_dbt\dbt_project",
    profiles_dir="dagster_and_dbt\dbt_project"
)
all_assets = [run_dbt]

defs = dg.Definitions(
    assets=all_assets,
    jobs=all_jobs,
    schedules=all_schedules,
    resources={
        "dbt": dbt_resource,
    },
)