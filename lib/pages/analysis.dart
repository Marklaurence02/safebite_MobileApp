// pages/analysis.dart

import 'package:flutter/material.dart';
import 'home.dart';
import 'notification.dart';
import 'profile.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String selectedMonth = 'Jun 2025';
  final List<String> months = ['Jun 2025', 'Jul 2025', 'Aug 2025'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                  backgroundColor: const Color(0xFF8BA3BF),

      appBar: AppBar(
        title: const Text('Analysis',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B1739),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _aiAnalyzerSummaryBox(),
              SizedBox(height: 24),
              _sensorActivityChart(),
              SizedBox(height: 24),
              _foodRiskChart(),
              SizedBox(height: 24),
              _recentFoodDetectionsTable(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF0B1739),
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SafeBiteHomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _aiAnalyzerSummaryBox() {
    return Card(
      color: Color(0xFF0B1739),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Analyzer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('Sensor activity ⬆️ 30%: Indicates increased scanning and possibly user engagement.', style: TextStyle(color: Colors.white)),
            SizedBox(height: 4),
            Text('Food risk ⬇️ 50%: Suggests improvement in food handling or detection accuracy.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _sensorActivityChart() {
    return Card(
      color: Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sensor Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  dropdownColor: Color(0xFF23242B),
                  style: TextStyle(color: Colors.white),
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
            SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF181A20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.white38)),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Score: 100', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Text('+10%', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

   Widget _foodRiskChart() {
    return Card(
      color: Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Food Risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  dropdownColor: Color.fromARGB(255, 236, 237, 240),
                  style: TextStyle(color: Colors.white),
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
            SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF181A20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('Line Chart Placeholder', style: TextStyle(color: const Color.fromARGB(97, 255, 255, 255))),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Score: 100', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Text('-50%', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentFoodDetectionsTable() {
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
    return Card(
      color: Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
            Divider(color: Colors.white12),
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(child: Text(row[0],style: TextStyle(color: Colors.white))),
                    Expanded(child: Text(row[1],style: TextStyle(color: Colors.white))),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: statusColors[row[2]], size: 14),
                          SizedBox(width: 6),
                          Text(row[2], style: TextStyle(color: statusColors[row[2]], fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}