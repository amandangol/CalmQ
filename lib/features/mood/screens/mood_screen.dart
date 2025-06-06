import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final weekMoods = moodProvider.getLatestMoodPerDayForWeek();

    return Scaffold(
      appBar: AppBar(title: Text('Mood & Sentiment Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood & Sentiment Trends',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _MoodSentimentChart(weekMoods: weekMoods),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getWeeklySummary(weekMoods),
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Recent Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: moodProvider.moodHistory.length,
                itemBuilder: (context, index) {
                  final entry = moodProvider
                      .moodHistory[moodProvider.moodHistory.length - 1 - index];
                  final imagePath =
                      'assets/images/' +
                      Provider.of<MoodProvider>(
                        context,
                        listen: false,
                      ).getMoodImage(entry.mood) +
                      '.png';
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(imagePath, width: 28, height: 28),
                                SizedBox(width: 8),
                                Text(
                                  entry.mood,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatDate(entry.timestamp),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (entry.trigger != null &&
                            entry.trigger!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  entry.trigger!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.85),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            entry.note!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Mood: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    entry.mood,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(entry.emoji),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Sentiment: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    _getSentiment(entry),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Dummy sentiment
  String _getSentiment(MoodEntry entry) {
    switch (entry.mood.toLowerCase()) {
      case 'very happy':
      case 'happy':
        return 'Positive';
      case 'neutral':
        return 'Neutral';
      case 'sad':
      case 'very sad':
        return 'Negative';
      default:
        return 'Neutral';
    }
  }

  String _getWeeklySummary(List<MoodEntry> week) {
    if (week.isEmpty) return 'No mood data for this week.';
    final positives = week.where((e) => _getSentiment(e) == 'Positive').length;
    final negatives = week.where((e) => _getSentiment(e) == 'Negative').length;
    final neutrals = week.length - positives - negatives;
    if (positives > negatives && positives > neutrals) {
      return 'Your overall sentiment has been positive!';
    } else if (negatives > positives && negatives > neutrals) {
      return 'Your overall sentiment has been negative.';
    } else {
      return 'Your overall sentiment has been relatively neutral.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _MoodSentimentChart extends StatelessWidget {
  final List<MoodEntry> weekMoods;
  const _MoodSentimentChart({required this.weekMoods});

  // Map moods to numeric values for chart
  double _moodToValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
        return 4;
      case 'happy':
        return 3;
      case 'neutral':
        return 2;
      case 'sad':
        return 1;
      case 'very sad':
        return 0;
      default:
        return 2;
    }
  }

  double _sentimentToValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
      case 'happy':
        return 2;
      case 'neutral':
        return 1;
      case 'sad':
      case 'very sad':
        return 0;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    // Use weekday index for x value and weekday label for x-axis
    final now = DateTime.now();
    final List<FlSpot> moodSpots = [];
    final List<FlSpot> sentimentSpots = [];
    final List<String> dayLabels = [];
    for (int i = 0; i < weekMoods.length; i++) {
      final entry = weekMoods[i];
      final weekday = entry.timestamp.weekday % 7; // 0=Sunday, 1=Monday, ...
      moodSpots.add(FlSpot(i.toDouble(), _moodToValue(entry.mood)));
      sentimentSpots.add(
        FlSpot(i.toDouble(), _sentimentToValue(entry.mood) * 2),
      );
      final label = _weekdayLabel(entry.timestamp.weekday);
      dayLabels.add(label);
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                String mood;
                switch (value.toInt()) {
                  case 0:
                    mood = 'Very Sad';
                    break;
                  case 1:
                    mood = 'Sad';
                    break;
                  case 2:
                    mood = 'Neutral';
                    break;
                  case 3:
                    mood = 'Happy';
                    break;
                  case 4:
                    mood = 'Very Happy';
                    break;
                  default:
                    mood = 'Neutral';
                }
                final imagePath =
                    'assets/images/' + moodProvider.getMoodImage(mood) + '.png';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.asset(imagePath, width: 24, height: 24),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < dayLabels.length) {
                  return Text(dayLabels[idx]);
                }
                return Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (weekMoods.length - 1).toDouble(),
        minY: 0,
        maxY: 4,
        lineBarsData: [
          LineChartBarData(
            spots: moodSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: sentimentSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
