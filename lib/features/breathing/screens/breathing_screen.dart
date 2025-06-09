import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';
import '../../web3/providers/web3_provider.dart';
import 'dart:math' as math;
import '../../../app_theme.dart';

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
  bool _isProviderInitialized = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProviderInitialized) {
      final web3Provider = context.read<Web3Provider>();

      // Initialize breathing provider if not already initialized
      if (!context.read<BreathingProvider>().isBreathing) {
        context.read<BreathingProvider>().startBreathing();
      }
      _isProviderInitialized = true;
    }
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
        context.read<BreathingProvider>().updateBreathProgress(
          _completedCycles / 3, // Using 3 as a default target
        );
      }

      // Trigger ripple effect on phase change
      if (_currentPhase != newPhase) {
        _rippleController.reset();
        _rippleController.forward();
      }
    }
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _currentPhase = BreathingPhase.inhale;
      _currentCount = 1;
      _completedCycles = 0;
    });
    context.read<BreathingProvider>().startBreathing();
    _breathingController.repeat();
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
    });
    context.read<BreathingProvider>().stopBreathing();
    context.read<BreathingProvider>().completeBreathingSession(context);
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
                  Color(0xFFF8F9FA),
                  Color(0xFFE9ECEF),
                  Color(0xFFF8F9FA),
                ],
                stops: [0.0, 0.5, 1.0],
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
                        SizedBox(height: 40),
                        _buildPhaseIndicator(theme),
                        SizedBox(height: 32),
                        _buildControlButton(theme),
                        SizedBox(height: 40),
                        _buildBreathingPattern(theme),
                        SizedBox(height: 24),
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Breathing Space',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.psychology_outlined,
                color: AppColors.primary,
                size: 20,
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
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer particles
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleAnimation.value),
                size: Size(280, 280),
              );
            },
          ),

          // Ripple effects
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: RipplePainter(_rippleAnimation.value, _isBreathing),
                size: Size(280, 280),
              );
            },
          ),

          // Main breathing circle
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              double scale = 1.0;
              Color primaryColor = AppColors.primary;
              Color secondaryColor = AppColors.secondary;

              if (_isBreathing) {
                switch (_currentPhase) {
                  case BreathingPhase.inhale:
                    scale = 0.7 + (0.6 * _breathingAnimation.value);
                    primaryColor = AppColors.primary;
                    secondaryColor = AppColors.secondary;
                    break;
                  case BreathingPhase.holdIn:
                    scale = 1.3;
                    primaryColor = AppColors.success;
                    secondaryColor = AppColors.success.withOpacity(0.7);
                    break;
                  case BreathingPhase.exhale:
                    scale = 1.3 - (0.6 * _breathingAnimation.value);
                    primaryColor = AppColors.accent;
                    secondaryColor = AppColors.accent.withOpacity(0.7);
                    break;
                  case BreathingPhase.holdOut:
                    scale = 0.7;
                    primaryColor = AppColors.primary.withOpacity(0.7);
                    secondaryColor = AppColors.secondary.withOpacity(0.7);
                    break;
                }
              }

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        secondaryColor.withOpacity(0.4),
                        primaryColor.withOpacity(0.1),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withOpacity(0.4),
                          secondaryColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getPhaseIcon(),
                        color: Colors.white,
                        size: 40,
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
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        if (_isBreathing)
          Text(
            '$_currentCount',
            style: theme.textTheme.displayMedium?.copyWith(
              color: _getPhaseColor(),
              fontWeight: FontWeight.w300,
              fontSize: 64,
            ),
          ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          child: Text(
            _getPhaseDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
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
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isBreathing
                ? [AppColors.error, AppColors.error.withOpacity(0.7)]
                : [AppColors.primary, AppColors.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isBreathing ? AppColors.error : AppColors.primary)
                  .withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          _isBreathing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildBreathingPattern(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
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
        children: [
          Text(
            'Breathing Pattern (4-7-8)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPatternItem('Inhale', '4s', AppColors.primary, theme),
              _buildPatternItem('Hold', '7s', AppColors.success, theme),
              _buildPatternItem('Exhale', '8s', AppColors.accent, theme),
              _buildPatternItem(
                'Hold',
                '4s',
                AppColors.primary.withOpacity(0.7),
                theme,
              ),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive && _isBreathing
                ? color
                : AppColors.textLight.withOpacity(0.3),
            boxShadow: isActive && _isBreathing
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          duration,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textLight,
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
        return AppColors.primary;
      case BreathingPhase.holdIn:
        return AppColors.success;
      case BreathingPhase.exhale:
        return AppColors.accent;
      case BreathingPhase.holdOut:
        return AppColors.primary.withOpacity(0.7);
    }
  }

  void _showBreathingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'About 4-7-8 Breathing',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This technique helps reduce anxiety and promote relaxation:\n\n'
          '• Inhale for 4 counts\n'
          '• Hold for 7 counts\n'
          '• Exhale for 8 counts\n'
          '• Hold for 4 counts\n\n'
          'Practice regularly for best results.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: AppColors.primary)),
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
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (math.pi / 180) + (animationValue * 2 * math.pi);
      final radius = 100 + (20 * math.sin(animationValue * 2 * math.pi + i));
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
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final radius = (animationValue + i * 0.3) * 130;
      final opacity = (1 - animationValue - i * 0.3).clamp(0.0, 1.0);

      paint.color = AppColors.primary.withOpacity(opacity * 0.3);
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
