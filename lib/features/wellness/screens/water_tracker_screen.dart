import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';
import '../widgets/water_tracker.dart';

class WaterTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F7FA), Color(0xFFE8ECF4)],
          ),
        ),
        child: Column(
          children: [
            CustomAppBar(
              title: 'Water Tracker',
              showBackButton: true,
              subtitle: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Stay hydrated, stay healthy',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: WaterTracker(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
