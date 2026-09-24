# AgriSense ML Service

This directory contains:
- `data/`: Dataset generation script (`generate_dataset.py`) and dataset inspection tool (`inspect_dataset.py`).
- `training/`: XGBoost model training script (`train_models.py`) evaluating 9 independent single-output regression models vs Persistence Baseline.
- `models/`: Exported JSON model artifacts (`temp_6h.json`, `hum_10h.json`, `soil_24h.json`, etc.).
- `app/`: FastAPI web server exposing `/health` and `POST /predict`.
