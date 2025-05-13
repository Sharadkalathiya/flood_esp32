import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../services/telegram_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'about_us_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/alert_service.dart';

class SensorDataScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  SensorDataScreen({required this.toggleTheme, required this.themeMode});

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> with TickerProviderStateMixin {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  String temperature = "0";
  String humidity = "0";
  String soilMoisture = "0";
  String waterLevel = "0";
  String floatSwitchStatus = "Loading...";
  String rainDetection = "Loading...";
  bool ledState = false;
  String lastSyncTime = "Syncing...";
  bool isOnline = true;
  Timer? _syncTimer;
  String esplastSyncTime = "Syncing...";
  bool _listenersInitialized = false;
  List<StreamSubscription> _subscriptions = [];

  // Animation controllers
  late AnimationController _temperatureController;
  late AnimationController _humidityController;
  late AnimationController _soilMoistureController;
  late AnimationController _waterLevelController;

  // Sensor limits
  static const double MAX_TEMPERATURE = 40.0;
  static const double MAX_HUMIDITY = 80.0;
  static const double MAX_WATER_LEVEL = 10.0;
  static const int MAX_SOIL_MOISTURE = 900;

  Color get backgroundColor => widget.themeMode == ThemeMode.dark ? Colors.black : Colors.white;
  Color get textColor => widget.themeMode == ThemeMode.dark ? Colors.white : Colors.black;
  Color get cardColor => widget.themeMode == ThemeMode.dark ? Colors.grey[900]! : Colors.grey[100]!;
  Color get secondaryTextColor => widget.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black87;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _temperatureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _humidityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _soilMoistureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _waterLevelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _temperatureController.forward();
    _humidityController.forward();
    _soilMoistureController.forward();
    _waterLevelController.forward();

    getSensorData();
    testTelegramConnection();
    startSyncTimer();
    monitorFirebaseConnection();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _soilMoistureController.dispose();
    _waterLevelController.dispose();
    _syncTimer?.cancel();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _listenersInitialized = false;
    super.dispose();
  }

  void checkSensorLimits() {
    final double? temp = double.tryParse(temperature);
    final double? hum = double.tryParse(humidity);
    final double? water = double.tryParse(waterLevel);
    final int? soil = int.tryParse(soilMoisture);

    if (temp != null && temp > MAX_TEMPERATURE) {
      final message = '🌡️ ALERT: High Temperature!\n\nCurrent Temperature: $temp°C\nTime: ${DateTime.now()}';
      TelegramService.sendMessage(message);
    }
    
    if (hum != null && hum > MAX_HUMIDITY) {
      final message = '💧 ALERT: High Humidity!\n\nCurrent Humidity: $hum%\nTime: ${DateTime.now()}';
      TelegramService.sendMessage(message);
    }
    
    if (water != null && water > MAX_WATER_LEVEL) {
      final message = '🚨 ALERT: High Water Level!\n\nCurrent Level: $water cm\nTime: ${DateTime.now()}';
      TelegramService.sendMessage(message);
    }
    
    if (soil != null && soil > MAX_SOIL_MOISTURE) {
      final message = '🌱 ALERT: High Soil Moisture!\n\nCurrent Moisture: $soil\nTime: ${DateTime.now()}';
      TelegramService.sendMessage(message);
    }
    
    if (floatSwitchStatus == "HIGH") {
      final message = '�� ALERT: Water Level is HIGH!\n\nTime: ${DateTime.now()}\n\n⚠️ Please take immediate action!';
      TelegramService.sendMessage(message);
    }
    
    if (rainDetection == "YES") {
      final message = '⚠️ ALERT: Rain has started!\n\nTime: ${DateTime.now()}';
      TelegramService.sendMessage(message);
    }
  }

  void startSyncTimer() {
    _syncTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      updateSyncTime();
    });
  }

  Future<void> testTelegramConnection() async {
    print('Testing Telegram connection...');
    final isConnected = await TelegramService.testConnection();
    if (!isConnected) {
      print('Warning: Telegram connection test failed!');
    }
  }

  void getSensorData() {
    try {
      // Water Level
      _subscriptions.add(
        dbRef.child("UltraSonic/Distance").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final double? distance = double.tryParse(newValue);
            
            if (distance != null && distance != double.tryParse(waterLevel)) {
              print('Water level changed from $waterLevel to $newValue cm');
              
              if (distance <= 5 && (double.tryParse(waterLevel) ?? 0) > 5) {
                final message = '🚨 DANGER: Water level is critically high! (≤ 5 cm)\n\nCurrent Level: $newValue cm\nTime: ${DateTime.now()}';
                print('Sending critical water level alert: ');
                TelegramService.sendMessage(message);
              } else if (distance <= 10 && distance > 5 && (double.tryParse(waterLevel) ?? 0) > 10) {
                final message = '⚠️ WARNING: Water level is rising! (≤ 10 cm)\n\nCurrent Level: $newValue cm\nTime: ${DateTime.now()}';
                print('Sending water level warning: ');
                TelegramService.sendMessage(message);
              }
            }
            
            setState(() {
              waterLevel = newValue;
              _waterLevelController.forward(from: 0);
            });
          }
        })
      );

      // Temperature
      _subscriptions.add(
        dbRef.child("DTH/Temperature").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final double? temp = double.tryParse(newValue);
            
            if (temp != null && temp != double.tryParse(temperature)) {
              print('Temperature changed from $temperature to $newValue °C');
              if (temp > MAX_TEMPERATURE) {
                final message = '🌡️ ALERT: High Temperature!\n\nCurrent Temperature: $newValue°C\nTime: ${DateTime.now()}';
                print('Sending high temperature alert: ');
                TelegramService.sendMessage(message);
              }
            }
            
            setState(() {
              temperature = newValue;
              _temperatureController.forward(from: 0);
            });
          }
        })
      );

      // Humidity
      _subscriptions.add(
        dbRef.child("DTH/Humidity").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final double? hum = double.tryParse(newValue);
            
            if (hum != null && hum != double.tryParse(humidity)) {
              print('Humidity changed from $humidity to $newValue%');
              if (hum > MAX_HUMIDITY) {
                final message = '💧 ALERT: High Humidity!\n\nCurrent Humidity: $newValue%\nTime: ${DateTime.now()}';
                print('Sending high humidity alert: ');
                TelegramService.sendMessage(message);
              }
            }
            
            setState(() {
              humidity = newValue;
              _humidityController.forward(from: 0);
            });
          }
        })
      );

      // Soil Moisture
      _subscriptions.add(
        dbRef.child("Soil/Moisture").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final int? moisture = int.tryParse(newValue);
            
            if (moisture != null && moisture != int.tryParse(soilMoisture)) {
              print('Soil moisture changed from $soilMoisture to $newValue');
              if (moisture > MAX_SOIL_MOISTURE) {
                final message = '🌱 ALERT: High Soil Moisture!\n\nCurrent Moisture: $newValue\nTime: ${DateTime.now()}';
                print('Sending high soil moisture alert: ');
                TelegramService.sendMessage(message);
              }
            }
            
            setState(() {
              soilMoisture = newValue;
              _soilMoistureController.forward(from: 0);
            });
          }
        })
      );

      // Float Switch
      _subscriptions.add(
        dbRef.child("floatSwitch").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final displayValue = newValue.toLowerCase() == "true" ? "HIGH" : "NORMAL";
            if (displayValue != floatSwitchStatus) {
              print('Float switch changed from $floatSwitchStatus to $displayValue');
              if (displayValue == "HIGH" && floatSwitchStatus != "Loading...") {
                final message = '🚨 ALERT: Water Level is HIGH!\n\nTime: ${DateTime.now()}\n\n⚠️ Please take immediate action!';
                print('Sending high water level alert: ');
                TelegramService.sendMessage(message);
              } else if (displayValue == "NORMAL" && floatSwitchStatus != "Loading...") {
                final message = '💧 UPDATE: Water Level is now NORMAL\n\nTime: ${DateTime.now()}\n\nWater level has returned to normal.';
                print('Sending normal water level alert: ');
                TelegramService.sendMessage(message);
              }
            }
            setState(() {
              floatSwitchStatus = displayValue;
            });
          }
        })
      );

      // Rain Detection
      _subscriptions.add(
        dbRef.child("Rain/Detect").onValue.listen((event) {
          if (event.snapshot.value != null && mounted) {
            final newValue = event.snapshot.value.toString();
            final displayValue = newValue.toLowerCase() == "true" ? "YES" : "NO";
            if (displayValue != rainDetection) {
              print('Rain detection changed from $rainDetection to $displayValue');
              if (displayValue == "YES" && rainDetection != "Loading...") {
                final message = '⚠️ ALERT: Rain has started!\n\nTime: ${DateTime.now()}';
                print('Sending rain alert: ');
                TelegramService.sendMessage(message);
              } else if (displayValue == "NO" && rainDetection != "Loading...") {
                final message = '✅ UPDATE: Rain has stopped\n\nTime: ${DateTime.now()}';
                print('Sending rain stopped alert: ');
                TelegramService.sendMessage(message);
              }
            }
            setState(() {
              rainDetection = displayValue;
            });
          }
        })
      );

      dbRef.child("System/StartupTime").onValue.listen((event) {
        setState(() {
          esplastSyncTime = event.snapshot.value.toString();
        });
      });

      dbRef.child("led").onValue.listen((event) {
        setState(() {
          ledState = event.snapshot.value == true;
        });
      });

      _listenersInitialized = true;
    } catch (e) {
      print('Error getting sensor data: $e');
    }
  }

  void monitorFirebaseConnection() {
    dbRef.child(".info/connected").onValue.listen((event) {
      setState(() {
        isOnline = event.snapshot.value == true;
      });
    });
  }

  void updateSyncTime() {
    DateTime now = DateTime.now();
    setState(() {
      lastSyncTime = isOnline
          ? "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}"
          : "Offline";
    });
  }

  void toggleLED(bool value) {
    dbRef.child("led").set(value);
    setState(() {
      ledState = value;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeMode == ThemeMode.dark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: backgroundColor,
              appBarTheme: AppBarTheme(
                backgroundColor: backgroundColor,
                elevation: 0,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: backgroundColor,
              appBarTheme: AppBarTheme(
                backgroundColor: backgroundColor,
                elevation: 0,
                iconTheme: IconThemeData(color: textColor),
                titleTextStyle: TextStyle(color: textColor),
              ),
            ),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                'Flood Monitoring',
                style: TextStyle(color: textColor),
              ),
              SizedBox(height: 5),
              Text(
                "Last Sync: $esplastSyncTime",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                widget.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: textColor,
              ),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: textColor),
                title: Text('Profile', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: textColor),
                title: Text('About Us', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AboutUsScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: textColor),
                title: Text('Logout', style: TextStyle(color: textColor)),
                onTap: logout,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildGauge(
                        "Soil Moisture",
                        soilMoisture,
                        Colors.green,
                        Icons.grass,
                        suffix: "",
                        maxValue: 5000,
                        controller: _soilMoistureController,
                      ),
                    ),
                    Expanded(
                      child: buildGauge(
                        "Water Level",
                        waterLevel,
                        Colors.blue,
                        Icons.water,
                        suffix: "cm",
                        controller: _waterLevelController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: buildGauge(
                        "Temperature",
                        temperature,
                        Colors.orange,
                        Icons.thermostat,
                        suffix: "°C",
                        maxValue: 60,
                        controller: _temperatureController,
                      ),
                    ),
                    Expanded(
                      child: buildGauge(
                        "Humidity",
                        humidity,
                        Colors.lightBlue,
                        Icons.water_drop,
                        suffix: "%",
                        controller: _humidityController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                buildStatusCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGauge(String title, String value, Color color, IconData icon,
      {String suffix = "", double maxValue = 100, required AnimationController controller}) {
    return Container(
      height: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: maxValue,
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: 0,
                          endValue: double.tryParse(value) ?? 0,
                          color: color,
                          startWidth: 10,
                          endWidth: 10,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            '$value$suffix',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.75,
                        ),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: controller.value * (double.tryParse(value) ?? 0),
                          needleColor: color,
                          needleStartWidth: 1,
                          needleEndWidth: 3,
                          knobStyle: KnobStyle(
                            knobRadius: 0.06,
                            color: color,
                          ),
                          enableAnimation: true,
                          animationType: AnimationType.ease,
                        ),
                      ],
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.1,
                        color: color.withOpacity(0.2),
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      majorTickStyle: MajorTickStyle(
                        length: 6,
                        thickness: 2,
                        color: color.withOpacity(0.3),
                      ),
                      minorTickStyle: MinorTickStyle(
                        length: 3,
                        thickness: 1,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard() {
    return Card(
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                floatSwitchStatus == "HIGH" ? Icons.warning : Icons.check_circle,
                color: floatSwitchStatus == "HIGH" ? Colors.red : Colors.green,
              ),
              title: Text(
                "Water Level Status",
                style: TextStyle(color: textColor),
              ),
              trailing: Text(
                floatSwitchStatus,
                style: TextStyle(
                  color: floatSwitchStatus == "HIGH" ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: widget.themeMode == ThemeMode.dark ? Colors.grey[800] : Colors.grey[300]),
            ListTile(
              leading: Icon(
                rainDetection == "YES" ? Icons.water_drop : Icons.water_drop_outlined,
                color: rainDetection == "YES" ? Colors.red : Colors.blue,
              ),
              title: Text(
                "Rain Detected",
                style: TextStyle(color: textColor),
              ),
              trailing: Text(
                rainDetection,
                style: TextStyle(
                  color: rainDetection == "YES" ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
