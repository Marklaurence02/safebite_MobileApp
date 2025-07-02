import 'package:flutter/material.dart';
import 'notification.dart';
import 'analysis.dart';
import 'profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Base URL for the Express backend (use 10.0.2.2 for Android emulator)
const String baseUrl = 'http://10.0.2.2:3000/api';
// Base URL for the Express backend when running on a website or local browser
const String websiteBaseUrl = 'http://localhost:3000/api';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeBite',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFF9DB2CE),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2196F3), // Blue for highlights
          secondary: Color(0xFF9DB2CE),
          background: Color(0xFF9DB2CE),
          error: Color(0xFFFF5252), // Red for alerts
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF8BA3BF), // Slightly darker shade for cards
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8BA3BF),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2196F3),
        ),
      ),
      home: const SafeBiteHomePage(user: {}),
    );
  }
}

class SafeBiteHomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const SafeBiteHomePage({super.key, required this.user});

  @override
  State<SafeBiteHomePage> createState() => _SafeBiteHomePageState();
}

class _SafeBiteHomePageState extends State<SafeBiteHomePage> {
  String selectedFood = 'Adobo';
  String selectedMonth = 'Jun 2025';
  final List<String> foods = ['Adobo', 'Sinigang', 'Tinola'];
  final List<String> months = ['Jun 2025'];

  // Backend data
  List<Map<String, dynamic>> recentFoodDetections = [];
  bool isLoadingFood = true;
  String foodError = '';

  int sensorActivityCount = 0;
  bool isLoadingSensor = true;
  String sensorError = '';

  List<Map<String, dynamic>> dailySensorData = [];
  bool isLoadingChart = true;
  String chartError = '';

  @override
  void initState() {
    super.initState();
    fetchRecentFoodDetections();
    fetchSensorActivity();
    fetchDailySensorData();
  }

