import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class ExerciseRecommendations extends StatefulWidget {
  @override
  _ExerciseRecommendationsState createState() =>
      _ExerciseRecommendationsState();
}

class _ExerciseRecommendationsState extends State<ExerciseRecommendations> {
  String _selectedCategory = 'All';
  int _dailyGoal = 30; // minutes
  int _currentProgress = 15; // minutes

  final List<String> _categories = ['All', 'Cardio', 'Strength', 'Flexibility'];
  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Morning Yoga',
      'duration': '15 min',
      'calories': 120,
      'category': 'Flexibility',
      'level': 'Beginner',
      'image': 'assets/images/yoga.jpg',
    },
    {
      'title': 'HIIT Workout',
      'duration': '20 min',
      'calories': 250,
      'category': 'Cardio',
      'level': 'Intermediate',
      'image': 'assets/images/hiit.jpg',
    },
    {
      'title': 'Core Strength',
      'duration': '15 min',
      'calories': 150,
      'category': 'Strength',
      'level': 'Beginner',
      'image': 'assets/images/core.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stay active, stay healthy',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 16),
                _buildCategorySelector(),
                SizedBox(height: 16),
                _buildExerciseList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Goal',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            Text(
              '$_currentProgress/$_dailyGoal min',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: _currentProgress / _dailyGoal,
          backgroundColor: AppColors.success.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.success
                        : AppColors.textLight.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseList() {
    final filteredExercises = _selectedCategory == 'All'
        ? _exercises
        : _exercises
              .where((exercise) => exercise['category'] == _selectedCategory)
              .toList();

    return Column(
      children: filteredExercises.map((exercise) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(exercise['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              exercise['title'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      exercise['duration'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${exercise['calories']} cal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise['level'],
                    style: TextStyle(color: AppColors.success, fontSize: 10),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.play_circle_outline,
                color: AppColors.success,
                size: 24,
              ),
              onPressed: () {
                // Implement exercise start functionality
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
