import 'package:flutter/material.dart';
import 'notification.dart';
import 'analysis.dart';
import 'profile.dart';

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
      home: const SafeBiteHomePage(),
    );
  }
}

class SafeBiteHomePage extends StatefulWidget {
  const SafeBiteHomePage({super.key});

  @override
  State<SafeBiteHomePage> createState() => _SafeBiteHomePageState();
}

class _SafeBiteHomePageState extends State<SafeBiteHomePage> {
  String selectedFood = 'Adobo';
  String selectedMonth = 'Jun 2025';
  final List<String> foods = ['Adobo', 'Sinigang', 'Tinola'];
  final List<String> months = ['Jun 2025'];

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
                                const Text('Score: ', style: TextStyle(color: Colors.white70)),
                                const Text('100', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('+10%', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1739),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.15),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.white38)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('June 1 - June 24', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                            ..._recentFoodDetectionsRows(),
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
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AnalysisPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfilePage()),
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

  List<Widget> _recentFoodDetectionsRows() {
    final rows = [
      ['Adobo', 'Jun 1, 2025', 'Good'],
      ['Sinigang', 'Jun 3, 2025', 'Spoilt'],
      ['Tinola', 'Jun 8, 2025', 'Good'],
      ['Adobo', 'Jun 8, 2025', 'Spoilt warning'],
    ];
    final statusColors = {
      'Good': Colors.green,
      'Spoilt': Colors.red,
      'Spoilt warning': Colors.yellow,
    };
    final statusTextColors = {
      'Good': Colors.green,
      'Spoilt': Colors.red,
      'Spoilt warning': Colors.yellow,
    };
    return rows.map((row) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Expanded(child: Text(row[0], style: const TextStyle(color: Colors.white))),
            Expanded(child: Text(row[1], style: const TextStyle(color: Colors.white,fontSize: 10))),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.circle, color: statusColors[row[2]], size: 11),
                  const SizedBox(width: 6),
                  Text(row[2], style: TextStyle(color: statusTextColors[row[2]], fontWeight: FontWeight.bold, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}


