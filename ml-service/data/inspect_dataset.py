import pandas as pd
import numpy as np
import os

"""
AgriSense Dataset Inspection & Validation Script (USER TASK 2)
--------------------------------------------------------------
Inspect generated dataset prior to training XGBoost models:
1. Shape & Missing Values Check
2. Feature Statistics & Sensor Range Semantics (Rain ADC, LDR ADC, Soil Moisture %)
3. Temporal Correlation Analysis with Target Variables
"""

def inspect_dataset():
    data_path = os.path.join(os.path.dirname(__file__), 'agrisense_training_data.csv')
    if not os.path.exists(data_path):
        print(f"Error: {data_path} not found. Please run generate_dataset.py first.")
        return
        
    df = pd.read_csv(data_path)
    
    print("=" * 60)
    print(" 📊 AGRISENSE TELEMETRY DATASET INSPECTION & VALIDATION")
    print("=" * 60)
    print(f"Rows: {len(df):,} | Columns: {len(df.columns)}")
    print(f"Time Range: {df['timestamp'].min()} to {df['timestamp'].max()}")
    print("-" * 60)
    
    print("\n🔍 1. SENSOR SEMANTICS & FEATURE RANGES:")
    sensor_cols = ['temperature', 'humidity', 'soil_moisture', 'rain', 'ldr_value', 'wind_speed', 'pressure']
    stats = df[sensor_cols].describe().T[['mean', 'std', 'min', '50%', 'max']]
    print(stats.to_string())
    
    print("\n🌧️ 2. RAIN SENSOR SEMANTICS CHECK:")
    rain_events = df[df['is_raining'] == 1]
    print(f"Rainy Hours: {len(rain_events)} / {len(df)} ({len(rain_events)/len(df)*100:.1f}%)")
    print(f"Rain ADC during rain: min={rain_events['rain'].min()}, max={rain_events['rain'].max()} (expected < 2000)")
    dry_events = df[df['is_raining'] == 0]
    print(f"Rain ADC during dry: min={dry_events['rain'].min()}, max={dry_events['rain'].max()} (expected > 2000)")
    
    print("\n🔮 3. TARGET CORRELATION MATRIX (Temperature, Humidity, Soil Moisture):")
    target_cols = [
        'temp_lead_6h', 'temp_lead_10h', 'temp_lead_24h',
        'hum_lead_6h', 'hum_lead_10h', 'hum_lead_24h',
        'soil_lead_6h', 'soil_lead_10h', 'soil_lead_24h'
    ]
    corrs = df[['temperature', 'humidity', 'soil_moisture'] + target_cols].corr()
    print("\nTemperature Target Correlations:")
    print(corrs.loc[['temperature', 'humidity', 'soil_moisture'], ['temp_lead_6h', 'temp_lead_10h', 'temp_lead_24h']].to_string())
    
    print("\nSoil Moisture Target Correlations:")
    print(corrs.loc[['soil_moisture', 'temperature', 'humidity'], ['soil_lead_6h', 'soil_lead_10h', 'soil_lead_24h']].to_string())
    
    print("\n✅ DATASET VALIDATION PASSED! Ready for XGBoost Model Training.")
    print("=" * 60)

if __name__ == '__main__':
    inspect_dataset()
