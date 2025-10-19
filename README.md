# 🌾 AgriSense: Real-Time IoT + AI Weather Prediction App

**AgriSense** is a Flutter-based mobile application integrated with IoT sensors and AI that provides **real-time insights and predictions for farmers**, helping them prevent crop losses due to weather uncertainties.  

The project combines **ESP32 sensor data**, **Firebase Realtime Database**, and **OpenAI Gemini API** to deliver actionable recommendations.

---

## 🚀 Features

- **Real-Time Farm Monitoring**  
  Fetches live sensor data from ESP32, including:
  - Temperature & Humidity (DHT11)  
  - Soil Moisture  
  - Rainfall  
  - Light Intensity (LDR)

- **Weather API Integration**  
  Automatically fetches weather data for the farmer’s location using **OpenWeatherMaps API**.

- **AI-Powered Analysis**  
  - Combines farm sensor data and weather API data  
  - Uses **Gemini 2.5 AI model** to act as a professional agronomist  
  - Provides **predictions, insights, and recommendations** to improve crop yield

- **Notifications & Alerts**  
  Rates weather severity as **High / Medium / Low** and sends notifications to farmers for proactive actions.

---

## 📱 Tech Stack
----------------------------------------------------------
| Component                | Technology / Tool           |
|--------------------------|-----------------------------|
| Mobile App               | Flutter                     |
| IoT Microcontroller      | ESP32 WROOM-32              |
| Sensors                  | DHT11, LDR, Rain Sensor,    |
|                          | Soil Moisture Sensor        |
| Database                 | Firebase Realtime Database  |
| AI Model                 | Gemini 2.5 Flash            |
| APIs                     | OpenWeatherMaps             |
| Backend Logic            | Dart + Flutter              |
----------------------------------------------------------


