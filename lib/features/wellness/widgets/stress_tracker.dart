import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class StressTracker extends StatefulWidget {
  @override
  _StressTrackerState createState() => _StressTrackerState();
}

class _StressTrackerState extends State<StressTracker> {
  double _currentStressLevel = 0.5;
  List<Map<String, dynamic>> _stressHistory = [];
  String _selectedTimeFrame = 'Today';

  final List<String> _timeFrames = ['Today', 'Week', 'Month'];
  final List<Map<String, dynamic>> _stressFactors = [
    {'title': 'Work Pressure', 'level': 0.7, 'icon': Icons.work},
    {'title': 'Sleep Quality', 'level': 0.4, 'icon': Icons.bedtime},
    {'title': 'Physical Activity', 'level': 0.3, 'icon': Icons.fitness_center},
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
                  AppColors.error.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stress Level',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track and manage your stress',
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
                _buildTimeFrameSelector(),
                SizedBox(height: 16),
                _buildStressLevelIndicator(),
                SizedBox(height: 16),
                _buildStressFactors(),
                SizedBox(height: 16),
                _buildRecommendations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _timeFrames.map((timeFrame) {
        final isSelected = _selectedTimeFrame == timeFrame;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTimeFrame = timeFrame;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.error.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.error
                    : AppColors.textLight.withOpacity(0.2),
              ),
            ),
            child: Text(
              timeFrame,
              style: TextStyle(
                color: isSelected ? AppColors.error : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStressLevelIndicator() {
    return Column(
      children: [
        Text(
          'Current Stress Level',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.success,
                      AppColors.warning,
                      AppColors.error,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    '${(_currentStressLevel * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.error,
            inactiveTrackColor: AppColors.error.withOpacity(0.1),
            thumbColor: AppColors.error,
            overlayColor: AppColors.error.withOpacity(0.1),
          ),
          child: Slider(
            value: _currentStressLevel,
            onChanged: (value) {
              setState(() {
                _currentStressLevel = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStressFactors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stress Factors',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ..._stressFactors.map((factor) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(factor['icon'], color: AppColors.error, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factor['title'],
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: factor['level'],
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.error,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Try these activities to reduce stress:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRecommendationChip('Take a walk'),
              _buildRecommendationChip('Practice deep breathing'),
              _buildRecommendationChip('Listen to calming music'),
              _buildRecommendationChip('Do some stretching'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: AppColors.success, fontSize: 12),
      ),
    );
  }
}
