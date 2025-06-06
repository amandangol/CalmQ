import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../../../app_theme.dart';

class AllMoodsScreen extends StatefulWidget {
  @override
  _AllMoodsScreenState createState() => _AllMoodsScreenState();
}

class _AllMoodsScreenState extends State<AllMoodsScreen> {
  DateTime selectedMonth = DateTime.now();

  void _navigateMonth(bool forward) {
    setState(() {
      if (forward) {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      } else {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = context.watch<MoodProvider>();
    final entries = moodProvider.getEntriesForMonth(selectedMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood History',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textSecondary,
              size: 18,
            ),
            onPressed: () => _navigateMonth(false),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 18,
            ),
            onPressed: () => _navigateMonth(true),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mood,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No entries for ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _MoodEntryCard(entry: entry);
              },
            ),
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final imagePath =
        'assets/images/${moodProvider.getMoodImage(entry.mood)}.png';

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
          onTap: () => _showMoodDetails(context, entry),
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
                            Text(
                              DateFormat(
                                'EEEE, MMMM d • HH:mm',
                              ).format(entry.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _showOptions(context, entry),
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
                ],
              ],
            ),
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

  void _showOptions(BuildContext context, MoodEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-mood', arguments: entry);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete Entry'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MoodEntry entry) {
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
}

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
