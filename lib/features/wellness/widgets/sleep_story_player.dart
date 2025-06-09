import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class SleepStoryPlayer extends StatefulWidget {
  @override
  _SleepStoryPlayerState createState() => _SleepStoryPlayerState();
}

class _SleepStoryPlayerState extends State<SleepStoryPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Nature', 'Fantasy', 'Calm'];
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'Ocean Waves',
      'description': 'Gentle waves lull you to sleep',
      'duration': '45 min',
      'category': 'Nature',
      'image': 'assets/images/ocean.jpg',
    },
    {
      'title': 'Forest Night',
      'description': 'Peaceful sounds of the forest',
      'duration': '30 min',
      'category': 'Nature',
      'image': 'assets/images/forest.jpg',
    },
    {
      'title': 'Starlit Journey',
      'description': 'A magical journey through the stars',
      'duration': '60 min',
      'category': 'Fantasy',
      'image': 'assets/images/stars.jpg',
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
                  AppColors.secondary.withOpacity(0.1),
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
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Stories',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Drift into peaceful sleep',
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
                _buildCategorySelector(),
                SizedBox(height: 16),
                _buildStoryList(),
                SizedBox(height: 16),
                _buildPlayerControls(),
              ],
            ),
          ),
        ],
      ),
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
                      ? AppColors.secondary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textLight.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.secondary
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

  Widget _buildStoryList() {
    final filteredStories = _selectedCategory == 'All'
        ? _stories
        : _stories
              .where((story) => story['category'] == _selectedCategory)
              .toList();

    return Column(
      children: filteredStories.map((story) {
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
                  image: AssetImage(story['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              story['title'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              story['description'],
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  story['duration'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.play_circle_outline,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ],
            ),
            onTap: () {
              // Implement story playback
            },
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
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.secondary.withOpacity(0.1),
            thumbColor: AppColors.secondary,
            overlayColor: AppColors.secondary.withOpacity(0.1),
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
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
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
