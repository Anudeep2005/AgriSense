import pandas as pd
import numpy as np
import xgboost as xgb
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import json
import os

"""
AgriSense 9 Independent XGBoost Regression Models Training Pipeline
---------------------------------------------------------------------
1. Loads agrisense_training_data.csv
2. Applies Chronological Train/Test Split (80% Train, 20% Test - NO SHUFFLE)
3. Establishes Persistence Baseline:
   - temp_lead ≈ current_temp
   - hum_lead ≈ current_hum
   - soil_lead ≈ current_soil
4. Trains 9 Independent Single-Output XGBoost Regression Models
5. Evaluates MAE, RMSE, R² (XGBoost vs Persistence)
6. Exports models to JSON files in ml-service/models/
"""

FEATURE_COLS = [
    'temperature', 'humidity', 'soil_moisture', 'rain', 'is_raining', 'ldr_value',
    'wind_speed', 'pressure', 'cloudiness',
    'temp_lag_1h', 'temp_lag_3h', 'temp_lag_6h',
    'hum_lag_1h', 'hum_lag_3h', 'hum_lag_6h',
    'soil_lag_1h', 'soil_lag_3h', 'soil_lag_6h',
    'temp_rolling_3h', 'temp_rolling_6h',
    'hum_rolling_3h', 'hum_rolling_6h',
    'soil_rolling_3h', 'soil_rolling_6h',
    'rain_min_3h', 'rain_min_6h',
    'hour_sin', 'hour_cos', 'day_of_year'
]

TARGET_CONFIG = [
    # (Target Column, Current Base Column, Metric Name, Target Key)
    ('temp_lead_6h', 'temperature', 'Temperature', '6h'),
    ('temp_lead_10h', 'temperature', 'Temperature', '10h'),
    ('temp_lead_24h', 'temperature', 'Temperature', '24h'),
    
    ('hum_lead_6h', 'humidity', 'Humidity', '6h'),
    ('hum_lead_10h', 'humidity', 'Humidity', '10h'),
    ('hum_lead_24h', 'humidity', 'Humidity', '24h'),
    
    ('soil_lead_6h', 'soil_moisture', 'Soil Moisture', '6h'),
    ('soil_lead_10h', 'soil_moisture', 'Soil Moisture', '10h'),
    ('soil_lead_24h', 'soil_moisture', 'Soil Moisture', '24h'),
]

def train_all_models():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_path = os.path.join(base_dir, 'data', 'agrisense_training_data.csv')
    models_dir = os.path.join(base_dir, 'models')
    os.makedirs(models_dir, exist_ok=True)
    
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Dataset missing at {data_path}. Please run generate_dataset.py first.")
        
    df = pd.read_csv(data_path)
    
    # Chronological Train/Test Split (80% Train, 20% Test)
    split_idx = int(len(df) * 0.8)
    train_df = df.iloc[:split_idx]
    test_df = df.iloc[split_idx:]
    
    X_train = train_df[FEATURE_COLS]
    X_test = test_df[FEATURE_COLS]
    
    print("=" * 80)
    print(" 🚀 AGRISENSE 9 INDEPENDENT XGBOOST REGRESSION MODELS TRAINING")
    print("=" * 80)
    print(f"Train samples: {len(X_train):,} | Test samples: {len(X_test):,}")
    print(f"Number of input features: {len(FEATURE_COLS)}")
    print("-" * 80)
    
    results_summary = []
    
    for target_col, base_col, metric_label, horizon in TARGET_CONFIG:
        y_train = train_df[target_col]
        y_test = test_df[target_col]
        
        # 1. Persistence Baseline Prediction (current value as forecast)
        y_pred_baseline = test_df[base_col].values
        
        mae_base = mean_absolute_error(y_test, y_pred_baseline)
        rmse_base = np.sqrt(mean_squared_error(y_test, y_pred_baseline))
        r2_base = r2_score(y_test, y_pred_baseline)
        
        # 2. Independent Single-Output XGBoost Regression Model
        model = xgb.XGBRegressor(
            n_estimators=100,
            learning_rate=0.05,
            max_depth=5,
            subsample=0.8,
            colsample_bytree=0.8,
            random_state=42,
            n_jobs=-1
        )
        
        model.fit(
            X_train, y_train,
            eval_set=[(X_test, y_test)],
            verbose=False
        )
        
        # Predict & Evaluate XGBoost
        y_pred_xgb = model.predict(X_test)
        
        mae_xgb = mean_absolute_error(y_test, y_pred_xgb)
        rmse_xgb = np.sqrt(mean_squared_error(y_test, y_pred_xgb))
        r2_xgb = r2_score(y_test, y_pred_xgb)
        
        # Save Model Artifact
        model_filename = f"{target_col}.json"
        model_path = os.path.join(models_dir, model_filename)
        model.save_model(model_path)
        
        results_summary.append({
            'Target': target_col,
            'Metric': metric_label,
            'Horizon': horizon,
            'Baseline MAE': round(mae_base, 3),
            'XGBoost MAE': round(mae_xgb, 3),
            'Baseline RMSE': round(rmse_base, 3),
            'XGBoost RMSE': round(rmse_xgb, 3),
            'Baseline R²': round(r2_base, 3),
            'XGBoost R²': round(r2_xgb, 3),
            'MAE Imprv %': round(((mae_base - mae_xgb) / mae_base) * 100, 1)
        })
        
    # Save Feature Columns List for FastAPI Predictor
    with open(os.path.join(models_dir, 'feature_names.json'), 'w') as f:
        json.dump(FEATURE_COLS, f, indent=2)
        
    summary_df = pd.DataFrame(results_summary)
    print("\n📊 MODEL EVALUATION VS PERSISTENCE BASELINE:")
    print(summary_df.to_string(index=False))
    print("\n✅ All 9 XGBoost models successfully trained and exported to ml-service/models/")
    print("=" * 80)

if __name__ == '__main__':
    train_all_models()
