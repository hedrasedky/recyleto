import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Rotation animation for logo
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Color animation
    _colorAnimation = ColorTween(
      begin: AppTheme.primaryGreen,
      end: AppTheme.primaryTeal,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _startAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _mainAnimationController.forward();

    // Start logo animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _logoAnimationController.repeat(reverse: true);
      }
    });

    // Start loading animation after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadingAnimationController.repeat(reverse: true);
      }
    });
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization with progress
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate loading steps
    await Future.delayed(const Duration(milliseconds: 800));

    // Final delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      final authProvider = context.read<AuthProvider>();

      // Check if user is already logged in
      if (authProvider.isAuthenticated) {
        AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.home);
      } else {
        AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _colorAnimation.value ?? AppTheme.primaryGreen,
                  AppTheme.primaryTeal,
                  AppTheme.darkTeal,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Background Elements
                  _buildAnimatedBackground(),

                  // Main Content
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo and App Name
                          AnimatedBuilder(
                            animation: _mainAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _mainAnimationController,
                                    curve: const Interval(0.0, 0.8,
                                        curve: Curves.easeOutBack),
                                  )),
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Column(
                                      children: [
                                        // App Logo with rotation animation
                                        AnimatedBuilder(
                                          animation: _logoAnimationController,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _rotationAnimation.value *
                                                  0.1,
                                              child: Container(
                                                width: 140,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      blurRadius: 30,
                                                      offset:
                                                          const Offset(0, 15),
                                                      spreadRadius: 5,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      blurRadius: 20,
                                                      offset:
                                                          const Offset(0, -5),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.local_pharmacy,
                                                  size: 70,
                                                  color: AppTheme.primaryGreen,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 32),

                                        // App Name with slide animation
                                        SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.5),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: _mainAnimationController,
                                            curve: const Interval(0.4, 1.0,
                                                curve: Curves.easeOutBack),
                                          )),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .welcomeToApp,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 36,
                                              letterSpacing: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // App Tagline with fade animation
                                        FadeTransition(
                                          opacity: Tween<double>(
                                            begin: 0.0,
                                            end: 1.0,
                                          ).animate(CurvedAnimation(
                                            parent: _mainAnimationController,
                                            curve: const Interval(0.6, 1.0,
                                                curve: Curves.easeInOut),
                                          )),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .welcomeToApp,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  letterSpacing: 0.5,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Loading Section
                  AnimatedBuilder(
                    animation: _mainAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _mainAnimationController,
                          curve:
                              const Interval(0.7, 1.0, curve: Curves.easeInOut),
                        )),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _mainAnimationController,
                            curve: const Interval(0.7, 1.0,
                                curve: Curves.easeOutBack),
                          )),
                          child: Column(
                            children: [
                              // Animated Loading Indicator
                              AnimatedBuilder(
                                animation: _loadingAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 3,
                                        ),
                                      ),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Loading Text with dots animation
                              _buildLoadingText(),

                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _mainAnimationController,
        builder: (context, child) {
          return CustomPaint(
            painter: _SplashBackgroundPainter(
              animationValue: _mainAnimationController.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        final dots = (3 * _loadingAnimationController.value).round();
        final dotsText = '.' * dots;

        return Text(
          '${AppLocalizations.of(context)!.loading}$dotsText',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        );
      },
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  final double animationValue;

  _SplashBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Animated circles in background
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Circle 1 - Top left
    paint.color = Colors.white.withOpacity(0.1 * animationValue);
    canvas.drawCircle(
      Offset(centerX * 0.3, centerY * 0.4),
      80 * animationValue,
      paint,
    );

    // Circle 2 - Top right
    paint.color = Colors.white.withOpacity(0.08 * animationValue);
    canvas.drawCircle(
      Offset(centerX * 1.7, centerY * 0.3),
      60 * animationValue,
      paint,
    );

    // Circle 3 - Bottom left
    paint.color = Colors.white.withOpacity(0.06 * animationValue);
    canvas.drawCircle(
      Offset(centerX * 0.2, centerY * 1.6),
      100 * animationValue,
      paint,
    );

    // Circle 4 - Bottom right
    paint.color = Colors.white.withOpacity(0.05 * animationValue);
    canvas.drawCircle(
      Offset(centerX * 1.8, centerY * 1.7),
      70 * animationValue,
      paint,
    );

    // Animated wave effect
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.3 * animationValue);

    final path = Path();
    final waveHeight = 20 * animationValue;
    final waveLength = size.width / 4;

    for (double x = 0; x <= size.width; x += 1) {
      final y = centerY +
          waveHeight *
              math.sin((x / waveLength) * 2 * math.pi +
                  animationValue * 2 * math.pi);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
