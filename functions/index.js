const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// Replace with your OpenWeatherMap API key
const OPENWEATHER_API_KEY = "80648a2d8737baf354b3d7c581b32b92";

// Replace with your location (city or coordinates)
const CITY_NAME = "Rajahmundry";

// Cloud Function to run every 15 minutes
exports.syncSensorWeatherData = functions.pubsub
    .schedule('every 15 minutes')
    .onRun(async (context) => {
        try {
            // 1️⃣ Fetch weather data from OpenWeatherMap
            const weatherUrl = `http://api.openweathermap.org/data/2.5/weather?q=${CITY_NAME}&appid=${OPENWEATHER_API_KEY}&units=metric`;
            const weatherResponse = await axios.get(weatherUrl);
            const weatherData = weatherResponse.data;

            // 2️⃣ Filter only the parameters you care about
            const filteredWeather = {
                temp: weatherData.main.temp,
                feels_like: weatherData.main.feels_like,
                sea_level: weatherData.main.sea_level,
                pressure: weatherData.main.pressure,
                grnd_level: weatherData.main.grnd_level,
                wind_speed: weatherData.wind.speed,
                wind_deg: weatherData.wind.deg,
                sunrise: weatherData.sys.sunrise,
                sunset: weatherData.sys.sunset,
                main: weatherData.weather[0].main,
                description: weatherData.weather[0].description
            };

            // 3️⃣ Fetch your ESP32 sensor data from Firebase (if already uploaded)
            const sensorSnapshot = await admin.database().ref("/farmData").once("value");
            const sensorData = sensorSnapshot.val() || {};

            // 4️⃣ Combine sensor data and weather data
            const combinedData = {
                sensor: sensorData,
                weather: filteredWeather,
                timestamp: new Date().toISOString()
            };

            // 5️⃣ Push combined data back to Firebase Realtime Database
            await admin.database().ref("/combinedData").set(combinedData);

            console.log("Combined data updated successfully!", combinedData);
        } catch (error) {
            console.error("Error syncing data:", error);
        }

        return null;
    });
