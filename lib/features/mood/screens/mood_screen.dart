import 'package:auralynn/features/home/screens/home_screen.dart';
import 'package:auralynn/features/mood/screens/all_moods_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';
import '../../../app_theme.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatefulWidget {
  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  DateTime currentMonth = DateTime.now();

  void _navigateMonth(bool forward) {
    setState(() {
      if (forward) {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      } else {
        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final weekMoods = moodProvider.getLatestMoodPerDayForWeek();
    final groupedMoodHistory = moodProvider.getGroupedMoodHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar as a widget, not as Scaffold.appBar
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.mood_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Mood Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        DateFormat('MMM yyyy').format(currentMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => _navigateMonth(false),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => _navigateMonth(true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body content
          Expanded(
            child: moodProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await moodProvider.refreshData();
                    },
                    child: CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Today's Quick Check-in Section
                                _buildTodayCheckinSection(context),
                                SizedBox(height: 24),

                                // Mood Chart Section
                                if (weekMoods.isNotEmpty) ...[
                                  Text(
                                    'Weekly Mood Trend',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    height: 280,
                                    child: _MoodBarChart(weekMoods: weekMoods),
                                  ),
                                  SizedBox(height: 24),
                                ],

                                // Mood Statistics
                                if (weekMoods.isNotEmpty) ...[
                                  _buildMoodStats(context, weekMoods),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Recent Entries Section (Grouped by Date)
                        if (groupedMoodHistory.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Entries',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllMoodsScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View All',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final dateKey = groupedMoodHistory.keys
                                    .elementAt(index);
                                final entries = groupedMoodHistory[dateKey]!;
                                // Only show entries for the first 5 days
                                if (index >= 5) return null;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Text(
                                        dateKey,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    ...entries.map(
                                      (entry) => _MoodEntryCard(entry: entry),
                                    ),
                                  ],
                                );
                              }, childCount: groupedMoodHistory.length),
                            ),
                          ),
                        ] else ...[
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(context),
                          ),
                        ],

                        // Tips Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (groupedMoodHistory.isNotEmpty) ...[
                                  Text(
                                    'Wellness Tips',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  _buildTipSection(
                                    context,
                                    'Connect with nature',
                                    'Spend time outdoors, surrounded by greenery and fresh air',
                                    Icons.nature,
                                  ),
                                  SizedBox(height: 16),
                                  _buildTipSection(
                                    context,
                                    'Practice mindfulness',
                                    'Take a few minutes each day to focus on your breathing',
                                    Icons.self_improvement,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: MoodPickerSheet(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayCheckinSection(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = context.read<MoodProvider>();
    final hasTodayEntry = moodProvider.hasTodayEntry();
    final streak = moodProvider.getMoodStreak();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTodayEntry
                        ? 'Today\'s mood logged!'
                        : 'How are you feeling today?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    hasTodayEntry
                        ? 'Great job tracking your mood!'
                        : 'Take a moment to check in with yourself',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.accent,
                    size: 32,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '$streak days',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!hasTodayEntry) ...[
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: MoodPickerSheet(),
                  ),
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Log Your Mood'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodStats(BuildContext context, List<MoodEntry> weekMoods) {
    final theme = Theme.of(context);
    final moodProvider = context.watch<MoodProvider>();
    final sentimentAnalysis = moodProvider.analyzeSentimentTrends();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildSentimentIndicator(
                context,
                sentimentAnalysis['overall_sentiment'],
                sentimentAnalysis['trend'],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Mood',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatSentiment(sentimentAnalysis['overall_sentiment']),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _getSentimentColor(
                          sentimentAnalysis['overall_sentiment'],
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (sentimentAnalysis['insights'].isNotEmpty) ...[
            Text(
              'Insights',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...sentimentAnalysis['insights']
                .map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.insights,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator(
    BuildContext context,
    String sentiment,
    String trend,
  ) {
    final color = _getSentimentColor(sentiment);
    final icon = _getTrendIcon(trend);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 4),
          Icon(Icons.mood, color: color, size: 24),
        ],
      ),
    );
  }

  String _formatSentiment(String sentiment) {
    switch (sentiment) {
      case 'very positive':
        return 'Very Positive';
      case 'positive':
        return 'Positive';
      case 'neutral':
        return 'Neutral';
      case 'negative':
        return 'Negative';
      case 'very negative':
        return 'Very Negative';
      default:
        return 'Neutral';
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'very positive':
        return Colors.green;
      case 'positive':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.orange;
      case 'negative':
        return Colors.orangeAccent;
      case 'very negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mood, size: 60, color: AppColors.primary),
          ),
          SizedBox(height: 24),
          Text(
            'Start Your Mood Journey',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Log your first mood to see your history and\ntrack your emotional patterns over time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: MoodPickerSheet(),
                ),
              );
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Log Your First Mood'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Mood Entry Card with better error handling and UX
class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final imagePath =
        'assets/images/${moodProvider.getMoodImage(entry.mood)}.png';
    final sentiment = _getSentiment(entry.mood);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to detailed view
            _showMoodDetails(context, entry);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MoodColors.getMoodColor(
                              entry.mood,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(imagePath, width: 24, height: 24),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.mood,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Feeling $sentiment',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(entry.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              context,
                              'Edit',
                              AppColors.primary,
                              () => _editMoodEntry(context, entry),
                            ),
                            SizedBox(width: 12),
                            _buildActionButton(
                              context,
                              'Delete',
                              AppColors.error,
                              () => _deleteMoodEntry(context, entry),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (entry.trigger != null && entry.trigger!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Trigger: ${entry.trigger!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    entry.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.note!.length > 100) ...[
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showMoodDetails(context, entry),
                      child: Text(
                        'Read more',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showMoodDetails(BuildContext context, MoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoodDetailModal(entry: entry),
    );
  }

  void _editMoodEntry(BuildContext context, MoodEntry entry) {
    Navigator.pushNamed(context, '/edit-mood', arguments: entry);
  }

  void _deleteMoodEntry(BuildContext context, MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Mood Entry'),
        content: Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MoodProvider>(
                context,
                listen: false,
              ).deleteMoodEntry(entry.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Mood entry deleted')));
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _getSentiment(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
      case 'awesome':
        return 'excited and joyful';
      case 'happy':
      case 'good':
        return 'positive and content';
      case 'neutral':
      case 'okay':
        return 'balanced';
      case 'sad':
      case 'down':
        return 'melancholic';
      case 'angry':
      case 'terrible':
        return 'frustrated';
      case 'anxious':
        return 'worried';
      case 'stressed':
        return 'overwhelmed';
      default:
        return 'complex emotions';
    }
  }
}

// Modal for detailed mood entry view
class _MoodDetailModal extends StatelessWidget {
  final MoodEntry entry;

  const _MoodDetailModal({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/${moodProvider.getMoodImage(entry.mood)}.png',
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.mood,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'EEEE, MMMM d, yyyy • HH:mm',
                            ).format(entry.timestamp),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (entry.trigger != null && entry.trigger!.isNotEmpty) ...[
                    Text(
                      'Trigger',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      entry.trigger!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          entry.note!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Bar Chart with better visual feedback
class _MoodBarChart extends StatelessWidget {
  final List<MoodEntry> weekMoods;

  const _MoodBarChart({required this.weekMoods});

  double _moodToValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
      case 'awesome':
        return 5;
      case 'happy':
      case 'good':
        return 4;
      case 'neutral':
      case 'okay':
        return 3;
      case 'sad':
      case 'down':
        return 2;
      case 'angry':
      case 'terrible':
        return 1;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final List<BarChartGroupData> barGroups = [];

    // Generate data for the last 7 days
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day - (6 - index));
    });

    for (int i = 0; i < last7Days.length; i++) {
      final date = last7Days[i];
      final entry = weekMoods.firstWhere(
        (mood) =>
            mood.timestamp.day == date.day &&
            mood.timestamp.month == date.month &&
            mood.timestamp.year == date.year,
        orElse: () => MoodEntry(
          id: 'placeholder',
          emoji: '😐',
          mood: 'Neutral',
          timestamp: date,
        ),
      );

      final moodValue = _moodToValue(entry.mood);
      final isPlaceholder = entry.id == 'placeholder';

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isPlaceholder ? 0.5 : moodValue,
              color: isPlaceholder
                  ? AppColors.textLight.withOpacity(0.2)
                  : MoodColors.getMoodColor(entry.mood),
              width: 24,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < last7Days.length) {
                  final date = last7Days[index];
                  final entry = weekMoods.firstWhere(
                    (mood) =>
                        mood.timestamp.day == date.day &&
                        mood.timestamp.month == date.month &&
                        mood.timestamp.year == date.year,
                    orElse: () => MoodEntry(
                      id: 'placeholder',
                      emoji: '😐',
                      mood: 'Neutral',
                      timestamp: date,
                    ),
                  );

                  final weekdayLabel = DateFormat('EEE').format(date);
                  final isPlaceholder = entry.id == 'placeholder';

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekdayLabel,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (!isPlaceholder)
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: MoodColors.getMoodColor(
                                entry.mood,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Image.asset(
                              'assets/images/${moodProvider.getMoodImage(entry.mood)}.png',
                              width: 18,
                              height: 18,
                            ),
                          )
                        else
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.textLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 12,
                              color: AppColors.textLight.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textLight.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        groupsSpace: 16,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = last7Days[group.x.toInt()];
              final entry = weekMoods.firstWhere(
                (mood) =>
                    mood.timestamp.day == date.day &&
                    mood.timestamp.month == date.month &&
                    mood.timestamp.year == date.year,
                orElse: () => MoodEntry(
                  id: 'placeholder',
                  emoji: '😐',
                  mood: 'Neutral',
                  timestamp: date,
                ),
              );

              if (entry.id == 'placeholder') {
                return BarTooltipItem(
                  'No entry',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '\n${DateFormat('MMM d').format(date)}',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                );
              }

              return BarTooltipItem(
                entry.mood,
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: '\n${DateFormat('MMM d').format(entry.timestamp)}',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  if (entry.trigger != null && entry.trigger!.isNotEmpty)
                    TextSpan(
                      text: '\n${entry.trigger}',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper class for mood colors (assuming this exists in your project)
class MoodColors {
  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
      case 'awesome':
        return Color(0xFF4CAF50); // Green
      case 'happy':
      case 'good':
        return Color(0xFF8BC34A); // Light Green
      case 'neutral':
      case 'okay':
        return Color(0xFFFFEB3B); // Yellow
      case 'sad':
      case 'down':
        return Color(0xFFFF9800); // Orange
      case 'angry':
      case 'terrible':
        return Color(0xFFF44336); // Red
      case 'anxious':
        return Color(0xFF9C27B0); // Purple
      case 'stressed':
        return Color(0xFF795548); // Brown
      default:
        return Color(0xFF9E9E9E); // Grey
    }
  }
}
