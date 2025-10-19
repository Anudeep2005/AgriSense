#include <WiFi.h>
#include <HTTPClient.h>
#include "DHT.h"
#include <ArduinoJson.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>


#define WIFI_SSID "real"              
#define WIFI_PASSWORD "anudeep1"      
#define FIREBASE_HOST "MY_FIREBASE_URL"  

#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);


#define RAIN_PIN 34


#define LDR_PIN 32


#define SOIL_PIN 35


LiquidCrystal_I2C lcd(0x27, 16, 2); 


String cityName = "-";
String description = "-";
float feelsLike = 0;
float windSpeed = 0;
int windDeg = 0;
int pressure = 0;
String sunriseTime = "-";
String sunsetTime = "-";


unsigned long lastFetchTime = 0;
const unsigned long fetchInterval = 5UL * 60UL * 60UL * 1000UL; 

void setup() {
  Serial.begin(9600);

  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");

  dht.begin();
  Serial.println("ESP32 HTTP Firebase + Weather LCD Started");

  pinMode(LDR_PIN, INPUT);

  
  lcd.init();
  lcd.backlight();

  
  fetchWeatherData();
}

void loop() {
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  int rainVal = analogRead(RAIN_PIN);
  int ldrVal = digitalRead(LDR_PIN);
  int soilVal = analogRead(SOIL_PIN);

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    delay(2000);
    return;
  }

  
  String ldrStatus = (ldrVal == HIGH) ? "Dark" : "Bright";

  float soilPercent = map(soilVal, 4095, 0, 0, 100); 
  soilPercent = constrain(soilPercent, 0, 100);

  
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String jsonData = "{";
    jsonData += "\"temperature\":" + String(temperature, 2) + ",";
    jsonData += "\"humidity\":" + String(humidity, 2) + ",";
    jsonData += "\"rain\":" + String(rainVal) + ",";
    jsonData += "\"ldr\":\"" + ldrStatus + "\",";
    jsonData += "\"soilMoisture\":" + String(soilPercent, 2);
    jsonData += "}";

    String firebaseURL = String(FIREBASE_HOST) + "/farmData.json";
    http.begin(firebaseURL);
    http.addHeader("Content-Type", "application/json");
    int httpResponseCode = http.PUT(jsonData);

    if (httpResponseCode > 0) {
      Serial.printf("HTTP Response code: %d\n", httpResponseCode);
      Serial.println("Data uploaded: " + jsonData);
    } else {
      Serial.printf("Error in HTTP request: %s\n", http.errorToString(httpResponseCode).c_str());
    }
    http.end();
  } else {
    Serial.println("WiFi Disconnected!");
  }

  Serial.printf("Temp: %.2f °C | Humidity: %.2f %% | Rain: %d | LDR: %s | Soil: %.2f%%\n", 
                temperature, humidity, rainVal, ldrStatus.c_str(), soilPercent);
  Serial.println("-----------------------------");

  
  if (millis() - lastFetchTime > fetchInterval || lastFetchTime == 0) {
    fetchWeatherData();
    lastFetchTime = millis();
  }

  
  displayWeatherLCD();
  displayFarmDataLCD(temperature, humidity, rainVal, ldrStatus, soilPercent);
}


void fetchWeatherData() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = String(FIREBASE_HOST) + "/openweatherdata/latest/weather_data.json";
    http.begin(url);

    int httpResponseCode = http.GET();
    if (httpResponseCode == 200) {
      String payload = http.getString();
      Serial.println("Weather Data Fetched: " + payload);

      
      DynamicJsonDocument doc(2048);
      deserializeJson(doc, payload);

      cityName = doc["city_name"] | "-";
      description = doc["description"] | "-";
      feelsLike = doc["feels_like"] | 0;
      windSpeed = doc["wind_speed"] | 0;
      windDeg = doc["wind_direction"] | 0;
      pressure = doc["pressure"] | 0;
      sunriseTime = doc["sunrise"] | "-";
      sunsetTime = doc["sunset"] | "-";
    } else {
      Serial.printf("Error fetching weather data: %d\n", httpResponseCode);
    }
    http.end();
  }
}


void displayWeatherLCD() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("<" + cityName+">");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Desc:");
  lcd.setCursor(0, 1);
  lcd.print(description);
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Feels Like:");
  lcd.setCursor(0, 1);
  lcd.print(feelsLike, 1);
  lcd.print(" C");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Wind:");
  lcd.setCursor(0, 1);
  lcd.print(windSpeed, 1);
  lcd.print(" m/s");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Direction:");
  lcd.setCursor(0, 1);
  lcd.print(windDeg);
  lcd.print(" deg");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Pressure:");
  lcd.setCursor(0, 1);
  lcd.print(pressure);
  lcd.print(" hPa");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sunrise:");
  lcd.setCursor(0, 1);
  lcd.print(sunriseTime);
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sunset:");
  lcd.setCursor(0, 1);
  lcd.print(sunsetTime);
  delay(3000);
}


void displayFarmDataLCD(float temp, float hum, int rain, String ldr, float soil) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temp, 1);
  lcd.print(" C");

  lcd.setCursor(0, 1);
  lcd.print("Hum: ");
  lcd.print(hum, 1);
  lcd.print("%");
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Rain: ");
  lcd.print(rain);

  lcd.setCursor(0, 1);
  lcd.print("LDR: ");
  lcd.print(ldr);
  delay(3000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Soil: ");
  lcd.print(soil, 1);
  lcd.print("%");
  delay(3000);
}
