from dagster import asset
from dagster_dbt import DbtCliResource

dbt_cli = DbtCliResource(project_dir="dagster_and_dbt/dbt_project")

@asset(
    group_name="transform_dbt",
    compute_kind="dbt",
    description="Run the dbt models via Dagster integration"
)
def run_dbt():
    """Executes `dbt run` and returns success message"""
    result = dbt_cli.cli(["run"]).wait()
    return "dbt run completed"