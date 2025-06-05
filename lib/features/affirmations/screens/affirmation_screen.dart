import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/affirmation_provider.dart';

class AffirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final affirmationProvider = context.watch<AffirmationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Affirmation'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Daily Affirmation Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 48,
                          color: Colors.purple.shade200,
                        ),
                        SizedBox(height: 16),
                        Text(
                          affirmationProvider.dailyAffirmation?.text ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              affirmationProvider.refreshDailyAffirmation(),
                          icon: Icon(Icons.refresh),
                          label: Text('New Affirmation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Category Selection
                Text(
                  'Affirmation Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text('All'),
                      selected: affirmationProvider.selectedCategory == null,
                      onSelected: (selected) {
                        affirmationProvider.setCategory(null);
                      },
                      backgroundColor: Colors.purple.shade50,
                      selectedColor: Colors.purple.shade200,
                    ),
                    ...affirmationProvider.categories.map(
                      (category) => FilterChip(
                        label: Text(
                          category.replaceAll('-', ' ').toUpperCase(),
                        ),
                        selected:
                            affirmationProvider.selectedCategory == category,
                        onSelected: (selected) {
                          affirmationProvider.setCategory(
                            selected ? category : null,
                          );
                        },
                        backgroundColor: Colors.purple.shade50,
                        selectedColor: Colors.purple.shade200,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Random Affirmation Button
                ElevatedButton.icon(
                  onPressed: () {
                    final affirmation = affirmationProvider
                        .getRandomAffirmation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(affirmation.text),
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(Icons.auto_awesome),
                  label: Text('Get Random Affirmation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
