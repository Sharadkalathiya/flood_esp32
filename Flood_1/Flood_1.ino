#include <WiFiManager.h>
#include <WiFi.h>
#include <DHT.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <HTTPClient.h>
#include "flood_model.h"  

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

// Sensor Pins
#define echoPin 18
#define trigPin 5
#define DHTPIN 4
#define DHTTYPE DHT11
#define SOIL_SENSOR 34
#define ledpin 26
#define FLOAT_SWITCH_PIN 13
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

// Telegram Bot
const char* BOT_TOKEN = "7412597635:AAHLVyHXiECDQdP6gHUJpkA1DNWsvuVSdrQ";
const char* CHAT_ID = "5550766633";
HTTPClient http;

// Sensor Variables
float temperature = 0;
float humidity = 0;
int soilMoisture = 0;
float distance = 0;
bool rainDetected = false;
bool floatSwitchStatus = false;
bool ledState = false;

// Flood Prediction Variables
float water_rate = 0;
float prev_water_level = 0;
unsigned long last_water_measurement = 0;
float flood_probability = 0;
bool flood_alert_triggered = false;

// Previous States for Alerts
bool lastRainState = false;
bool lastFloatSwitchState = false;
float lastDistance = 0;
int lastSoilMoisture = 0;
float lastTemperature = 0;
float lastHumidity = 0;
float last_flood_prob = 0;

// Function Declarations
void connectToWiFi();
String getDateTime();
void uploadDateTimeToFirebase();
void sendTelegramMessage(String message);
void checkAndSendAlerts();
float calculateWaterRate();
void predictFlood();
void triggerFloodAlert();
void uploadFloodPredictionToFirebase(float probability);

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Initialize sensors
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  dht.begin();
  pinMode(SOIL_SENSOR, INPUT);
  pinMode(ledpin, OUTPUT);
  pinMode(FLOAT_SWITCH_PIN, INPUT_PULLUP);
  pinMode(RAIN_DIGITAL_PIN, INPUT);

  // Connect to WiFi
  connectToWiFi();

  // Initialize Firebase
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

  // Initial Telegram message
  sendTelegramMessage("🔄 ESP32 Flood Detection System Started\n📡 Connected to WiFi\n🕒 Time: " + getDateTime());
}

void loop() {
  static unsigned long lastCheckTime = 0;
  static unsigned long lastPredictionTime = 0;
  const unsigned long checkInterval = 5000;
  const unsigned long predictionInterval = 30000; // Predict every 30 seconds

  // Reconnect Wi-Fi if disconnected
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi lost! Reconnecting...");
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
    connectToWiFi();
  }

  // Restart Wi-Fi setup when button is pressed
  if (digitalRead(BUTTON_PIN) == LOW) {
    Serial.println("Button pressed! Restarting Wi-Fi setup...");
    wm.resetSettings();
    delay(1000);
    ESP.restart();
  }

  // Main sensor reading and Firebase update cycle (every 5 seconds)
  if (millis() - lastCheckTime > checkInterval || lastCheckTime == 0) {
    lastCheckTime = millis();

    // Read sensors
    float newTemp = dht.readTemperature();
    float newHum = dht.readHumidity();
    if (!isnan(newTemp)) temperature = newTemp;
    if (!isnan(newHum)) humidity = newHum;

    // Ultrasonic distance measurement
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    long duration = pulseIn(echoPin, HIGH);
    distance = duration * 0.034 / 2;

    // Other sensors
    soilMoisture = analogRead(SOIL_SENSOR);
    floatSwitchStatus = digitalRead(FLOAT_SWITCH_PIN) == LOW;
    rainDetected = digitalRead(RAIN_DIGITAL_PIN) == LOW;

    // Calculate water rate
    water_rate = calculateWaterRate();

    // Send data to Firebase
    if (Firebase.ready() && signupOK) {
      Firebase.RTDB.setFloat(&fbdo, "DTH/Temperature", temperature);
      Firebase.RTDB.setFloat(&fbdo, "DTH/Humidity", humidity);
      Firebase.RTDB.setFloat(&fbdo, "UltraSonic/Distance", distance);
      Firebase.RTDB.setInt(&fbdo, "Soil/Moisture", soilMoisture);
      Firebase.RTDB.setBool(&fbdo, "floatSwitch", floatSwitchStatus);
      Firebase.RTDB.setBool(&fbdo, "Rain/Detect", rainDetected);
      Firebase.RTDB.setFloat(&fbdo, "Predictions/WaterRate", water_rate);
    }

    // Visual alert for high water
    if (distance < 10 || floatSwitchStatus) {
      digitalWrite(ledpin, HIGH);
      ledState = true;
    } else {
      digitalWrite(ledpin, LOW);
      ledState = false;
    }

    // Send alerts
    checkAndSendAlerts();
  }

  // Flood prediction (every 30 seconds)
  if (millis() - lastPredictionTime > predictionInterval || lastPredictionTime == 0) {
    lastPredictionTime = millis();
    predictFlood();
    
    // Upload prediction to Firebase
    if (Firebase.ready() && signupOK) {
      uploadFloodPredictionToFirebase(flood_probability);
    }
    
    // Check if we need to send a flood alert
    if (flood_probability >= 70.0 && !flood_alert_triggered) {
      triggerFloodAlert();
      flood_alert_triggered = true;
    } else if (flood_probability < 70.0 && flood_alert_triggered) {
      flood_alert_triggered = false;
    }
  }

  delay(100);
}

// ===== Helper Functions ===== //

void connectToWiFi() {
  wm.setConfigPortalTimeout(TIMEOUT_SECONDS);
  bool res = wm.autoConnect("ESPTESTING");
  if (!res) {
    Serial.println("Failed to connect!");
  } else {
    Serial.println("Connected to Wi-Fi");
    digitalWrite(LED_PIN, HIGH);
  }
}

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

