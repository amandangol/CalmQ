// import 'dart:io';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../models/journal_entry.dart';

// class JournalEntryCard extends StatelessWidget {
//   final JournalEntry entry;
//   final VoidCallback? onTap;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const JournalEntryCard({
//     Key? key,
//     required this.entry,
//     this.onTap,
//     this.onEdit,
//     this.onDelete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 0,
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//         side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(24),
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       entry.title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   if (entry.isPrivate)
//                     Icon(
//                       Icons.lock,
//                       size: 16,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   SizedBox(width: 8),
//                   PopupMenuButton(
//                     icon: Icon(
//                       Icons.more_vert,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         value: 'edit',
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.edit,
//                               size: 20,
//                               color: Color(0xFF667eea),
//                             ),
//                             SizedBox(width: 8),
//                             Text('Edit', style: TextStyle(color: Colors.white)),
//                           ],
//                         ),
//                       ),
//                       PopupMenuItem(
//                         value: 'delete',
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.delete,
//                               size: 20,
//                               color: Colors.red[300],
//                             ),
//                             SizedBox(width: 8),
//                             Text(
//                               'Delete',
//                               style: TextStyle(color: Colors.red[300]),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                     onSelected: (value) {
//                       if (value == 'edit' && onEdit != null) {
//                         onEdit!();
//                       } else if (value == 'delete' && onDelete != null) {
//                         onDelete!();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Text(
//                 DateFormat('EEEE, MMMM d, y • h:mm a').format(entry.createdAt),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 entry.content,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.9),
//                   height: 1.4,
//                 ),
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   _buildMoodChip(entry.mood),
//                   SizedBox(width: 8),
//                   _buildMetricChip(
//                     'Gratitude',
//                     entry.gratitudeLevel,
//                     Color(0xFF667eea),
//                   ),
//                   SizedBox(width: 8),
//                   _buildMetricChip(
//                     'Stress',
//                     entry.stressLevel,
//                     Color(0xFF764ba2),
//                   ),
//                 ],
//               ),
//               if (entry.tags.isNotEmpty) ...[
//                 SizedBox(height: 12),
//                 Wrap(
//                   spacing: 6,
//                   runSpacing: 6,
//                   children: entry.tags.take(3).map((tag) {
//                     return Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF667eea).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Color(0xFF667eea).withOpacity(0.3),
//                         ),
//                       ),
//                       child: Text(
//                         '#$tag',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF667eea),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMoodChip(String mood) {
//     final moodColors = {
//       'Terrible': Color(0xFF667eea),
//       'Bad': Color(0xFF764ba2),
//       'Okay': Color(0xFF667eea),
//       'Neutral': Color(0xFF764ba2),
//       'Good': Color(0xFF667eea),
//       'Great': Color(0xFF764ba2),
//       'Amazing': Color(0xFF667eea),
//     };

//     final moodEmojis = {
//       'Terrible': '😢',
//       'Bad': '😟',
//       'Okay': '😐',
//       'Neutral': '😊',
//       'Good': '😄',
//       'Great': '😁',
//       'Amazing': '🤩',
//     };

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: (moodColors[mood] ?? Color(0xFF667eea)).withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: (moodColors[mood] ?? Color(0xFF667eea)).withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(moodEmojis[mood] ?? '😊', style: TextStyle(fontSize: 14)),
//           SizedBox(width: 4),
//           Text(
//             mood,
//             style: TextStyle(
//               fontSize: 12,
//               color: moodColors[mood] ?? Color(0xFF667eea),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricChip(String label, int value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         '$label: $value',
//         style: TextStyle(
//           fontSize: 12,
//           color: color,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

// class MoodTrendChart extends StatelessWidget {
//   final List<Map<String, dynamic>> trendData;

//   const MoodTrendChart({Key? key, required this.trendData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
//       ),
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             horizontalInterval: 1,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: Colors.white.withOpacity(0.1),
//                 strokeWidth: 1,
//               );
//             },
//           ),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 40,
//                 interval: 1,
//                 getTitlesWidget: (value, meta) {
//                   final moodLabels = [
//                     '',
//                     'Terrible',
//                     'Bad',
//                     'Okay',
//                     'Neutral',
//                     'Good',
//                     'Great',
//                     'Amazing',
//                   ];
//                   if (value >= 1 && value <= 7) {
//                     return Text(
//                       moodLabels[value.toInt()],
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     );
//                   }
//                   return Text('');
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 30,
//                 getTitlesWidget: (value, meta) {
//                   if (value >= 0 && value < trendData.length) {
//                     final date = trendData[value.toInt()]['date'] as DateTime;
//                     return Text(
//                       '${date.day}/${date.month}',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     );
//                   }
//                   return Text('');
//                 },
//               ),
//             ),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           borderData: FlBorderData(show: false),
//           minX: 0,
//           maxX: (trendData.length - 1).toDouble(),
//           minY: 1,
//           maxY: 7,
//           lineBarsData: [
//             LineChartBarData(
//               spots: trendData.asMap().entries.map((entry) {
//                 return FlSpot(
//                   entry.key.toDouble(),
//                   entry.value['mood_score'].toDouble(),
//                 );
//               }).toList(),
//               isCurved: true,
//               color: Color(0xFF667eea),
//               barWidth: 3,
//               isStrokeCapRound: true,
//               dotData: FlDotData(
//                 show: true,
//                 getDotPainter: (spot, percent, barData, index) {
//                   return FlDotCirclePainter(
//                     radius: 4,
//                     color: Color(0xFF667eea),
//                     strokeWidth: 2,
//                     strokeColor: Colors.white,
//                   );
//                 },
//               ),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: Color(0xFF667eea).withOpacity(0.1),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class JournalPrompts {
//   static const List<String> dailyPrompts = [
//     "What are three things you're grateful for today?",
//     "Describe a moment that made you smile today.",
//     "What challenged you today and how did you overcome it?",
//     "How did you show kindness to yourself or others today?",
//     "What did you learn about yourself today?",
//     "What are you looking forward to tomorrow?",
//     "Describe your energy levels and what affected them.",
//     "What thoughts occupied your mind the most today?",
//     "How did you take care of your mental health today?",
//     "What would you tell your past self about today?",
//   ];

