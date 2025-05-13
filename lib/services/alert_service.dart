import 'package:flutter/material.dart';
// import 'telegram_service.dart';

class AlertService {
  static String getWaterLevelAlert(double distance) {
    if (distance <= 5) {
      return "🚨 DANGER: Water level is critically high! (≤ 5 cm)";
    } else if (distance <= 10) {
      return "⚠️ WARNING: Water level is rising! (≤ 10 cm)";
    }
    return "";
  }

  static String getFloatSwitchAlert(String status) {
    if (status == "HIGH") {
      return "🚨 ALERT: Water Level is HIGH!\n\n⚠️ Please take immediate action!";
    } else if (status == "LOW") {
      return "💧 UPDATE: Water Level is now LOW\n\nWater level has returned to normal.";
    }
    return "";
  }

  static String getRainAlert(String status) {
    if (status == "YES") {
      return "⚠️ ALERT: Rain has started! ⚠️";
    } else if (status == "NO") {
      return "✅ UPDATE: Rain has stopped";
    }
    return "";
  }

  static String getSoilMoistureAlert(int value) {
    if (value > 900) {
      return "🚨 DANGER: Soil is extremely wet!";
    } else if (value < 300) {
      return "⚠️ WARNING: Soil is too dry!";
    }
    return "";
  }

  static String getTemperatureAlert(double value) {
    if (value > 40) {
      return "🌡️ WARNING: Temperature too high! (> 40°C)";
    } else if (value < 15) {
      return "🌡️ WARNING: Temperature too low! (< 15°C)";
    }
    return "";
  }

  static String getHumidityAlert(double value) {
    if (value > 90) {
      return "💧 WARNING: Humidity too high! (> 90%)";
    } else if (value < 30) {
      return "💧 WARNING: Humidity too low! (< 30%)";
    }
    return "";
  }

  static Color getAlertColor(String alert) {
    if (alert.contains("🚨")) {
      return Colors.red;
    } else if (alert.contains("⚠️")) {
      return Colors.orange;
    } else if (alert.contains("✅")) {
      return Colors.green;
    }
    return Colors.grey;
  }

  static IconData getAlertIcon(String alert) {
    if (alert.contains("🚨")) {
      return Icons.warning;
    } else if (alert.contains("⚠️")) {
      return Icons.warning_amber;
    } else if (alert.contains("✅")) {
      return Icons.check_circle;
    }
    return Icons.info;
  }

  // Water Level Alerts
  static Future<void> checkWaterLevel(double distance) async {
    if (distance <= 5) {
      // await TelegramService.sendMessage(
      //   '⚠️ CRITICAL ALERT: Water Level\n'
      //   '🌊 Water level is extremely high!\n'
      //   '📏 Current level: ${distance.toStringAsFixed(1)} cm\n'
      //   '⚡ Immediate action required!'
      // );
    } else if (distance <= 10) {
      // await TelegramService.sendMessage(
      //   '⚠️ WARNING: Water Level\n'
      //   '💧 Water level is rising\n'
      //   '📏 Current level: ${distance.toStringAsFixed(1)} cm\n'
      //   '👀 Please Take PreAction'
      // );
    }
  }

  // Float Switch Alerts
  static Future<void> checkFloatSwitch(String status) async {
    if (status.toLowerCase() == 'high') {
      // await TelegramService.sendMessage(
      //   '⚠️ ALERT: Float Switch\n'
      //   '🔴 Water level is HIGH\n'
      //   '💢 Float switch has been triggered\n'
      //   '⚡ Please check water level immediately!'
      // );
    }
  }

  // Rain Detection Alerts
  static Future<void> checkRainStatus(String status) async {
    if (status.toLowerCase() == 'raining') {
      // await TelegramService.sendMessage(
      //   '☔ Rain Alert\n'
      //   '🌧️ Rain has been detected\n'
      //   '📌 Current status: Raining\n'
      //   '⚠️ Please monitor water levels'
      // );
    }
  }

  // Soil Moisture Alerts
  static Future<void> checkSoilMoisture(int value) async {
    if (value > 900) {
      // await TelegramService.sendMessage(
      //   '⚠️ HIGH Soil Moisture Alert\n'
      //   '💦 Soil is extremely wet!\n'
      //   '📊 Current value: $value\n'
      //   '⚡ Risk of flooding!'
      // );
    } else if (value < 300) {
      // await TelegramService.sendMessage(
      //   '⚠️ LOW Soil Moisture Alert\n'
      //   '🏜️ Soil is too dry!\n'
      //   '📊 Current value: $value\n'
      //
      // );
    }
  }

  // Temperature Alerts
  static Future<void> checkTemperature(double value) async {
    if (value > 40) {
      // await TelegramService.sendMessage(
      //   '🌡️ HIGH Temperature Alert\n'
      //   '🔥 High temperature detected!\n'
      //   '📊 Current temperature: ${value.toStringAsFixed(1)}°C\n'
      //   '⚠️ Please check equipment'
      // );
    } else if (value < 15) {
      // await TelegramService.sendMessage(
      //   '🌡️ LOW Temperature Alert\n'
      //   '❄️ Low temperature detected!\n'
      //   '📊 Current temperature: ${value.toStringAsFixed(1)}°C\n'
      //   '⚠️ Risk of equipment malfunction'
      // );
    }
  }

  // Humidity Alerts
  static Future<void> checkHumidity(double value) async {
    if (value > 90) {
      // await TelegramService.sendMessage(
      //   '💧 HIGH Humidity Alert\n'
      //   '🌫️ High humidity detected!\n'
      //   '📊 Current humidity: ${value.toStringAsFixed(1)}%\n'
      //   '⚠️ Risk of condensation'
      // );
    } else if (value < 30) {
      // await TelegramService.sendMessage(
      //   '💧 LOW Humidity Alert\n'
      //   '🏜️ Low humidity detected!\n'
      //   '📊 Current humidity: ${value.toStringAsFixed(1)}%\n'
      //   '⚠️ Environment too dry'
      // );
    }
  }
}