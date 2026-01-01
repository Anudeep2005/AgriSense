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

## Tech Stack
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

---
## Circuit Diagram
The circuit diagram below illustrates the complete ESP32 sensor wiring used in this project.

<img width="3000" height="3571" alt="circuit_image (1)" src="https://github.com/user-attachments/assets/401bf044-517b-4626-80c0-6eeb334bc39e" />

## How to Run

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- ESP32 board (ESP32 WROOM-32)
- Arduino IDE or PlatformIO
- Firebase account
- OpenWeatherMap API key
- Gemini API key

---

### 1. Hardware Setup (ESP32)
1. Assemble the circuit as shown in the provided **circuit diagram**.
2. Connect the following sensors to the ESP32:
   - DHT11 (Temperature & Humidity)
   - Soil Moisture Sensor
   - Rain Sensor
   - LDR (Light Intensity)
3. Connect the ESP32 to your system via USB.

---

### 2. ESP32 Firmware Setup
1. Navigate to the `esp32_core/` directory.
2. Open the firmware code in Arduino IDE or PlatformIO.
3. Install required libraries:
   - DHT Sensor Library
   - Firebase ESP Client
4. Replace Firebase credentials and Wi-Fi details with your own (placeholders are provided).
5. Upload the firmware to the ESP32.
6. Verify that sensor data is being sent to Firebase Realtime Database.

---

### 3. Firebase Setup
1. Create a Firebase project.
2. Enable **Firebase Realtime Database**.
3. Replace Firebase configuration placeholders in the Flutter project.
4. Ensure database rules are properly configured for testing.

---

### 4. Flutter App Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
2.Navigate to the project directory
3.Install Dependencies
4.Replace API placeholders:
  1.OpenWeatherMap API key
  2.Gemini AI API key
5.Run the application



