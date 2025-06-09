import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';

class CreateJournalScreen extends StatefulWidget {
  final JournalEntry? editingEntry;

  const CreateJournalScreen({Key? key, this.editingEntry}) : super(key: key);

  @override
  _CreateJournalScreenState createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Neutral';
  List<String> _gratitudeItems = [];
  bool _isRecording = false;
  String _dailyPrompt = "";

  @override
  void initState() {
    super.initState();
    _loadDailyPrompt();
    if (widget.editingEntry != null) {
      _titleController.text = widget.editingEntry!.title;
      _contentController.text = widget.editingEntry!.content;
      _selectedMood = widget.editingEntry!.mood;
      _gratitudeItems = List.from(widget.editingEntry!.gratitudeItems);
    }
  }

  void _loadDailyPrompt() {
    final prompts = [
      "What made you smile today?",
      "What's one thing you're grateful for?",
      "What's your biggest achievement today?",
      "What's something you're looking forward to?",
      "What's a challenge you overcame today?",
    ];
    final random = DateTime.now().day % prompts.length;
    _dailyPrompt = prompts[random];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F7FA), Color(0xFFE8ECF4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: widget.editingEntry != null
                    ? 'Edit Journal'
                    : 'New Journal',
                showBackButton: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.white),
                    onPressed: _saveEntry,
                  ),
                ],
                subtitle: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Express yourself freely',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyPrompt(),
                      SizedBox(height: 20),
                      _buildMoodSelection(),
                      SizedBox(height: 20),
                      _buildJournalForm(),
                      SizedBox(height: 20),
                      _buildGratitudeLog(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyPrompt() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'Daily Prompt',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            _dailyPrompt,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    final moodProvider = context.watch<MoodProvider>();
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Icon(Icons.mood, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMood,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: TextStyle(color: AppColors.textPrimary),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: moodProvider.moodEmojis.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Text(entry.value, style: TextStyle(fontSize: 20)),
                        SizedBox(width: 12),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMood = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Journal Entry',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                  // TODO: Implement voice-to-text
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          TextField(
            controller: _titleController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.surfaceVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.surfaceVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _contentController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Write your thoughts...',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.surfaceVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.surfaceVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            maxLines: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeLog() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'Gratitude Log',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'What are you grateful for today?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          SizedBox(height: 15),
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Gratitude item ${index + 1}',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.favorite, color: AppColors.accent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.surfaceVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.surfaceVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                onChanged: (value) {
                  if (index < _gratitudeItems.length) {
                    _gratitudeItems[index] = value;
                  } else {
                    _gratitudeItems.add(value);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in title and content'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );
      final now = DateTime.now();

      if (widget.editingEntry != null && widget.editingEntry!.id.isNotEmpty) {
        final updatedEntry = widget.editingEntry!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          mood: _selectedMood,
          gratitudeItems: _gratitudeItems,
          updatedAt: now,
        );
        await journalProvider.updateEntry(
          widget.editingEntry!.id,
          updatedEntry,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journal entry updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        final entry = JournalEntry(
          id: '', // Will be set by Firestore
          title: _titleController.text,
          content: _contentController.text,
          mood: _selectedMood,
          gratitudeItems: _gratitudeItems,
          createdAt: now,
        );
        await journalProvider.addEntry(entry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journal entry saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving journal entry: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
