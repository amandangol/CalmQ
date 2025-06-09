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
            CustomAppBar(title: 'Water Tracker', showBackButton: true),
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
