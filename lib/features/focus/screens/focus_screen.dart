import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../app_theme.dart';

class FocusScreen extends StatefulWidget {
  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  // Session State
  bool _isSessionActive = false;
  int _sessionDuration = 300; // 5 minutes default
  int _remainingSeconds = 0;
  Timer? _sessionTimer;
  Timer? _exerciseTimer;

  // Current Exercise State
  String _currentExercise = '';
  String _currentInstruction = '';
  int _currentStep = 0;
  int _exerciseSteps = 0;
  bool _isExerciseActive = false;

  // Selected Mode
  String _selectedMode = 'Mindfulness';
  String _selectedAmbiance = 'Forest';

  // Focus Exercises Data
  final Map<String, List<Map<String, dynamic>>> _focusExercises = {
    'Mindfulness': [
      {
        'title': 'Body Scan Meditation',
        'steps': [
          'Close your eyes and take three deep breaths',
          'Start by focusing on the top of your head',
          'Slowly move your attention down to your forehead',
          'Notice any tension in your jaw and neck',
          'Feel your shoulders and let them relax',
          'Bring awareness to your chest and breathing',
          'Focus on your arms, hands, and fingers',
          'Move attention to your stomach and back',
          'Notice your hips and pelvis',
          'Feel your thighs and knees',
          'Bring awareness to your calves and feet',
          'Take a moment to feel your whole body',
        ],
        'stepDuration': 25,
        'icon': Icons.accessibility_new,
        'color': Colors.green,
      },
      {
        'title': '5-4-3-2-1 Grounding',
        'steps': [
          'Find a comfortable position and breathe naturally',
          'Notice 5 things you can see around you',
          'Identify 4 things you can touch or feel',
          'Listen for 3 different sounds in your environment',
          'Notice 2 things you can smell',
          'Identify 1 thing you can taste',
          'Take three deep breaths and return to awareness',
        ],
        'stepDuration': 30,
        'icon': Icons.visibility,
        'color': Colors.blue,
      },
      {
        'title': 'Loving-Kindness Meditation',
        'steps': [
          'Sit comfortably and close your eyes',
          'Think of yourself with kindness and compassion',
          'Silently repeat: "May I be happy, may I be peaceful"',
          'Bring to mind someone you love',
          'Send them loving thoughts: "May you be happy"',
          'Think of a neutral person in your life',
          'Extend the same wishes to them',
          'Consider someone difficult in your life',
          'Try to send them loving-kindness too',
          'Extend these wishes to all living beings',
        ],
        'stepDuration': 30,
        'icon': Icons.favorite,
        'color': Colors.pink,
      },
    ],
    'Focus Training': [
      {
        'title': 'Candle Flame Meditation',
        'steps': [
          'Light a candle and place it 3 feet away',
          'Sit comfortably and gaze at the flame',
          'Focus completely on the dancing flame',
          'When your mind wanders, gently return focus',
          'Notice the colors and movement of the flame',
          'Breathe naturally while maintaining focus',
          'If thoughts arise, acknowledge and release them',
          'Continue focusing on the flame\'s center',
        ],
        'stepDuration': 45,
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'Counting Meditation',
        'steps': [
          'Sit in a comfortable position',
          'Begin counting your breaths from 1 to 10',
          'Count "one" on the exhale of your first breath',
          'Continue to "ten", then start over at "one"',
          'If you lose count, simply start again at "one"',
          'Focus only on the counting and breathing',
          'Notice when your mind wanders and return to counting',
          'Maintain this practice with patience',
        ],
        'stepDuration': 30,
        'icon': Icons.format_list_numbered,
        'color': Colors.indigo,
      },
      {
        'title': 'Single-Point Focus',
        'steps': [
          'Choose a small object to focus on',
          'Place it at eye level about 2 feet away',
          'Gaze softly at the object without straining',
          'Notice every detail: shape, color, texture',
          'When thoughts arise, return attention to the object',
          'Maintain steady, relaxed focus',
          'Breathe naturally while observing',
          'End by closing your eyes for 30 seconds',
        ],
        'stepDuration': 40,
        'icon': Icons.center_focus_strong,
        'color': Colors.purple,
      },
    ],
    'Stress Relief': [
      {
        'title': 'Progressive Muscle Relaxation',
        'steps': [
          'Lie down comfortably and close your eyes',
          'Tense your feet and toes for 5 seconds, then relax',
          'Tense your calves and shins, then release',
          'Tense your thighs and glutes, then relax',
          'Tense your hands and forearms, then release',
          'Tense your upper arms and shoulders, then relax',
          'Tense your chest and back, then release',
          'Tense your face and scalp, then relax completely',
          'Lie still and enjoy the feeling of total relaxation',
        ],
        'stepDuration': 35,
        'icon': Icons.self_improvement,
        'color': Colors.teal,
      },
      {
        'title': 'Breath of Relief',
        'steps': [
          'Sit comfortably with your back straight',
          'Inhale slowly through your nose for 4 counts',
          'Hold your breath for 4 counts',
          'Exhale slowly through your mouth for 8 counts',
          'Repeat this pattern 4 times',
          'Now breathe naturally and notice the calm',
          'If tension returns, repeat the cycle',
        ],
        'stepDuration': 25,
        'icon': Icons.air,
        'color': Colors.cyan,
      },
      {
        'title': 'Worry Time Technique',
        'steps': [
          'Acknowledge that you have worries',
          'Write down your current worries mentally',
          'For each worry, ask: "Can I control this?"',
          'For controllable worries, plan one small action',
          'For uncontrollable worries, practice letting go',
          'Imagine placing worries in a mental container',
          'Set them aside for now, you can return later',
          'Focus on the present moment instead',
        ],
        'stepDuration': 40,
        'icon': Icons.psychology,
        'color': Colors.amber,
      },
    ],
    'Energy Boost': [
      {
        'title': 'Energizing Breath',
        'steps': [
          'Sit up straight with feet flat on the floor',
          'Place one hand on chest, one on belly',
          'Breathe in quickly through nose (belly rises)',
          'Breathe out quickly through mouth (belly falls)',
          'Repeat this rapid breathing for 30 seconds',
          'Return to normal breathing and notice energy',
          'Repeat if you need more invigoration',
        ],
        'stepDuration': 20,
        'icon': Icons.flash_on,
        'color': Colors.yellow,
      },
      {
        'title': 'Mental Clarity Visualization',
        'steps': [
          'Sit comfortably and close your eyes',
          'Imagine a bright, clear mountain lake',
          'See the water perfectly still and transparent',
          'This lake represents your clear mind',
          'Watch as any mental clouds dissolve away',
          'Feel the clarity and focus entering your mind',
          'Carry this clear, focused feeling with you',
        ],
        'stepDuration': 35,
        'icon': Icons.wb_sunny,
        'color': Colors.lightBlue,
      },
    ],
  };

