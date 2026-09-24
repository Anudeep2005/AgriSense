# 🎯 WHAT I MUST KNOW FOR THE INTERVIEW — AGRISENSE ML & BACKEND

This document contains everything you need to understand, explain, and defend the AgriSense ML & Backend architecture in a technical interview.

---

## 1. MACHINE LEARNING & XGBOOST QUESTIONS

### Q1: Why did you choose XGBoost over Deep Learning (LSTM, GRU, Transformers)?
**Answer**:
- **Tabular & Heterogeneous Telemetry Data**: XGBoost is state-of-the-art for tabular data combining continuous sensor readings (temperature, humidity, soil moisture) and categorical/raw flags (is_raining, ldr_value).
- **Interpretability & Low Latency**: Tree-based ensembles perform inference in milliseconds without requiring heavy GPU infrastructure.
- **Data Efficiency**: LSTMs require vast continuous sequence histories and are prone to overfitting on limited farm sensor datasets. 9 independent XGBoost regression models gave targeted, high-accuracy predictions for 6h, 10h, and 24h horizons.

### Q2: How does Gradient Boosting work?
**Answer**:
Gradient boosting constructs an ensemble of weak decision trees sequentially. Each new tree fits the residual errors (gradients) of the previous tree ensemble, minimizing a specified loss function (e.g., Mean Squared Error for regression).

### Q3: Why 9 independent single-output regression models instead of a multi-output model?
**Answer**:
- **Target Independence**: Temperature, humidity, and soil moisture have distinct decay/recharge rates across 6h, 10h, and 24h horizons.
- **Model Tuning & Isolation**: Each model's hyperparameters (max depth, learning rate, subsample ratio) can be independently tuned for its specific target horizon. If one horizon requires retraining, other models remain unaffected.

### Q4: How did you evaluate your XGBoost models?
**Answer**:
We compared XGBoost against a **Persistence Baseline** (where $y_{pred}(t+h) = y(t)$, assuming future values equal current values). We evaluated using:
- **MAE (Mean Absolute Error)**: Average absolute prediction error in metric units (°C, %, etc.).
- **RMSE (Root Mean Squared Error)**: Penalizes larger prediction errors.
- **$R^2$ Score**: Measure of variance explained by the model compared to the mean.

### Q5: How did you prevent Data Leakage during training?
**Answer**:
- Used a **Chronological Train/Test Split** (first 80% chronologically for training, last 20% for testing).
- **NO random shuffling**: Randomly shuffling time-series data leaks future temporal correlations into the training set.

---

## 2. SYSTEM ARCHITECTURE & DATA FLOW QUESTIONS

### Q6: What is the end-to-end data flow of AgriSense?
**Answer**:
```text
ESP32 Hardware (Sensors)
  └─► Firebase Realtime DB (Raw Telemetry Buffer)
        └─► Node.js / Express Backend (JWT Auth & Alert Orchestration)
              └─► FastAPI ML Service (Computes Lags/Rolling Features)
                    └─► 9 XGBoost Models (Predicts 6h, 10h, 24h Horizons)
                          └─► Threshold Alert Engine (Generates MongoDB Alerts)
                                └─► Flutter Mobile App (Displays Forecasts & Alerts)
```

### Q7: Why do you need BOTH Firebase Realtime Database AND MongoDB Atlas?
**Answer**:
- **Firebase RTDB**: Optimized for real-time IoT hardware telemetry stream (ESP32 sensor writes and reactive Flutter dashboard listeners).
- **MongoDB Atlas**: Used as the application database for structured user accounts, JWT security, persistent alert logs, and business domain models.

### Q8: How are alerts generated?
**Answer**:
The ML models predict future values (e.g., 6h soil moisture = 22%), but **do not** directly classify alerts. Instead, predictions pass into a deterministic **Threshold Alert Engine** (`alertEngine.js`) configured with clear agricultural rules:
- Soil moisture $\le 25\%$ $\rightarrow$ CRITICAL Alert (Immediate Irrigation)
- Soil moisture $\le 30\%$ $\rightarrow$ WARNING Alert
- Temperature $\ge 38^\circ\text{C}$ $\rightarrow$ CRITICAL Alert

---

## 3. SENSOR & TELEMETRY SEMANTICS

### Q9: How are the raw ESP32 sensors represented in the data?
**Answer**:
- **Rain Sensor**: Analog ADC reading ($0 - 4095$). Lower values indicate wet conditions ($<2000$). Derived feature `is_raining` ($1$ if rain ADC $<2000$ else $0$).
- **Light Sensor**: Raw uncalibrated LDR photoresistor ADC value (`ldr_value`, $0 - 4095$), avoiding uncalibrated lux labels.
- **Soil Moisture**: Moisture percentage ($0 - 100\%$) with exponential drainage decay over dry periods and sharp recharge on rain events.

---

## 4. KEY SUMMARY STATS FOR THE INTERVIEW
- **Dataset**: 8,730 hourly telemetry records (1 year of continuous farm metrics).
- **Features**: 29 features (current telemetry, 1h/3h/6h lags, 3h/6h rolling averages, rain minimums, cyclical time encoding).
- **Models**: 9 single-output XGBoost Regressors (`temp_6h`, `temp_10h`, `temp_24h`, `hum_6h`, `hum_10h`, `hum_24h`, `soil_6h`, `soil_10h`, `soil_24h`).
- **Services**: Express (Node.js, Port 5000), FastAPI (Python, Port 8000), Flutter Client.
