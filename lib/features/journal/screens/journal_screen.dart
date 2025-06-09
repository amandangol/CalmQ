import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../mood/providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Neutral';
  List<String> _gratitudeItems = [];
  JournalEntry? _editingEntry;
  bool _isRecording = false;
  String _dailyPrompt = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDailyPrompt();
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
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showSnackBar('Please fill in title and content', isError: true);
      return;
    }

    final journalProvider = Provider.of<JournalProvider>(
      context,
      listen: false,
    );
    final now = DateTime.now();

    if (_editingEntry != null) {
      final updatedEntry = _editingEntry!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood,
        gratitudeItems: _gratitudeItems,
        updatedAt: now,
      );
      journalProvider.updateEntry(_editingEntry!.id, updatedEntry);
      _showSnackBar('Journal entry updated successfully!');
    } else {
      final entry = JournalEntry(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood,
        gratitudeItems: _gratitudeItems,
        createdAt: now,
      );
      journalProvider.addEntry(entry);
      _showSnackBar('Journal entry saved successfully!');
    }
    _clearForm();
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedMood = 'Neutral';
      _gratitudeItems.clear();
      _editingEntry = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildNewEntryTab(), _buildEntriesTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'My Journal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white70),
            onPressed: () {
              // TODO: Show calendar view
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Color(0xFFE94560),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(text: 'Write'),
          Tab(text: 'Entries'),
        ],
      ),
    );
  }

  Widget _buildNewEntryTab() {
    return SingleChildScrollView(
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
          SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildDailyPrompt() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFFFD700)),
              SizedBox(width: 10),
              Text(
                'Daily Prompt',
                style: TextStyle(
                  color: Colors.white,
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
              color: Colors.white.withOpacity(0.9),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mood, color: Color(0xFFFFD700)),
              SizedBox(width: 10),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.white,
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMood,
                isExpanded: true,
                dropdownColor: Color(0xFF16213E),
                style: TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Color(0xFFE94560)),
              SizedBox(width: 10),
              Text(
                'Journal Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.white70,
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
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color(0xFFE94560)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _contentController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Write your thoughts...',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color(0xFFE94560)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Color(0xFFE94560)),
              SizedBox(width: 10),
              Text(
                'Gratitude Log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'What are you grateful for today?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 15),
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Gratitude item ${index + 1}',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.star, color: Color(0xFFFFD700)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFE94560)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE94560),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            SizedBox(width: 8),
            Text(
              'Save Entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesTab() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final entries = journalProvider.entries;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                SizedBox(height: 16),
                Text(
                  'No journal entries yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start writing to track your thoughts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return GestureDetector(
              onTap: () => _showEntryDetail(entry),
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          DateFormat('MMM d').format(entry.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEntryDetail(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF16213E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Text(
                    'Entry Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      _editEntry(entry);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteEntry(entry);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          DateFormat('MMMM d, y').format(entry.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE94560).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.mood,
                            style: TextStyle(
                              color: Color(0xFFE94560),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      entry.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    if (entry.gratitudeItems.isNotEmpty) ...[
                      SizedBox(height: 24),
                      Text(
                        'Gratitude Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...entry.gratitudeItems.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                item,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editEntry(JournalEntry entry) {
    setState(() {
      _editingEntry = entry;
      _titleController.text = entry.title;
      _contentController.text = entry.content;
      _selectedMood = entry.mood;
      _gratitudeItems = List.from(entry.gratitudeItems);
    });
    _tabController.animateTo(0);
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF16213E),
        title: Text('Delete Entry', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this entry?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<JournalProvider>(
                context,
                listen: false,
              ).deleteEntry(entry.id);
              Navigator.pop(context);
              _showSnackBar('Entry deleted successfully');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
