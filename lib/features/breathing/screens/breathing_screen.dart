import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';
import '../../achievements/providers/achievements_provider.dart';
import 'dart:math' as math;

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _particleController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _particleAnimation;

  int _currentCount = 0;
  bool _isBreathing = false;
  int _completedCycles = 0;
  static const int CYCLES_FOR_ACHIEVEMENT =
      3; // Number of cycles needed for achievement

  @override
  void initState() {
    super.initState();

    // Main breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 23), // Total cycle duration
    );

    // Ripple effect animation
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Start particle animation
    _particleController.repeat();

    _breathingController.addListener(_updateBreathingPhase);
  }

  void _updateBreathingPhase() {
    if (!_isBreathing) return;

    final progress = _breathingController.value;
    final totalDuration = _breathingPattern.values.reduce((a, b) => a + b);

    double cumulativeTime = 0;
    BreathingPhase newPhase = BreathingPhase.inhale;
    int count = 0;

    for (final phase in BreathingPhase.values) {
      final phaseDuration = _breathingPattern[phase]! / totalDuration;
      if (progress <= cumulativeTime + phaseDuration) {
        newPhase = phase;
        final phaseProgress = (progress - cumulativeTime) / phaseDuration;
        count = (_breathingPattern[phase]! * phaseProgress).ceil();
        count = count.clamp(1, _breathingPattern[phase]!);
        break;
      }
      cumulativeTime += phaseDuration;
    }

    if (_currentPhase != newPhase || _currentCount != count) {
      setState(() {
        _currentPhase = newPhase;
        _currentCount = count;
      });

      // Track completed cycles
      if (_currentPhase == BreathingPhase.inhale && _currentCount == 1) {
        _completedCycles++;

        // Check for achievement after completing required cycles
        if (_completedCycles >= CYCLES_FOR_ACHIEVEMENT) {
          _checkAndAwardAchievement();
        }
      }

      // Trigger ripple effect on phase change
      if (_currentPhase != newPhase) {
        _rippleController.reset();
        _rippleController.forward();
      }
    }
  }

  void _checkAndAwardAchievement() {
    final achievementsProvider = context.read<AchievementsProvider>();
    achievementsProvider.checkAndAwardAchievements('breathing');
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _currentPhase = BreathingPhase.inhale;
      _currentCount = 1;
      _completedCycles = 0; // Reset cycles when starting new session
    });
    _breathingController.repeat();
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rippleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<BreathingProvider>(
      builder: (context, breathingProvider, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF24243e),
                  Color(0xFF302B63),
                  Color(0xFF0F0C29),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAppBar(theme),
                        _buildBreathingVisualization(),
                        SizedBox(height: 60),
                        _buildPhaseIndicator(theme),
                        SizedBox(height: 40),
                        _buildControlButton(theme),
                        SizedBox(height: 60),
                        _buildBreathingPattern(theme),
                        SizedBox(height: 24), // Bottom padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Breathing Space',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
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
                size: 24,
              ),
              onPressed: () {
                _showBreathingInfo(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingVisualization() {
    return Container(
      height: 320,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer particles
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleAnimation.value),
                size: Size(320, 320),
              );
            },
          ),

          // Ripple effects
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: RipplePainter(_rippleAnimation.value, _isBreathing),
                size: Size(320, 320),
              );
            },
          ),

          // Main breathing circle
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              double scale = 1.0;
              Color primaryColor = Colors.cyan;
              Color secondaryColor = Colors.purple;

              if (_isBreathing) {
                switch (_currentPhase) {
                  case BreathingPhase.inhale:
                    scale = 0.7 + (0.6 * _breathingAnimation.value);
                    primaryColor = Colors.cyan;
                    secondaryColor = Colors.blue;
                    break;
                  case BreathingPhase.holdIn:
                    scale = 1.3;
                    primaryColor = Colors.green;
                    secondaryColor = Colors.teal;
                    break;
                  case BreathingPhase.exhale:
                    scale = 1.3 - (0.6 * _breathingAnimation.value);
                    primaryColor = Colors.purple;
                    secondaryColor = Colors.pink;
                    break;
                  case BreathingPhase.holdOut:
                    scale = 0.7;
                    primaryColor = Colors.indigo;
                    secondaryColor = Colors.deepPurple;
                    break;
                }
              }

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.3),
                        secondaryColor.withOpacity(0.6),
                        primaryColor.withOpacity(0.1),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withOpacity(0.6),
                          secondaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getPhaseIcon(),
                        color: Colors.white.withOpacity(0.9),
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(ThemeData theme) {
    return Column(
      children: [
        Text(
          _getPhaseText(),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        if (_isBreathing)
          Text(
            '$_currentCount',
            style: theme.textTheme.displayMedium?.copyWith(
              color: _getPhaseColor(),
              fontWeight: FontWeight.w200,
              fontSize: 72,
            ),
          ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Text(
            _getPhaseDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isBreathing ? _stopBreathing : _startBreathing,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isBreathing
                ? [Colors.red.withOpacity(0.7), Colors.pink.withOpacity(0.7)]
                : [Colors.cyan.withOpacity(0.7), Colors.blue.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isBreathing ? Colors.red : Colors.cyan).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isBreathing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildBreathingPattern(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Breathing Pattern (4-7-8)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPatternItem('Inhale', '4s', Colors.cyan, theme),
              _buildPatternItem('Hold', '7s', Colors.green, theme),
              _buildPatternItem('Exhale', '8s', Colors.purple, theme),
              _buildPatternItem('Hold', '4s', Colors.indigo, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(
    String label,
    String duration,
    Color color,
    ThemeData theme,
  ) {
    final isActive =
        (_currentPhase == BreathingPhase.inhale && label == 'Inhale') ||
        (_currentPhase == BreathingPhase.holdIn &&
            label == 'Hold' &&
            duration == '7s') ||
        (_currentPhase == BreathingPhase.exhale && label == 'Exhale') ||
        (_currentPhase == BreathingPhase.holdOut &&
            label == 'Hold' &&
            duration == '4s');

    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive && _isBreathing
                ? color
                : Colors.white.withOpacity(0.3),
            boxShadow: isActive && _isBreathing
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        Text(
          duration,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getPhaseText() {
    if (!_isBreathing) return 'Ready to Begin';

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.holdIn:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.holdOut:
        return 'Hold';
    }
  }

  String _getPhaseDescription() {
    if (!_isBreathing)
      return 'Tap the button below to start your breathing session';

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Slowly fill your lungs with air';
      case BreathingPhase.holdIn:
        return 'Keep the air in your lungs';
      case BreathingPhase.exhale:
        return 'Slowly release the air from your lungs';
      case BreathingPhase.holdOut:
        return 'Rest before the next breath';
    }
  }

  IconData _getPhaseIcon() {
    if (!_isBreathing) return Icons.air;

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return Icons.keyboard_arrow_up;
      case BreathingPhase.holdIn:
        return Icons.pause;
      case BreathingPhase.exhale:
        return Icons.keyboard_arrow_down;
      case BreathingPhase.holdOut:
        return Icons.pause;
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return Colors.cyan;
      case BreathingPhase.holdIn:
        return Colors.green;
      case BreathingPhase.exhale:
        return Colors.purple;
      case BreathingPhase.holdOut:
        return Colors.indigo;
    }
  }

  void _showBreathingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About 4-7-8 Breathing',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        content: Text(
          'This technique helps reduce anxiety and promote relaxation:\n\n'
          '• Inhale for 4 counts\n'
          '• Hold for 7 counts\n'
          '• Exhale for 8 counts\n'
          '• Hold for 4 counts\n\n'
          'Practice regularly for best results.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
}

// Custom painter for floating particles
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (math.pi / 180) + (animationValue * 2 * math.pi);
      final radius = 120 + (20 * math.sin(animationValue * 2 * math.pi + i));
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final particleSize = 2 + (2 * math.sin(animationValue * 4 * math.pi + i));
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for ripple effects
class RipplePainter extends CustomPainter {
  final double animationValue;
  final bool isBreathing;

  RipplePainter(this.animationValue, this.isBreathing);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isBreathing) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final radius = (animationValue + i * 0.3) * 150;
      final opacity = (1 - animationValue - i * 0.3).clamp(0.0, 1.0);

      paint.color = Colors.cyan.withOpacity(opacity * 0.5);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Breathing phases
enum BreathingPhase { inhale, holdIn, exhale, holdOut }

BreathingPhase _currentPhase = BreathingPhase.inhale;

// Breathing pattern (4-7-8 technique by default)
final Map<BreathingPhase, int> _breathingPattern = {
  BreathingPhase.inhale: 4,
  BreathingPhase.holdIn: 7,
  BreathingPhase.exhale: 8,
  BreathingPhase.holdOut: 4,
};