void uploadDateTimeToFirebase() {
  if (!timeUploaded) {
    String currentDateTime = getDateTime();
    if (Firebase.RTDB.setString(&fbdo, "System/StartupTime", currentDateTime)) {
      timeUploaded = true;
    }
  }
}

void sendTelegramMessage(String message) {
  String url = "https://api.telegram.org/bot" + String(BOT_TOKEN) + "/sendMessage";
  String postData = "chat_id=" + String(CHAT_ID) + "&text=" + message + "&parse_mode=HTML";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  int httpResponseCode = http.POST(postData);
  
  if (httpResponseCode > 0) {
    Serial.println("Telegram message sent");
  } else {
    Serial.println("Error sending Telegram message");
  }
  
  http.end();
}

float calculateWaterRate() {
  unsigned long now = millis();
  float current_level = distance;
  
  if (last_water_measurement == 0) {
    last_water_measurement = now;
    prev_water_level = current_level;
    return 0;
  }
  
  float rate = (prev_water_level - current_level) / ((now - last_water_measurement) / 60000.0);
  prev_water_level = current_level;
  last_water_measurement = now;
  
  return rate;
}

void predictFlood() {
  // Prepare input array (order must match training)
  double input[6] = {
    distance,         // water_level (cm)
    temperature,      // temp (°C)
    humidity,         // humidity (%)
    soilMoisture,     // soil_moisture (0-4095)
    rainDetected ? 1.0 : 0.0,  // rain_detection (0 or 1)
    water_rate        // water_rate (cm/min)
  };
  
  // Run prediction
  double output[2];
  score(input, output);
  
  flood_probability = output[1] * 100;
  Serial.printf("Flood Probability: %.2f%%\n", flood_probability);
}

void uploadFloodPredictionToFirebase(float probability) {
  if (Firebase.ready() && signupOK) {
    // Create a prediction object with timestamp
    String path = "Predictions/History/" + String(millis());
    
    FirebaseJson predictionData;
    predictionData.set("probability", probability);
    predictionData.set("timestamp", getDateTime());
    predictionData.set("water_level", distance);
    predictionData.set("water_rate", water_rate);
    predictionData.set("temperature", temperature);
    predictionData.set("humidity", humidity);
    predictionData.set("soil_moisture", soilMoisture);
    predictionData.set("rain_detected", rainDetected);
    
    if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &predictionData)) {
      Serial.println("Prediction data uploaded to Firebase");
    } else {
      Serial.println("Failed to upload prediction data");
    }
    
    // Also update the current prediction
    Firebase.RTDB.setFloat(&fbdo, "Predictions/Current/Probability", probability);
  }
}

void triggerFloodAlert() {
  String currentTime = getDateTime();
  String message = 
    "🚨 FLOOD PREDICTION ALERT\n"
    "⚠️ High probability of flooding!\n"
    "📊 Probability: " + String(flood_probability, 1) + "%\n";
    
  if (water_rate > 0) {
    float minutes_until_flood = (5.0 - distance) / water_rate;
    if (minutes_until_flood > 0) {
      message += "⏳ Estimated time: " + String(minutes_until_flood, 1) + " mins\n";
    }
  }
  
  message += 
    "🌊 Current level: " + String(distance, 1) + " cm\n"
    "💧 Water trend: " + String(water_rate, 2) + " cm/min\n"
    "🌡️ Temperature: " + String(temperature, 1) + "°C\n"
    "💧 Humidity: " + String(humidity, 1) + "%\n"
    "🕒 Time: " + currentTime;
  
  sendTelegramMessage(message);
  digitalWrite(ledpin, HIGH);
  ledState = true;
  
  // Upload alert to Firebase
  if (Firebase.ready() && signupOK) {
    FirebaseJson alertData;
    alertData.set("probability", flood_probability);
    alertData.set("timestamp", currentTime);
    alertData.set("message", "High probability of flooding detected");
    
    String alertPath = "Alerts/" + String(millis());
    Firebase.RTDB.setJSON(&fbdo, alertPath.c_str(), &alertData);
  }
}

void checkAndSendAlerts() {
  String currentTime = getDateTime();
  
  // Water Level Alerts
  if (distance <= 5 && lastDistance > 5) {
    sendTelegramMessage("⚠️ CRITICAL ALERT: Water Level\n🌊 Water level is extremely high!\n📏 Current level: " + String(distance, 1) + " cm\n🕒 Time: " + currentTime);
  } else if (distance <= 10 && distance > 5 && lastDistance > 10) {
    sendTelegramMessage("⚠️ WARNING: Water Level\n💧 Water level is rising\n📏 Current level: " + String(distance, 1) + " cm\n🕒 Time: " + currentTime);
  }
  lastDistance = distance;

  // Float Switch Alerts
  if (floatSwitchStatus != lastFloatSwitchState) {
    sendTelegramMessage(floatSwitchStatus ? 
      "⚠️ ALERT: Float Switch\n🔴 Water level is HIGH\n🕒 Time: " + currentTime :
      "✅ UPDATE: Float Switch\n🟢 Water level is LOW\n🕒 Time: " + currentTime);
  }
  lastFloatSwitchState = floatSwitchStatus;

  // Rain Detection Alerts
  if (rainDetected != lastRainState) {
    sendTelegramMessage(rainDetected ? 
      "☔ Rain Alert\n🌧️ Rain detected\n🕒 Time: " + currentTime :
      "✅ Rain Update\n🌤️ Rain stopped\n🕒 Time: " + currentTime);
  }
  lastRainState = rainDetected;
}