//   static const List<String> weeklyPrompts = [
//     "What patterns did I notice in my mood this week?",
//     "What was my biggest accomplishment this week?",
//     "How did I grow or change this week?",
//     "What relationships brought me joy this week?",
//     "What habits served me well this week?",
//     "What would I like to do differently next week?",
//     "How did I handle stress and challenges this week?",
//     "What moments of peace did I experience this week?",
//   ];

//   static const List<String> reflectionPrompts = [
//     "What does happiness mean to me right now?",
//     "How have I changed over the past month?",
//     "What values are most important to me?",
//     "What fears am I ready to face?",
//     "How do I want to be remembered?",
//     "What brings out the best in me?",
//     "What boundaries do I need to set?",
//     "How can I be more compassionate with myself?",
//   ];

//   static String getRandomDailyPrompt() {
//     return dailyPrompts[(DateTime.now().day) % dailyPrompts.length];
//   }

//   static String getRandomWeeklyPrompt() {
//     return weeklyPrompts[(DateTime.now().day ~/ 7) % weeklyPrompts.length];
//   }

//   static String getRandomReflectionPrompt() {
//     return reflectionPrompts[DateTime.now().millisecond %
//         reflectionPrompts.length];
//   }
// }

// class JournalExporter {
//   static Future<String> exportToText(List<JournalEntry> entries) async {
//     final buffer = StringBuffer();
//     buffer.writeln('My Journal Export');
//     buffer.writeln(
//       'Generated on: ${DateFormat('EEEE, MMMM d, y').format(DateTime.now())}',
//     );
//     buffer.writeln('Total Entries: ${entries.length}');
//     buffer.writeln('=' * 50);
//     buffer.writeln();

//     for (var entry in entries) {
//       buffer.writeln('Title: ${entry.title}');
//       buffer.writeln(
//         'Date: ${DateFormat('EEEE, MMMM d, y • h:mm a').format(entry.createdAt)}',
//       );
//       buffer.writeln('Mood: ${entry.mood}');
//       buffer.writeln('Gratitude Level: ${entry.gratitudeLevel}/10');
//       buffer.writeln('Stress Level: ${entry.stressLevel}/10');
//       if (entry.tags.isNotEmpty) {
//         buffer.writeln('Tags: ${entry.tags.join(', ')}');
//       }
//       buffer.writeln();
//       buffer.writeln(entry.content);
//       buffer.writeln();
//       buffer.writeln('-' * 30);
//       buffer.writeln();
//     }

//     return buffer.toString();
//   }

//   static Future<void> shareEntries(List<JournalEntry> entries) async {
//     final textContent = await exportToText(entries);

//     try {
//       final directory = await getTemporaryDirectory();
//       final file = File('${directory.path}/journal_export.txt');
//       await file.writeAsString(textContent);

//       await Share.shareXFiles([
//         XFile(file.path),
//       ], text: 'My Journal Export - ${entries.length} entries');
//     } catch (e) {
//       // Fallback to sharing just text
//       await Share.share(textContent, subject: 'My Journal Export');
//     }
//   }

//   static Future<Map<String, dynamic>> generateStats(
//     List<JournalEntry> entries,
//   ) async {
//     if (entries.isEmpty) {
//       return {'error': 'No entries to analyze'};
//     }

//     final totalEntries = entries.length;
//     final firstEntry = entries.last.createdAt;
//     final daysSinceFirst = DateTime.now().difference(firstEntry).inDays;

//     // Mood distribution
//     final moodCounts = <String, int>{};
//     var totalGratitude = 0;
//     var totalStress = 0;

//     for (var entry in entries) {
//       moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
//       totalGratitude += entry.gratitudeLevel;
//       totalStress += entry.stressLevel;
//     }

//     // Most used words (simplified)
//     final wordCounts = <String, int>{};
//     for (var entry in entries) {
//       final words = entry.content.toLowerCase().split(RegExp(r'\W+'));
//       for (var word in words) {
//         if (word.length > 3) {
//           wordCounts[word] = (wordCounts[word] ?? 0) + 1;
//         }
//       }
//     }

//     final topWords = wordCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return {
//       'total_entries': totalEntries,
//       'days_since_first': daysSinceFirst,
//       'entries_per_week': (totalEntries / (daysSinceFirst / 7)).toStringAsFixed(
//         1,
//       ),
//       'average_gratitude': (totalGratitude / totalEntries).toStringAsFixed(1),
//       'average_stress': (totalStress / totalEntries).toStringAsFixed(1),
//       'mood_distribution': moodCounts,
//       'top_words': topWords
//           .take(10)
//           .map((e) => '${e.key} (${e.value})')
//           .toList(),
//     };
//   }
// }
