#include <WiFiManager.h>
#include <WiFi.h>
#include <DHT.h>
#include <Wire.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <HTTPClient.h>

// Wi-Fi Manager Settings
#define LED_PIN 2
#define BUTTON_PIN 0
#define TIMEOUT_SECONDS 120

WiFiManager wm;

// Firebase Credentials
#define API_KEY "AIzaSyA6awKc4A6toK1EYNBANrJ-wTMMcrxJ7gE"
#define DATABASE_URL "https://flood-esp-default-rtdb.firebaseio.com/"
#define USER_EMAIL "esp@gmail.com"
#define USER_PASSWORD "123456"

// Ultrasonic Sensor
#define echoPin 18
#define trigPin 5

// DHT Sensor
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Soil Moisture Sensor
#define SOIL_SENSOR 34

// LED Control
#define ledpin 26

// Float Switch
#define FLOAT_SWITCH_PIN 13

// Rain Sensor
#define RAIN_ANALOG_PIN 21
#define RAIN_DIGITAL_PIN 23

// Firebase & NTP
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
String uid;

const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 19800;
const int daylightOffset_sec = 0;

bool signupOK = false;
bool timeUploaded = false;
bool ledstatus = false;

// Telegram Bot Token 
const char* BOT_TOKEN = "7412597635:AAHLVyHXiECDQdP6gHUJpkA1DNWsvuVSdrQ";
const char* CHAT_ID = "5550766633";

// Initialize components
HTTPClient http;

// Variables for sensor readings
float temperature = 0;
float humidity = 0;
int soilMoisture = 0;
float distance = 0;
bool rainDetected = false;
bool floatSwitchStatus = false;
bool ledState = false;

// Variables for Telegram notifications
bool lastRainState = false;
bool lastFloatSwitchState = false;
float lastDistance = 0;
int lastSoilMoisture = 0;
float lastTemperature = 0;
float lastHumidity = 0;

// Function to connect to WiFi using WiFiManager
void connectToWiFi() {
  wm.setConfigPortalTimeout(TIMEOUT_SECONDS);
  bool res = wm.autoConnect("ESPTESTING");
  if (!res) {
    Serial.println("Failed to connect!");
  } else {
    Serial.println("Connected to Wi-Fi, LED ON");
    digitalWrite(LED_PIN, HIGH);
  }
}

// Function to get the current date & time
String getDateTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("⚠ Failed to obtain time!");
    return "N/A";
  }

  char timeString[30];
  snprintf(timeString, sizeof(timeString), "%02d-%02d-%04d %02d:%02d:%02d",
           timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900,
           timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);

  return String(timeString);
}

// Upload startup time to Firebase once
void uploadDateTimeToFirebase() {
  if (!timeUploaded) {
    String currentDateTime = getDateTime();
    Serial.print("Uploading startup time: ");
    Serial.println(currentDateTime);

    if (Firebase.RTDB.setString(&fbdo, "System/StartupTime", currentDateTime)) {
      Serial.println("✅ Startup time successfully uploaded!");
      timeUploaded = true;
    } else {
      Serial.println("❌ Failed to upload time: " + fbdo.errorReason());
    }
  }
}

void sendTelegramMessage(String message) {
  Serial.println("Sending Telegram message: " + message);
  
  // Create the URL for the Telegram API
  String url = "https://api.telegram.org/bot" + String(BOT_TOKEN) + "/sendMessage";
  
  // Prepare the POST data
  String postData = "chat_id=" + String(CHAT_ID) + 
                   "&text=" + message + 
                   "&parse_mode=HTML";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  
  // Send the POST request
  int httpResponseCode = http.POST(postData);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("✅ Telegram message sent successfully");
    Serial.println("Response code: " + String(httpResponseCode));
    Serial.println("Response: " + response);
  } else {
    Serial.println("❌ Error sending Telegram message");
    Serial.println("Error code: " + String(httpResponseCode));
  }
  
  http.end();
}

