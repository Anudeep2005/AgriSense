# AgriSense Architecture Documentation

## Overview
AgriSense is an IoT-enabled smart agriculture system combining real-time environmental monitoring, machine learning forecasts, and plant disease diagnosis.

## System Topology
```text
┌──────────────────┐
│      ESP32       │ (Sensors: Temp, Hum, Soil Moisture, Rain, LDR)
└────────┬─────────┘
         │ (HTTP/Firebase Realtime DB)
         ▼
┌──────────────────┐
│  Firebase RTDB   │ (IoT Live Telemetry & History)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Express Backend │ (Node.js + Express + MongoDB Atlas + JWT Auth)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ FastAPI ML Svc   │ (Python + scikit-learn + XGBoost)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 9 XGBoost Models │ (Predict 6h, 10h, 24h for Temp, Humidity, Soil Moisture)
└──────────────────┘
```

## Data Flow & Components
1. **ESP32 Firmware**: Reads physical sensors and writes JSON telemetry directly to Firebase RTDB.
2. **Firebase RTDB**: Serves as the real-time buffer for raw hardware telemetry and recent reading history window.
3. **Express Application Backend**: Handles user authentication (JWT/bcrypt), manages MongoDB application data, orchestrates ML prediction requests, and evaluates deterministic threshold alert rules.
4. **FastAPI ML Service**: Receives telemetry history window, computes lag/rolling features on-the-fly, executes predictions across 9 independent single-output XGBoost regression models, and returns formatted horizon predictions.
5. **Flutter Client**: Displays live telemetry, XGBoost forecasts, rule-driven alerts, crop knowledge base, and Gemini Vision plant disease detection.
