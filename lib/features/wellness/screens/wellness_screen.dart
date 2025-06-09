import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';
import '../widgets/meditation_player.dart';
import '../widgets/sleep_story_player.dart';
import '../widgets/stress_tracker.dart';
import '../widgets/exercise_recommendations.dart';
import '../widgets/nutrition_tracker.dart';
import '../widgets/water_tracker.dart';

class WellnessScreen extends StatefulWidget {
  @override
  _WellnessScreenState createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFF8F9FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'Wellness Tools', showBackButton: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Today\'s Wellness'),
                      SizedBox(height: 16),
                      _buildWellnessOverview(),
                      SizedBox(height: 24),
                      _buildSectionTitle('Guided Meditation'),
                      SizedBox(height: 16),
                      MeditationPlayer(),
                      SizedBox(height: 24),
                      _buildSectionTitle('Sleep Stories'),
                      SizedBox(height: 16),
                      SleepStoryPlayer(),
                      SizedBox(height: 24),
                      _buildSectionTitle('Stress Level'),
                      SizedBox(height: 16),
                      StressTracker(),
                      SizedBox(height: 24),
                      _buildSectionTitle('Exercise & Nutrition'),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: ExerciseRecommendations()),
                          SizedBox(width: 16),
                          Expanded(child: NutritionTracker()),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildSectionTitle('Water Intake'),
                      SizedBox(height: 16),
                      WaterTracker(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildWellnessOverview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWellnessStat(
                'Meditation',
                '15 min',
                Icons.self_improvement,
              ),
              _buildWellnessStat('Water', '1.5L', Icons.water_drop),
              _buildWellnessStat('Exercise', '30 min', Icons.fitness_center),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 8),
          Text(
            'Daily Goal: 70% Complete',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
