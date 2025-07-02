// pages/analysis.dart

import 'package:flutter/material.dart';
import '../services/analytics_service.dart'; // Import the new service
import 'home.dart';
import 'notification.dart';
import 'profile.dart';

// Base URL for the Express backend (use 10.0.2.2 for Android emulator)
const String baseUrl = 'http://10.0.2.2:3000/api';
// Base URL for the Express backend when running on a website or local browser
const String websiteBaseUrl = 'http://localhost:3000/api';

class AnalysisPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const AnalysisPage({super.key, required this.user});
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String selectedMonth = 'Jun 2025';
  final List<String> months = ['Jun 2025', 'Jul 2025', 'Aug 2025'];

  // Futures to hold the data from the API
  late Future<Map<String, dynamic>> _summaryFuture;
  late Future<Map<String, dynamic>> _sensorActivityFuture;
  late Future<Map<String, dynamic>> _foodRiskFuture;
  late Future<Map<String, dynamic>> _recentDetectionsFuture;
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    // Fetch all data when the widget is initialized
    _summaryFuture = _analyticsService.getSummaryData();
    _sensorActivityFuture = _analyticsService.getSensorActivityData();
    _foodRiskFuture = _analyticsService.getFoodRiskData();
    _recentDetectionsFuture = _analyticsService.getRecentDetections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                  backgroundColor: const Color(0xFF8BA3BF),
      appBar: AppBar(
        title: const Text('Analysis', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B1739),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use FutureBuilder for each section, specifying the expected data type
              _buildFutureBuilder<Map<String, dynamic>>(_summaryFuture, (data) => _aiAnalyzerSummaryBox(data)),
              const SizedBox(height: 24),
              _buildFutureBuilder<Map<String, dynamic>>(_sensorActivityFuture, (data) => _sensorActivityChart(data)),
              const SizedBox(height: 24),
              _buildFutureBuilder<Map<String, dynamic>>(_foodRiskFuture, (data) => _foodRiskChart(data)),
              const SizedBox(height: 24),
              _buildFutureBuilder<List<dynamic>>(_recentDetectionsFuture, (data) => _recentFoodDetectionsTable(data)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B1739),
        selectedItemColor: const Color(0xFF2196F3),
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
              MaterialPageRoute(builder: (context) => SafeBiteHomePage(user: widget.user)),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NotificationPage(user: widget.user)),
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

  // Generic FutureBuilder that can handle different data types from the 'data' field
  Widget _buildFutureBuilder<T>(Future<Map<String, dynamic>> future, Widget Function(T data) builder) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else if (snapshot.hasData) {
          // Cast the data to the expected type T
          return builder(snapshot.data!['data'] as T);
        } else {
          return const Center(child: Text('No data found.'));
        }
      },
    );
  }

  Widget _aiAnalyzerSummaryBox(Map<String, dynamic> data) {
    final activityChange = data['sensorActivityChange'] ?? 0;
    final riskChange = data['foodRiskChange'] ?? 0;

    return Card(
      color: const Color(0xFF0B1739),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Analyzer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Sensor activity ${activityChange > 0 ? '⬆️' : '⬇️'} $activityChange%: ${data['sensorActivityText']}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Food risk ${riskChange > 0 ? '⬆️' : '⬇️'} ${riskChange.abs()}%: ${data['foodRiskText']}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorActivityChart(Map<String, dynamic> data) {
    final score = data['score'] ?? 0;
    final change = data['change'] ?? 0;
    
    return Card(
      color: const Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Sensor Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  dropdownColor: const Color(0xFF23242B),
                  style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.white38)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Score: $score', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('${change > 0 ? '+' : ''}$change%', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodRiskChart(Map<String, dynamic> data) {
    final score = data['score'] ?? 0;
    final change = data['change'] ?? 0;

    return Card(
      color: const Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Food Risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  dropdownColor: const Color.fromARGB(255, 236, 237, 240),
                  style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Line Chart Placeholder', style: TextStyle(color: Color.fromARGB(97, 255, 255, 255))),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Score: $score', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('$change%', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentFoodDetectionsTable(List<dynamic> rows) {
    final statusColors = {
      'Good': Colors.green,
      'Spoilt': Colors.red,
      'Spoilt warning': Colors.orange,
    };
    return Card(
      color: const Color(0xFF19233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(child: Text('Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
            const Divider(color: Colors.white12),
            ...rows.map((row) {
              final item = row as Map<String, dynamic>;
              final food = item['food'] ?? 'N/A';
              final date = item['date'] ?? 'N/A';
              final status = item['status'] ?? 'N/A';
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(child: Text(food, style: const TextStyle(color: Colors.white))),
                    Expanded(child: Text(date, style: const TextStyle(color: Colors.white))),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: statusColors[status] ?? Colors.grey, size: 14),
                          const SizedBox(width: 6),
                          Text(status, style: TextStyle(color: statusColors[status] ?? Colors.grey, fontSize: 12)),
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