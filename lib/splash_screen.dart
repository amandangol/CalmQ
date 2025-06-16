import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SerenaraSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SerenaraSplashScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<SerenaraSplashScreen> createState() => _SerenaraSplashScreenState();
}

class _SerenaraSplashScreenState extends State<SerenaraSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _breathingController;
  late AnimationController _progressController;
  late AnimationController _rippleController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start floating particles immediately
    _floatingController.repeat();

    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _breathingController.repeat(reverse: true);
    _rippleController.repeat();

    await Future.delayed(const Duration(milliseconds: 1000));
    _progressController.forward();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    // Check auth state and complete
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoading) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _breathingController.dispose();
    _progressController.dispose();
    _rippleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.15),
              AppColors.background,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating wellness particles
            ...List.generate(8, (index) => _buildWellnessParticle(index)),

            // Breathing meditation circles
            _buildBreathingCircles(),

            // Ripple effect
            _buildRippleEffect(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and app name
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Column(
                                children: [
                                  // Logo container with breathing effect
                                  AnimatedBuilder(
                                    animation: _breathingAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _breathingAnimation.value,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.primary.withOpacity(
                                                  0.3,
                                                ),
                                                AppColors.secondary.withOpacity(
                                                  0.4,
                                                ),
                                                AppColors.success.withOpacity(
                                                  0.3,
                                                ),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.2),
                                                blurRadius: 30,
                                                spreadRadius: 10,
                                              ),
                                              BoxShadow(
                                                color: AppColors.secondary
                                                    .withOpacity(0.15),
                                                blurRadius: 50,
                                                spreadRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.surface
                                                  .withOpacity(0.9),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.self_improvement_outlined,
                                              size: 45,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 32),

                                  // App name with wellness gradient
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                        AppColors.success,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'Serenara',
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                        letterSpacing: 3,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tagline with breathing animation
                                  AnimatedBuilder(
                                    animation: _breathingAnimation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity:
                                            0.5 +
                                            (_breathingAnimation.value - 0.8) *
                                                1.25,
                                        child: Text(
                                          'Your Mind Wellness Companion',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 8),

                                  // Wellness subtitle
                                  Text(
                                    'Breathe • Relax • Grow',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Animated Loading Section
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _progressAnimation,
                        child: Column(
                          children: [
                            // Animated wellness icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final delay = index * 0.2;
                                final progress =
                                    (_progressAnimation.value - delay).clamp(
                                      0.0,
                                      1.0,
                                    );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Transform.scale(
                                    scale: 0.8 + (0.2 * progress),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                          AppColors.success,
                                        ][index].withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        [
                                          Icons.self_improvement_outlined,
                                          Icons.psychology_outlined,
                                          Icons.spa_outlined,
                                        ][index],
                                        color: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                          AppColors.success,
                                        ][index],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 32),

                            // Animated loading dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final delay = index * 0.2;
                                final progress =
                                    (_progressAnimation.value - delay).clamp(
                                      0.0,
                                      1.0,
                                    );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 8 + (4 * progress),
                                    height: 8 + (4 * progress),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(
                                        0.3 + (0.7 * progress),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessParticle(int index) {
    final colors = [
      AppColors.primary.withOpacity(0.1),
      AppColors.secondary.withOpacity(0.1),
      AppColors.success.withOpacity(0.1),
      AppColors.accent.withOpacity(0.1),
      AppColors.info.withOpacity(0.1),
    ];

    final sizes = [40.0, 60.0, 35.0, 55.0, 25.0, 45.0, 30.0, 50.0];
    final leftPositions = [0.1, 0.85, 0.15, 0.7, 0.25, 0.8, 0.05, 0.9];
    final topPositions = [0.15, 0.25, 0.75, 0.65, 0.85, 0.35, 0.55, 0.45];

    return Positioned(
      left: MediaQuery.of(context).size.width * leftPositions[index],
      top: MediaQuery.of(context).size.height * topPositions[index],
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              10 * math.sin(_floatingAnimation.value * 2 * math.pi + index),
              15 *
                  math.cos(
                    _floatingAnimation.value * 2 * math.pi + index * 0.5,
                  ),
            ),
            child: Container(
              width: sizes[index],
              height: sizes[index],
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index % colors.length],
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length],
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreathingCircles() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildBreathingCircle(200 * _breathingAnimation.value, 0.02),
              _buildBreathingCircle(300 * _breathingAnimation.value, 0.015),
              _buildBreathingCircle(400 * _breathingAnimation.value, 0.01),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreathingCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(opacity),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.3;
              final progress = (_rippleAnimation.value - delay).clamp(0.0, 1.0);

              return Container(
                width: 300 * progress,
                height: 300 * progress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(
                      (1 - progress) * 0.1,
                    ),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
