import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class NutritionTracker extends StatefulWidget {
  @override
  _NutritionTrackerState createState() => _NutritionTrackerState();
}

class _NutritionTrackerState extends State<NutritionTracker> {
  final List<Map<String, dynamic>> _meals = [
    {
      'name': 'Breakfast',
      'time': '8:00 AM',
      'items': [
        {'name': 'Oatmeal', 'calories': 150},
        {'name': 'Banana', 'calories': 105},
        {'name': 'Coffee', 'calories': 5},
      ],
    },
    {
      'name': 'Lunch',
      'time': '12:30 PM',
      'items': [
        {'name': 'Grilled Chicken Salad', 'calories': 350},
        {'name': 'Whole Grain Bread', 'calories': 120},
      ],
    },
    {
      'name': 'Dinner',
      'time': '7:00 PM',
      'items': [
        {'name': 'Salmon', 'calories': 280},
        {'name': 'Brown Rice', 'calories': 220},
        {'name': 'Steamed Vegetables', 'calories': 100},
      ],
    },
  ];

  final Map<String, double> _nutritionGoals = {
    'Calories': 2000,
    'Protein': 60,
    'Carbs': 250,
    'Fat': 65,
  };

  final Map<String, double> _nutritionProgress = {
    'Calories': 1230,
    'Protein': 45,
    'Carbs': 150,
    'Fat': 40,
  };

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
                  AppColors.warning.withOpacity(0.1),
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
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track your daily intake',
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
                _buildNutritionProgress(),
                SizedBox(height: 16),
                _buildMealList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Nutrition',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_nutritionProgress['Calories']?.toInt()}/${_nutritionGoals['Calories']?.toInt()} cal',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),
        ..._nutritionGoals.entries.map((entry) {
          final progress = _nutritionProgress[entry.key] ?? 0;
          final goal = entry.value;
          final percentage = progress / goal;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${progress.toInt()}/${goal.toInt()}g',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.warning.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMealList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Meals',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ..._meals.map((meal) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    meal['name'],
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    meal['time'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.warning,
                      size: 24,
                    ),
                    onPressed: () {
                      // Implement add food functionality
                    },
                  ),
                ),
                ...meal['items'].map<Widget>((item) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${item['calories']} cal',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
