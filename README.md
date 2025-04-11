# Patient Data Ingestion and Transformation

## Objective
The goal of this pipeline is to ingest a CSV file containing patient data into a local PostgreSQL database, transform the data into a standardized FHIR Patient table using Dagster and dbt, and analyze both the clean data and any quality issues using Power BI.

---

## Technologies Used

- **MinIO (via Docker):** Simulated object storage for uploading and storing the patient CSV file.
- **PostgreSQL (local):** Relational database used to store both raw and transformed data.
- **Dagster:** Orchestrates the pipeline execution, from extraction to transformation.
- **dbt:** Performs data modeling, transformation, validation, and testing.
- **Power BI:** Used for data visualization, showcasing both the final model and validation insights.

---

## How to Re-run the Process

### Start MinIO and PostgreSQL
Ensure your Docker containers for MinIO and PostgreSQL are running.

### Upload the CSV to MinIO
Place the `patient.csv` file in the configured bucket (e.g., `raw`) using the MinIO UI or AWS CLI.

### Run the Dagster Job
Trigger the `ingest_patient_job` in Dagster. This job performs:

1. **Extraction** of the CSV file from MinIO.
2. **Filtering** out rows with invalid emails (logged separately to MinIO).
3. **Loading** valid records into the `staging.raw_patient` table in PostgreSQL.
4. **Execution** of dbt transformations using `dbt run`.

### Run dbt Tests (Optional but Recommended)
From the dbt project directory, run:

```bash
dbt test --select fhir_patient
```

---

## Dagster Pipeline

The Dagster job `ingest_patient_job` is composed of the following steps:

- `extract_patient_csv_file_from_minio`: Reads the patient CSV file from MinIO.
- `filter_invalid_emails_and_save_to_minio`: Filters invalid emails and logs them.
- `load_valid_records_to_postgres`: Loads valid data into the `staging.raw_patient` table.
- `run_dbt_models`: Executes the dbt models to perform transformations.

Each run ensures a fresh and consistent view of the patient data.

---

## 🧱 dbt Project Overview

- **stg_patient**: Performs cleaning and standardization (e.g., gender normalization, email and insurance validations, address formatting).
- **fhir_patient**: Deduplicates valid patients and structures data to follow the FHIR standard.
- **fhir_patient_quality_issues**: Stores rows with known data issues (e.g., missing name, invalid gender).
- **repeated_insurance_numbers**: Identifies multiple entries with the same `insurance_number`.

#### Quality outputs:

- `patient_with_errors`: Shows invalid or incomplete records.
- `repeated_patients_by_insurance_number`: Flags duplicated entries.

---
### Tests and Validations

- **Generic tests**: `not null`, `unique`, and `accepted values` on key fields.
- **Custom tests**: Validation of insurance number, marital status, language, state, email, and address.
- **Quality outputs**:
  - `patient_with_errors`: Shows invalid or incomplete records.
  - `repeated_patients_by_insurance_number`: Flags duplicated entries.

---

## Power BI Dashboards

Two dashboards were built:

- **FHIR Patient Analysis**: Shows the transformed and cleaned patient data.
- **Data Quality Insights**: Highlights invalid records and common quality issues based on dbt validation outputs.

These dashboards provide insights on data completeness, field standardization, and duplicate issues.