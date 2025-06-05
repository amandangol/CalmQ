import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            context.read<BreathingProvider>().updateBreathProgress(
              _animation.value,
            );
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breathingProvider = context.watch<BreathingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Breathing Exercise'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 200 + (_animation.value * 100),
                        height: 200 + (_animation.value * 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            breathingProvider.isInhale
                                ? 'Breathe In'
                                : 'Breathe Out',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int duration
                            in breathingProvider.availableDurations)
                          ElevatedButton(
                            onPressed: () =>
                                breathingProvider.setDuration(duration),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  breathingProvider.selectedDuration == duration
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              foregroundColor:
                                  breathingProvider.selectedDuration == duration
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            child: Text('${duration}m'),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (String soundscape
                            in breathingProvider.availableSoundscapes)
                          ElevatedButton(
                            onPressed: () =>
                                breathingProvider.setSoundscape(soundscape),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  breathingProvider.selectedSoundscape ==
                                      soundscape
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              foregroundColor:
                                  breathingProvider.selectedSoundscape ==
                                      soundscape
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            child: Text(soundscape.capitalize()),
                          ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (breathingProvider.isBreathing) {
                          breathingProvider.stopBreathing();
                          _animationController.stop();
                        } else {
                          breathingProvider.startBreathing();
                          _animationController.forward();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        breathingProvider.isBreathing ? 'Stop' : 'Start',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
