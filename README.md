# Healthcare Patient Pipeline with Dagster, dbt, PostgreSQL, and MinIO

## ✨ Overview

This project implements a complete data pipeline that ingests patient data from a CSV file stored in MinIO, validates and loads it into a PostgreSQL database, and transforms it using dbt to generate clean and standardized data in FHIR format.

This solution is part of a data engineering challenge and demonstrates good practices around modularization, error handling, validation, and orchestration.

---

## 🚀 Architecture

### Tools & Technologies
- **Dagster**: Orchestrator used to manage the pipeline steps
- **MinIO**: Object storage used to store the input CSV and logs
- **PostgreSQL**: Database to store raw and transformed data
- **dbt (Data Build Tool)**: Used for SQL-based transformations and testing
- **pytest**: Unit testing framework for Python
- **Docker**: Used to spin up MinIO
- **pandas / SQLAlchemy**: Data processing and database interaction in Python

### Pipeline Flow
1. **extract_from_minio**: Reads the CSV file (`patient.csv`) from the `csv-data` bucket in MinIO. Tries multiple encodings.
2. **load_to_postgres**:
   - Validates email format using regex
   - Logs invalid emails into a separate CSV in `logs/YYYY-MM-DD/invalid_emails.csv`
   - Loads valid records into PostgreSQL table `staging.raw_patient`
3. **run_dbt**:
   - Executes dbt models:
     - `fhir_patient`: Cleaned data in FHIR format
     - `fhir_patient_errors`: Captures invalid records

---

## 📃 Project Structure
```
dagster_and_dbt/
├── dagster_and_dbt/
│   ├── assets/              # DBT trigger function
│   ├── resources.py         # MinIO and PostgreSQL connection resources
│   ├── constants.py         # Centralized constants (e.g., paths, bucket)
│   ├── jobs.py              # Dagster job with ops and graph
│   ├── dbt_project/         # dbt models and config
│   │   ├── models/
│   │   ├── tests/
│   │   └── ...
│   └── tests/               # Unit tests for validation logic
├── .env                     # Local credentials (not committed)
└── README.md
```

---

## 🔧 Setup & Execution

### Requirements
- Python 3.12+
- PostgreSQL running locally
- MinIO via Docker
- dbt (installed via pip or brew)

### 1. Start MinIO via Docker
```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=admin123 \
  quay.io/minio/minio server /data --console-address ":9001"
```

### 2. Load `patient.csv` to MinIO
```bash
mc alias set local http://localhost:9000 admin admin123
mc mb local/csv-data
mc cp patient.csv local/csv-data/
```

### 3. Run the Dagster job
```bash
dagster dev
```
Then trigger `ingest_patient_job` from the UI or Python API.

### 4. Run dbt manually (optional)
```bash
cd dagster_and_dbt/dagster_and_dbt/dbt_project
dbt run
dbt test
dbt docs generate && dbt docs serve
```

### 5. Run Unit Tests
```bash
PYTHONPATH=dagster_and_dbt pytest dagster_and_dbt/dagster_and_dbt/tests/
```

---

## 💡 Highlights
- ✅ Email validation before DB insertion
- ✅ Invalid records are not lost (stored in MinIO logs)
- ✅ Unit tests and dbt tests implemented
- ✅ Modular code and centralized constants
- ✅ Structured following best practices in data engineering

---

## 🤝 Author
**Paulo Tadao Ijichi Tanaka**