import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'welcome_screen.dart';
import 'providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Use Future.microtask to avoid setState during build
      await Future.microtask(() async {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.loadData();
      });

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tennis Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  appProvider.isLoading
                      ? 'Loading your data...'
                      : 'Ready to serve!',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(300, 20),
                        painter: ProgressBarPainter(
                          progress: _progressAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  final double progress;
  static const int totalSegments = 15;
  static const double segmentWidth = 18;
  static const double segmentSpacing = 2;

  ProgressBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint =
        Paint()
          ..color = const Color(0xFFE63946)
          ..style = PaintingStyle.fill;

    final emptyPaint =
        Paint()
          ..color = Colors.grey.shade800
          ..style = PaintingStyle.fill;

    final filledSegments = (totalSegments * progress).floor();

    for (int i = 0; i < totalSegments; i++) {
      final x = i * (segmentWidth + segmentSpacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, segmentWidth, size.height),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, i < filledSegments ? fillPaint : emptyPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