  final List<String> _durations = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
  ];
  final List<String> _ambianceOptions = [
    'Forest',
    'Ocean',
    'Rain',
    'Silence',
    'Bells',
  ];

  // Statistics
  int _sessionsToday = 0;
  int _totalMinutes = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_progressController);

    // Start ambient animations
    _waveController.repeat();
    _pulseController.repeat(reverse: true);

    _remainingSeconds = _sessionDuration;
    _selectRandomExercise();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  void _selectRandomExercise() {
    final exercises = _focusExercises[_selectedMode] ?? [];
    if (exercises.isNotEmpty) {
      final randomExercise = exercises[math.Random().nextInt(exercises.length)];
      setState(() {
        _currentExercise = randomExercise['title'];
        _exerciseSteps = randomExercise['steps'].length;
        _currentStep = 0;
        _currentInstruction = randomExercise['steps'][0];
      });
    }
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _remainingSeconds = _sessionDuration;
    });

    // Start session timer
    _sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _progressController.value =
              1 - (_remainingSeconds / _sessionDuration);
        } else {
          _completeSession();
        }
      });
    });

    _startExercise();
    HapticFeedback.lightImpact();
  }

  void _startExercise() {
    setState(() {
      _isExerciseActive = true;
      _currentStep = 0;
    });

    _updateExerciseStep();
  }

  void _updateExerciseStep() {
    if (!_isSessionActive || _currentStep >= _exerciseSteps) return;

    final exercises = _focusExercises[_selectedMode] ?? [];
    final currentExerciseData = exercises.firstWhere(
      (e) => e['title'] == _currentExercise,
      orElse: () => exercises.first,
    );

    setState(() {
      _currentInstruction = currentExerciseData['steps'][_currentStep];
    });

    _exerciseTimer?.cancel();
    _exerciseTimer = Timer(
      Duration(seconds: currentExerciseData['stepDuration']),
      () {
        if (_isSessionActive) {
          setState(() {
            _currentStep++;
          });

          if (_currentStep < _exerciseSteps) {
            _updateExerciseStep();
          } else {
            // Move to next exercise or repeat
            _selectRandomExercise();
            _startExercise();
          }

          HapticFeedback.selectionClick();
        }
      },
    );
  }

  void _stopSession() {
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();

    setState(() {
      _isSessionActive = false;
      _isExerciseActive = false;
      _remainingSeconds = _sessionDuration;
    });

    _progressController.reset();
    HapticFeedback.mediumImpact();
  }

  void _completeSession() {
    _sessionTimer?.cancel();
    _exerciseTimer?.cancel();

    setState(() {
      _isSessionActive = false;
      _isExerciseActive = false;
      _sessionsToday++;
      _totalMinutes += _sessionDuration ~/ 60;
      _currentStreak++;
    });

    _progressController.value = 1;
    _showCompletionDialog();
    HapticFeedback.heavyImpact();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              SizedBox(height: 24),
              Text(
                'Session Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Well done! You\'ve completed a ${_sessionDuration ~/ 60}-minute $_selectedMode session.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompletionStat('Sessions', _sessionsToday.toString()),
                  _buildCompletionStat('Minutes', _totalMinutes.toString()),
                  _buildCompletionStat('Streak', _currentStreak.toString()),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSession();
            },
            child: Text(
              'Continue',
              style: TextStyle(color: Colors.cyan, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  void _resetSession() {
    setState(() {
      _remainingSeconds = _sessionDuration;
    });
    _progressController.reset();
    _selectRandomExercise();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
              Color(0xFF0D1B2A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModeSelector(),
                      SizedBox(height: 30),
                      _buildMainVisualization(),
                      SizedBox(height: 30),
                      _buildCurrentExercise(),
                      SizedBox(height: 30),
                      _buildSessionControls(),
                      SizedBox(height: 30),
                      _buildStatsSection(),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mind Wellness',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Focus & Mental Clarity',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.psychology_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
              onPressed: () => _showInfoDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: _focusExercises.keys.map((mode) {
          final isSelected = _selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isSessionActive) {
                  setState(() {
                    _selectedMode = mode;
                  });
                  _selectRandomExercise();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.cyan.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainVisualization() {
    return Container(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background waves
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_waveAnimation.value, _isSessionActive),
                size: Size(250, 250),
              );
            },
          ),

          // Progress ring
          if (_isSessionActive)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ProgressRingPainter(_progressAnimation.value),
                  size: Size(200, 200),
                );
              },
            ),

          // Center visualization
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isSessionActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.4),
                        Colors.blue.withOpacity(0.6),
                        Colors.indigo.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSessionActive ? Icons.self_improvement : Icons.spa,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    final exercises = _focusExercises[_selectedMode] ?? [];
    final currentExerciseData = exercises.firstWhere(
      (e) => e['title'] == _currentExercise,
      orElse: () => exercises.isNotEmpty ? exercises.first : {},
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (currentExerciseData['color'] as Color? ?? Colors.cyan)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  currentExerciseData['icon'] ?? Icons.spa,
                  color: currentExerciseData['color'] ?? Colors.cyan,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentExercise,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isSessionActive)
                      Text(
                        'Step ${_currentStep + 1} of $_exerciseSteps',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _currentInstruction,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_isSessionActive) ...[
            SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _selectRandomExercise,
                icon: Icon(Icons.refresh, color: Colors.cyan, size: 20),
                label: Text(
                  'Try Different Exercise',
                  style: TextStyle(color: Colors.cyan),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionControls() {
    return Column(
      children: [
        // Duration selector
        if (!_isSessionActive) ...[
          Text(
            'Session Duration',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _durations.map((duration) {
              final minutes = int.parse(duration.split(' ')[0]);
              final isSelected = _sessionDuration == minutes * 60;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _sessionDuration = minutes * 60;
                    _remainingSeconds = _sessionDuration;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.cyan.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? Colors.cyan
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
        ],

        // Main control button
        GestureDetector(
          onTap: _isSessionActive ? _stopSession : _startSession,
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSessionActive
                    ? [
                        Colors.red.withOpacity(0.7),
                        Colors.pink.withOpacity(0.7),
                      ]
                    : [
                        Colors.cyan.withOpacity(0.7),
                        Colors.blue.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (_isSessionActive ? Colors.red : Colors.cyan)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSessionActive ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  _isSessionActive ? 'Stop Session' : 'Start Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Sessions',
                _sessionsToday.toString(),
                Icons.psychology,
              ),
              _buildStatItem('Minutes', _totalMinutes.toString(), Icons.timer),
              _buildStatItem(
                'Streak',
                '${_currentStreak} days',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.cyan, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mind Wellness Guide',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                'Mindfulness',
                'Focus on present moment awareness and meditation practices',
              ),
              _buildInfoSection(
                'Focus Training',
                'Exercises to improve concentration and mental clarity',
              ),
              _buildInfoSection(
                'Stress Relief',
                'Techniques to reduce anxiety and promote relaxation',
              ),
              _buildInfoSection(
                'Energy Boost',
                'Methods to increase mental energy and alertness',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painters
class WavePainter extends CustomPainter {
  final double animationValue;
  final bool isActive;

  WavePainter(this.animationValue, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final radius =
          maxRadius * (0.3 + i * 0.2) +
          (isActive ? math.sin(animationValue + i * 0.5) * 10 : 0);
      final opacity = isActive ? 0.3 - i * 0.1 : 0.1;

      paint.color = Colors.cyan.withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProgressRingPainter extends CustomPainter {
  final double progress;

  ProgressRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background ring
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