void checkAndSendAlerts() {
  String currentTime = getDateTime();
  
  // Water Level Alerts
  if (distance <= 5 && lastDistance > 5) {
    sendTelegramMessage(
      "⚠️ CRITICAL ALERT: Water Level\n"
      "🌊 Water level is extremely high!\n"
      "📏 Current level: " + String(distance, 1) + " cm\n"
      "⚡ Immediate action required!\n"
      "🕒 Time: " + currentTime
    );
  } else if (distance <= 10 && distance > 5 && lastDistance > 10) {
    sendTelegramMessage(
      "⚠️ WARNING: Water Level\n"
      "💧 Water level is rising\n"
      "📏 Current level: " + String(distance, 1) + " cm\n"
      "👀 Please monitor the situation\n"
      "🕒 Time: " + currentTime
    );
  }
  lastDistance = distance;

  // Float Switch Alerts
  if (floatSwitchStatus != lastFloatSwitchState) {
    if (floatSwitchStatus) {
      sendTelegramMessage(
        "⚠️ ALERT: Float Switch\n"
        "🔴 Water level is HIGH\n"
        "💢 Float switch has been triggered\n"
        "⚡ Please check water level immediately!\n"
        "🕒 Time: " + currentTime
      );
    } else {
      sendTelegramMessage(
        "✅ UPDATE: Float Switch\n"
        "🟢 Water level is LOW\n"
        "💧 Float switch has returned to normal\n"
        "🕒 Time: " + currentTime
      );
    }
  }
  lastFloatSwitchState = floatSwitchStatus;

  // Rain Detection Alerts
  if (rainDetected != lastRainState) {
    if (rainDetected) {
      sendTelegramMessage(
        "☔ Rain Alert\n"
        "🌧️ Rain has been detected\n"
        "📌 Current status: Raining\n"
        "⚠️ Please monitor water levels\n"
        "🕒 Time: " + currentTime
      );
    } else {
      sendTelegramMessage(
        "✅ Rain Update\n"
        "🌤️ Rain has stopped\n"
        "📌 Current status: Clear\n"
        "🕒 Time: " + currentTime
      );
    }
  }
  lastRainState = rainDetected;

  // Soil Moisture Alerts
  if (soilMoisture > 900 && lastSoilMoisture <= 900) {
    sendTelegramMessage(
      "⚠️ ALERT: Soil Moisture\n"
      "💦 Soil is extremely wet!\n"
      "📊 Current value: " + String(soilMoisture) + "\n"
      "⚡ Risk of flooding!\n"
      "🕒 Time: " + currentTime
    );
  } else if (soilMoisture < 300 && lastSoilMoisture >= 300) {
    sendTelegramMessage(
      "⚠️ ALERT: Soil Moisture\n"
      "🏜️ Soil is too dry!\n"
      "📊 Current value: " + String(soilMoisture) + "\n"
      "🌱 Plants may be at risk!\n"
      "🕒 Time: " + currentTime
    );
  }
  lastSoilMoisture = soilMoisture;

  // Temperature Alerts
  if (temperature > 40 && lastTemperature <= 40) {
    sendTelegramMessage(
      "🌡️ Temperature Alert\n"
      "🔥 High temperature detected!\n"
      "📊 Current temperature: " + String(temperature, 1) + "°C\n"
      "⚠️ Please check equipment\n"
      "🕒 Time: " + currentTime
    );
  } else if (temperature < 15 && lastTemperature >= 15) {
    sendTelegramMessage(
      "🌡️ Temperature Alert\n"
      "❄️ Low temperature detected!\n"
      "📊 Current temperature: " + String(temperature, 1) + "°C\n"
      "⚠️ Risk of equipment malfunction\n"
      "🕒 Time: " + currentTime
    );
  }
  lastTemperature = temperature;

  // Humidity Alerts
  if (humidity > 90 && lastHumidity <= 90) {
    sendTelegramMessage(
      "💧 Humidity Alert\n"
      "🌫️ High humidity detected!\n"
      "📊 Current humidity: " + String(humidity, 1) + "%\n"
      "⚠️ Risk of condensation\n"
      "🕒 Time: " + currentTime
    );
  } else if (humidity < 30 && lastHumidity >= 30) {
    sendTelegramMessage(
      "💧 Humidity Alert\n"
      "🏜️ Low humidity detected!\n"
      "📊 Current humidity: " + String(humidity, 1) + "%\n"
      "⚠️ Environment too dry\n"
      "🕒 Time: " + currentTime
    );
  }
  lastHumidity = humidity;
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Wi-Fi Setup
  connectToWiFi();

  // Firebase Setup
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.reconnectWiFi(true);
  Firebase.begin(&config, &auth);

  while ((auth.token.uid) == "") {
    Serial.print('.');
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
  }

  signupOK = true;

  // Sync Time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("⏳ Waiting for NTP time...");
  delay(2000);
  uploadDateTimeToFirebase();

  // Sensor Setup
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  dht.begin();
  pinMode(SOIL_SENSOR, INPUT);
  pinMode(ledpin, OUTPUT);
  pinMode(FLOAT_SWITCH_PIN, INPUT_PULLUP);
  pinMode(RAIN_DIGITAL_PIN, INPUT);

  // Test Telegram Connection
  sendTelegramMessage("🔄 ESP32 System Started\n📡 Connected to WiFi\n🕒 Time: " + getDateTime());
}

