import os
import json
import pandas as pd
import numpy as np
import xgboost as xgb
from typing import List, Dict, Any
from .schemas import TelemetryReading, PredictionResponse, HorizonPrediction

class AgriSensePredictor:
    def __init__(self, models_dir: str = None):
        if models_dir is None:
            models_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'models')
            
        self.models_dir = models_dir
        self.feature_names_path = os.path.join(models_dir, 'feature_names.json')
        self.feature_names = []
        self.models = {}
        
        self.target_keys = [
            'temp_lead_6h', 'temp_lead_10h', 'temp_lead_24h',
            'hum_lead_6h', 'hum_lead_10h', 'hum_lead_24h',
            'soil_lead_6h', 'soil_lead_10h', 'soil_lead_24h'
        ]
        self._load_models()

    def _load_models(self):
        if not os.path.exists(self.feature_names_path):
            print(f"Warning: {self.feature_names_path} not found. Models may not be trained yet.")
            return

        with open(self.feature_names_path, 'r') as f:
            self.feature_names = json.load(f)

        for target in self.target_keys:
            model_path = os.path.join(self.models_dir, f"{target}.json")
            if os.path.exists(model_path):
                model = xgb.XGBRegressor()
                model.load_model(model_path)
                self.models[target] = model
                
        print(f"AgriSense Predictor loaded {len(self.models)} / 9 XGBoost models.")

    def is_ready(self) -> bool:
        return len(self.models) == 9 and len(self.feature_names) > 0

    def predict_from_history(self, history: List[TelemetryReading]) -> Dict[str, Any]:
        if not self.is_ready():
            self._load_models()
            if not self.is_ready():
                raise RuntimeError("XGBoost models are not loaded. Ensure train_models.py has been executed.")

        # Convert history list into DataFrame
        records = [r.dict() for r in history]
        df = pd.DataFrame(records)

        # Infer is_raining if missing
        if 'is_raining' not in df.columns or df['is_raining'].isnull().any():
            df['is_raining'] = (df['rain'] < 2000).astype(int)

        # Parse hour and day of year from timestamp if available, else fallback
        if 'timestamp' in df.columns and df['timestamp'].iloc[-1] is not None:
            try:
                dt = pd.to_datetime(df['timestamp'].iloc[-1])
                hour = dt.hour
                day_of_year = dt.dayofyear
            except Exception:
                hour = 14
                day_of_year = 150
        else:
            hour = 14
            day_of_year = 150

        # Construct features for the latest observation using history window
        latest_row = df.iloc[-1]

        # Calculate lag features (if history is too short, backfill with current value)
        def get_lag(series, lag_steps):
            if len(series) > lag_steps:
                return series.iloc[-(lag_steps + 1)]
            return series.iloc[0]

        def get_rolling_mean(series, window):
            val_count = min(len(series), window)
            return series.tail(val_count).mean()

        def get_rolling_min(series, window):
            val_count = min(len(series), window)
            return series.tail(val_count).min()

        feature_dict = {
            'temperature': latest_row['temperature'],
            'humidity': latest_row['humidity'],
            'soil_moisture': latest_row['soil_moisture'],
            'rain': latest_row['rain'],
            'is_raining': int(latest_row['is_raining']),
            'ldr_value': latest_row['ldr_value'],
            'wind_speed': latest_row['wind_speed'],
            'pressure': latest_row['pressure'],
            'cloudiness': latest_row['cloudiness'],
            
            'temp_lag_1h': get_lag(df['temperature'], 1),
            'temp_lag_3h': get_lag(df['temperature'], 3),
            'temp_lag_6h': get_lag(df['temperature'], 6),
            
            'hum_lag_1h': get_lag(df['humidity'], 1),
            'hum_lag_3h': get_lag(df['humidity'], 3),
            'hum_lag_6h': get_lag(df['humidity'], 6),
            
            'soil_lag_1h': get_lag(df['soil_moisture'], 1),
            'soil_lag_3h': get_lag(df['soil_moisture'], 3),
            'soil_lag_6h': get_lag(df['soil_moisture'], 6),
            
            'temp_rolling_3h': get_rolling_mean(df['temperature'], 3),
            'temp_rolling_6h': get_rolling_mean(df['temperature'], 6),
            
            'hum_rolling_3h': get_rolling_mean(df['humidity'], 3),
            'hum_rolling_6h': get_rolling_mean(df['humidity'], 6),
            
            'soil_rolling_3h': get_rolling_mean(df['soil_moisture'], 3),
            'soil_rolling_6h': get_rolling_mean(df['soil_moisture'], 6),
            
            'rain_min_3h': get_rolling_min(df['rain'], 3),
            'rain_min_6h': get_rolling_min(df['rain'], 6),
            
            'hour_sin': np.sin(2 * np.pi * hour / 24.0),
            'hour_cos': np.cos(2 * np.pi * hour / 24.0),
            'day_of_year': day_of_year
        }

        # Build single row DataFrame matching feature_names order
        input_df = pd.DataFrame([feature_dict])[self.feature_names]

        # Execute 9 XGBoost Predictions
        preds = {}
        for target, model in self.models.items():
            val = model.predict(input_df)[0]
            preds[target] = float(np.round(val, 2))

        # Format output payload
        response_payload = {
            "temperature": {
                "6h": preds.get("temp_lead_6h", round(latest_row['temperature'], 1)),
                "10h": preds.get("temp_lead_10h", round(latest_row['temperature'], 1)),
                "24h": preds.get("temp_lead_24h", round(latest_row['temperature'], 1))
            },
            "humidity": {
                "6h": preds.get("hum_lead_6h", round(latest_row['humidity'], 1)),
                "10h": preds.get("hum_lead_10h", round(latest_row['humidity'], 1)),
                "24h": preds.get("hum_lead_24h", round(latest_row['humidity'], 1))
            },
            "soilMoisture": {
                "6h": preds.get("soil_lead_6h", round(latest_row['soil_moisture'], 1)),
                "10h": preds.get("soil_lead_10h", round(latest_row['soil_moisture'], 1)),
                "24h": preds.get("soil_lead_24h", round(latest_row['soil_moisture'], 1))
            },
            "modelVersion": "xgboost-v1-9models"
        }

        return response_payload
