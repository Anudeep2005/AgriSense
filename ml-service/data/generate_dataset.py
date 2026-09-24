import numpy as np
import pandas as pd
import os

"""
AgriSense Telemetry Dataset Generator
--------------------------------------
Simulates realistic farm telemetry matching actual hardware & API semantics:
- temperature (°C): diurnal solar cycle + seasonal trend
- humidity (%): inverse temperature correlation + rain spikes
- soil_moisture (%): exponential drainage decay + rapid recharge on rainfall
- rain (raw analog): 4095 (dry) to 500 (heavy rain) [ESP32 ADC semantics]
- is_raining (derived binary): 1 if rain < 2000 else 0
- ldr_value (raw analog): 0 (dark) to 4095 (bright sunlight) [ESP32 LDR semantics]
- wind_speed (m/s) & pressure (hPa) & cloudiness (%)

Target Variables (9 Independent Single-Output Targets):
- temp_lead_6h, temp_lead_10h, temp_lead_24h
- hum_lead_6h, hum_lead_10h, hum_lead_24h
- soil_lead_6h, soil_lead_10h, soil_lead_24h
"""

def generate_agrisense_telemetry(num_days=365, seed=42):
    np.random.seed(seed)
    
    hours = num_days * 24
    timestamps = pd.date_range(start="2025-01-01", periods=hours, freq="h")
    
    # Time signals
    hour_of_day = timestamps.hour.values
    day_of_year = timestamps.dayofyear.values
    
    # Solar heating baseline: peak around 14:00 (2 PM), min around 05:00 (5 AM)
    solar_cycle = np.sin((hour_of_day - 8) * (2 * np.pi / 24))
    
    # Seasonal temperature variation (warmer mid-year)
    season_cycle = 10 * np.sin((day_of_year - 80) * (2 * np.pi / 365))
    
    # Base temperature (°C)
    base_temp = 25.0 + season_cycle + 6.0 * solar_cycle + np.random.normal(0, 1.2, hours)
    temperature = np.clip(base_temp, 10.0, 45.0)
    
    # Rain simulation (probabilistic rain events lasting a few hours)
    rain_event_prob = 0.05
    is_raining_raw = (np.random.rand(hours) < rain_event_prob).astype(int)
    # Smooth rain events to span 2-5 consecutive hours
    rain_series = pd.Series(is_raining_raw).rolling(window=4, min_periods=1).max().values
    
    # ESP32 Rain sensor ADC: 4095 = dry, 500 = heavy rain
    rain_adc = np.where(rain_series == 1, np.random.uniform(500, 1800, hours), np.random.uniform(3800, 4095, hours))
    is_raining = (rain_adc < 2000).astype(int)
    
    # Relative Humidity (%): Inverse to temperature, spikes when raining
    base_humidity = 70.0 - 1.5 * (temperature - 25.0) + 25.0 * is_raining + np.random.normal(0, 3.0, hours)
    humidity = np.clip(base_humidity, 20.0, 98.0)
    
    # LDR Photoresistor ADC: 0 (dark night) to 4095 (bright noon sun), cloud reduction
    cloudiness = np.clip(np.where(is_raining == 1, np.random.uniform(70, 100, hours), np.random.uniform(10, 60, hours)), 0, 100)
    raw_light = np.maximum(0, solar_cycle * 3800) * (1.0 - 0.5 * (cloudiness / 100.0)) + np.random.normal(50, 30, hours)
    ldr_value = np.clip(raw_light, 0, 4095)
    
    # Soil Moisture (%): Decay over dry periods, recharge during rain
    soil_moisture = np.zeros(hours)
    current_sm = 45.0
    for t in range(hours):
        if is_raining[t] == 1:
            current_sm = min(85.0, current_sm + np.random.uniform(4.0, 10.0))
        else:
            # Evapotranspiration loss higher when warm
            temp_factor = 1.0 + max(0, (temperature[t] - 25.0) / 20.0)
            decay = np.random.uniform(0.1, 0.35) * temp_factor
            current_sm = max(15.0, current_sm - decay)
        soil_moisture[t] = current_sm
        
    # Weather metrics
    wind_speed = np.clip(np.random.gamma(shape=2.0, scale=1.5, size=hours), 0.5, 20.0)
    pressure = np.clip(1013.25 - 0.1 * (temperature - 25.0) - 0.05 * cloudiness + np.random.normal(0, 2.0, hours), 980.0, 1035.0)
    
    # Create DataFrame
    df = pd.DataFrame({
        'timestamp': timestamps,
        'temperature': np.round(temperature, 2),
        'humidity': np.round(humidity, 2),
        'soil_moisture': np.round(soil_moisture, 2),
        'rain': np.round(rain_adc, 0),
        'is_raining': is_raining,
        'ldr_value': np.round(ldr_value, 0),
        'wind_speed': np.round(wind_speed, 2),
        'pressure': np.round(pressure, 2),
        'cloudiness': np.round(cloudiness, 1)
    })
    
    # Feature Engineering (Lags & Rolling)
    df['temp_lag_1h'] = df['temperature'].shift(1)
    df['temp_lag_3h'] = df['temperature'].shift(3)
    df['temp_lag_6h'] = df['temperature'].shift(6)
    
    df['hum_lag_1h'] = df['humidity'].shift(1)
    df['hum_lag_3h'] = df['humidity'].shift(3)
    df['hum_lag_6h'] = df['humidity'].shift(6)
    
    df['soil_lag_1h'] = df['soil_moisture'].shift(1)
    df['soil_lag_3h'] = df['soil_moisture'].shift(3)
    df['soil_lag_6h'] = df['soil_moisture'].shift(6)
    
    df['temp_rolling_3h'] = df['temperature'].rolling(window=3).mean()
    df['temp_rolling_6h'] = df['temperature'].rolling(window=6).mean()
    
    df['hum_rolling_3h'] = df['humidity'].rolling(window=3).mean()
    df['hum_rolling_6h'] = df['humidity'].rolling(window=6).mean()
    
    df['soil_rolling_3h'] = df['soil_moisture'].rolling(window=3).mean()
    df['soil_rolling_6h'] = df['soil_moisture'].rolling(window=6).mean()
    
    df['rain_min_3h'] = df['rain'].rolling(window=3).min()
    df['rain_min_6h'] = df['rain'].rolling(window=6).min()
    
    df['hour_sin'] = np.sin(2 * np.pi * hour_of_day / 24.0)
    df['hour_cos'] = np.cos(2 * np.pi * hour_of_day / 24.0)
    df['day_of_year'] = day_of_year
    
    # Target Variables (Independent Future Horizons)
    df['temp_lead_6h'] = df['temperature'].shift(-6)
    df['temp_lead_10h'] = df['temperature'].shift(-10)
    df['temp_lead_24h'] = df['temperature'].shift(-24)
    
    df['hum_lead_6h'] = df['humidity'].shift(-6)
    df['hum_lead_10h'] = df['humidity'].shift(-10)
    df['hum_lead_24h'] = df['humidity'].shift(-24)
    
    df['soil_lead_6h'] = df['soil_moisture'].shift(-6)
    df['soil_lead_10h'] = df['soil_moisture'].shift(-10)
    df['soil_lead_24h'] = df['soil_moisture'].shift(-24)
    
    # Drop NaNs resulting from lag/lead window edges
    clean_df = df.dropna().reset_index(drop=True)
    return clean_df

if __name__ == '__main__':
    output_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(output_dir, 'agrisense_training_data.csv')
    
    print('Generating synthetic AgriSense farm telemetry dataset...')
    df = generate_agrisense_telemetry(num_days=365, seed=42)
    df.to_csv(output_file, index=False)
    
    print(f'Successfully generated dataset: {output_file}')
    print(f'Dataset Shape: {df.shape[0]} rows x {df.shape[1]} columns')
