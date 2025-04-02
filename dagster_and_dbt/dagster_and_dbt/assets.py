from dagster import AssetExecutionContext, asset
from dagster_dbt import DbtCliResource

# Definition of the dbt resource
dbt_cli = DbtCliResource(project_dir="dagster_and_dbt/dbt_project")

@asset(
    group_name="transform_dbt",
    compute_kind="dbt",
    description="Run a dbt model in Dagster"
)
def run_dbt(): 
    """Run the 'dbt run' command within Dagster"""
    
    result = dbt_cli.cli(["run"])

    return "dbt run completed"