  Future<void> fetchRecentFoodDetections() async {
    setState(() {
      isLoadingFood = true;
      foodError = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      if (sessionToken == null) {
        setState(() {
          foodError = 'Not logged in';
          isLoadingFood = false;
        });
        return;
      }
      final apiUrl = kIsWeb ? websiteBaseUrl : baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/dashboard/recent-food'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $sessionToken',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            recentFoodDetections = List<Map<String, dynamic>>.from(data['data']);
            isLoadingFood = false;
          });
        } else {
          setState(() {
            foodError = 'Failed to load food data';
            isLoadingFood = false;
          });
        }
      } else {
        setState(() {
          foodError = 'Server error: ${response.statusCode}';
          isLoadingFood = false;
        });
      }
    } catch (e) {
      setState(() {
        foodError = 'Error: ${e.toString()}';
        isLoadingFood = false;
      });
    }
  }

  Future<void> fetchSensorActivity() async {
    setState(() {
      isLoadingSensor = true;
      sensorError = '';
    });
    try {
      final userId = widget.user['user_id'];
      if (userId == null) {
        setState(() {
          sensorError = 'User ID not found';
          isLoadingSensor = false;
        });
        return;
      }
      final apiUrl = kIsWeb ? websiteBaseUrl : baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/dashboard/sensor-activity?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            sensorActivityCount = data['usage_count'] ?? 0;
            isLoadingSensor = false;
          });
        } else {
          setState(() {
            sensorError = 'Failed to load sensor data';
            isLoadingSensor = false;
          });
        }
      } else {
        setState(() {
          sensorError = 'Server error: ${response.statusCode}';
          isLoadingSensor = false;
        });
      }
    } catch (e) {
      setState(() {
        sensorError = 'Error: ${e.toString()}';
        isLoadingSensor = false;
      });
    }
  }

  Future<void> fetchDailySensorData() async {
    setState(() {
      isLoadingChart = true;
      chartError = '';
    });
    try {
      final userId = widget.user['user_id'];
      if (userId == null) {
        setState(() {
          chartError = 'User ID not found';
          isLoadingChart = false;
        });
        return;
      }
      final start = '2025-06-01'; // or dynamically from selectedMonth
      final end = '2025-06-30';   // or dynamically from selectedMonth
      final apiUrl = kIsWeb ? websiteBaseUrl : baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/dashboard/sensor-activity?user_id=$userId&start=$start&end=$end&chart=1'),
      );
      if (response.statusCode == 200) {
        print('Chart response: ${response.body}');
        final data = json.decode(response.body);
        final rawData = data['data'];
        if (rawData != null && rawData is List) {
          setState(() {
            dailySensorData = List<Map<String, dynamic>>.from(rawData);
            isLoadingChart = false;
          });
        } else {
          setState(() {
            dailySensorData = [];
            chartError = 'No chart data available';
            isLoadingChart = false;
          });
        }
      } else {
        setState(() {
          chartError = 'Server error: ${response.statusCode}';
          isLoadingChart = false;
        });
      }
    } catch (e) {
      setState(() {
        chartError = 'Error: ${e.toString()}';
        isLoadingChart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BA3BF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1739),
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            children: [
              TextSpan(text: 'Safe'),
              TextSpan(text: 'Bite', style: TextStyle(color: Color(0xFF2196F3))),
            ],
          ),
        ),
        centerTitle: false,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sensors Section
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0B1739),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sensors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        DropdownButton<String>(
                          value: selectedFood,
                          dropdownColor: const Color(0xFF23242B),
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: foods.map((food) => DropdownMenuItem(
                            value: food,
                            child: Text(food),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFood = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sensorCard('Methane Gas', '1 ppm', Colors.red, 0.1, Icons.speed),
                        _sensorCard('Temperature', '24° C', Colors.yellow, 0.5, Icons.thermostat),
                        _sensorCard('Humidity', '67.5% RH', Colors.green, 0.8, Icons.water_drop),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sensor Activity Section
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0B1739),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sensor activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        DropdownButton<String>(
                          value: selectedMonth,
                          dropdownColor: const Color(0xFF23242B),
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: months.map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: const Color(0xFF0B1739),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Usage Count: ', style: TextStyle(color: Colors.white70)),
                                if (isLoadingSensor)
                                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
                                else if (sensorError.isNotEmpty)
                                  Text(sensorError, style: const TextStyle(color: Colors.redAccent, fontSize: 12))
                                else
                                  Text(' $sensorActivityCount', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 200,
                              padding: EdgeInsets.all(8),
                              child: isLoadingChart
                                  ? Center(child: CircularProgressIndicator())
                                  : chartError.isNotEmpty
                                      ? Center(child: Text(chartError, style: TextStyle(color: Colors.red)))
                                      : (dailySensorData.isEmpty
                                          ? Center(child: Text('No data', style: TextStyle(color: Colors.white54)))
                                          : LineChart(
                                              LineChartData(
                                                gridData: FlGridData(show: false),
                                                titlesData: FlTitlesData(
                                                  leftTitles: AxisTitles(
                                                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                                  ),
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      getTitlesWidget: (value, meta) {
                                                        int idx = value.toInt();
                                                        if (idx % 7 == 0 && idx < dailySensorData.length) {
                                                          return Text(
                                                            dailySensorData[idx]['date'].substring(5), // MM-DD
                                                            style: TextStyle(color: Colors.white54, fontSize: 10),
                                                          );
                                                        }
                                                        return Container();
                                                      },
                                                      reservedSize: 32,
                                                    ),
                                                  ),
                                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                ),
                                                borderData: FlBorderData(show: false),
                                                minX: 0,
                                                maxX: (dailySensorData.length - 1).toDouble(),
                                                minY: 0,
                                                maxY: dailySensorData.isNotEmpty
                                                    ? dailySensorData.map((e) => (e['count'] as num).toDouble()).reduce((a, b) => a > b ? a : b) + 10
                                                    : 10,
                                                lineBarsData: [
                                                  LineChartBarData(
                                                    spots: [
                                                      for (int i = 0; i < dailySensorData.length; i++)
                                                        FlSpot(i.toDouble(), (dailySensorData[i]['count'] as num).toDouble())
                                                    ],
                                                    isCurved: true,
                                                    color: Colors.cyanAccent,
                                                    barWidth: 3,
                                                    belowBarData: BarAreaData(
                                                      show: true,
                                                      color: Colors.cyanAccent.withOpacity(0.15),
                                                    ),
                                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                                            )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Recent Food Detections Section
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0B1739),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Food Detections', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        DropdownButton<String>(
                          value: selectedMonth,
                          dropdownColor: const Color(0xFF23242B),
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: months.map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: const Color(0xFF0B1739),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Expanded(child: Text('Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              ],
                            ),
                            const Divider(color: Colors.white12),
                            ...(
                              isLoadingFood
                                ? [const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
                                  )]
                                : foodError.isNotEmpty
                                  ? [Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(foodError, style: const TextStyle(color: Colors.redAccent)),
                                    )]
                                  : recentFoodDetections.isEmpty
                                    ? [const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('No recent food detections.', style: TextStyle(color: Colors.white70)),
                                      )]
                                    : recentFoodDetections.map((row) {
                                        final statusColors = {
                                          'Good': Colors.green,
                                          'Spoilt': Colors.red,
                                          'Spoilt warning': Colors.yellow,
                                        };
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(row['food'] ?? '', style: const TextStyle(color: Colors.white))),
                                              Expanded(child: Text(row['date'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10))),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle, color: statusColors[row['status']] ?? Colors.grey, size: 11),
                                                    const SizedBox(width: 6),
                                                    Text(row['status'] ?? '', style: TextStyle(color: statusColors[row['status']] ?? Colors.grey, fontWeight: FontWeight.bold, fontSize: 9)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B1739),
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: const Color(0xFF80848F),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NotificationPage(user: widget.user)),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AnalysisPage(user: widget.user)),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
            );
          }
        },
      ),
    );
  }

  Widget _sensorCard(String label, String value, Color color, double percent, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.white24, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 9),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: percent,
                    backgroundColor: const Color(0xFF0B1739),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 5,
                  ),
                ),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}