void loop() {
  static unsigned long lastCheckTime = 0;
  const unsigned long checkInterval = 5000;

  // Reconnect Wi-Fi if disconnected
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi lost! Reconnecting...");
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);

    if (millis() - lastCheckTime > checkInterval) {
      connectToWiFi();
      lastCheckTime = millis();
    }
  } else {
    digitalWrite(LED_PIN, HIGH);
  }

  // Restart Wi-Fi setup when button is pressed
  if (digitalRead(BUTTON_PIN) == LOW) {
    Serial.println("Button pressed! Restarting Wi-Fi setup...");
    wm.resetSettings();
    delay(1000);
    ESP.restart();
  }

  // Send data to Firebase every second
  if (Firebase.ready() && signupOK && (millis() - lastCheckTime > 500 || lastCheckTime == 0)) {
    lastCheckTime = millis();

    // Temperature & Humidity
    float newTemp = dht.readTemperature();
    float newHum = dht.readHumidity();
    if (!isnan(newTemp) && !isnan(newHum)) {
      temperature = newTemp;
      humidity = newHum;
      Firebase.RTDB.setFloat(&fbdo, "DTH/Temperature", temperature);
      Firebase.RTDB.setFloat(&fbdo, "DTH/Humidity", humidity);
    }

    // Ultrasonic Sensor
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    long duration = pulseIn(echoPin, HIGH);
    distance = duration * 0.034 / 2;
    Firebase.RTDB.setFloat(&fbdo, "UltraSonic/Distance", distance);

    // Soil Moisture
    soilMoisture = analogRead(SOIL_SENSOR);
    Firebase.RTDB.setInt(&fbdo, "Soil/Moisture", soilMoisture);

    // Water Level
    floatSwitchStatus = digitalRead(FLOAT_SWITCH_PIN) == HIGH;
    String waterstatus = (floatSwitchStatus) ? "HIGH" : "LOW";
    Firebase.RTDB.setString(&fbdo, "floatSwitch", waterstatus);

    // Turn on LED if distance is less than 10 cm
    if (distance < 10 || floatSwitchStatus) {
      digitalWrite(ledpin, HIGH);
      ledState = true;
      Serial.println("🚨 Water Level HIGH");
    } else {
      digitalWrite(ledpin, LOW);
      ledState = false;
    }

    // Rain Detection
    rainDetected = digitalRead(RAIN_DIGITAL_PIN) == LOW;
    String detectRain = (rainDetected) ? "YES" : "NO";
    Firebase.RTDB.setString(&fbdo, "Rain/Detect", detectRain);

    // Check and send alerts
    checkAndSendAlerts();
  }

  // Update Firebase
  if (Firebase.ready()) {
    Firebase.RTDB.setBool(&fbdo, "led", ledState);
  }

  delay(1000); // Delay between readings
}