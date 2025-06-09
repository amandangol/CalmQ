import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class MeditationPlayer extends StatefulWidget {
  @override
  _MeditationPlayerState createState() => _MeditationPlayerState();
}

class _MeditationPlayerState extends State<MeditationPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;
  String _selectedDuration = '10 min';

  final List<String> _durations = ['5 min', '10 min', '15 min', '20 min'];
  final List<Map<String, dynamic>> _meditations = [
    {
      'title': 'Mindful Breathing',
      'description': 'Focus on your breath and find inner peace',
      'duration': '10 min',
      'icon': Icons.air,
    },
    {
      'title': 'Body Scan',
      'description': 'Release tension and relax your body',
      'duration': '15 min',
      'icon': Icons.self_improvement,
    },
    {
      'title': 'Loving Kindness',
      'description': 'Cultivate compassion and positive energy',
      'duration': '20 min',
      'icon': Icons.favorite,
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
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guided Meditation',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Find your inner peace',
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
                _buildDurationSelector(),
                SizedBox(height: 16),
                _buildMeditationList(),
                SizedBox(height: 16),
                _buildPlayerControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDuration = duration;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textLight.withOpacity(0.2),
              ),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMeditationList() {
    return Column(
      children: _meditations.map((meditation) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  meditation['icon'],
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation['title'],
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      meditation['description'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                meditation['duration'],
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerControls() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.1),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: _progress,
            onChanged: (value) {
              setState(() {
                _progress = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay_10, color: AppColors.textSecondary),
              onPressed: () {
                // Implement rewind functionality
              },
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.forward_10, color: AppColors.textSecondary),
              onPressed: () {
                // Implement forward functionality
              },
            ),
          ],
        ),
      ],
    );
  }
}
