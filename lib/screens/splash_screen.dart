import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.elasticOut)),
    );

    _controller.forward();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient with rich, warm ambient lighting
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF04060C),
                        const Color(0xFF0C1020),
                        const Color(0xFF151930),
                      ]
                    : [
                        const Color(0xFF1E3A8A), // Deep Navy Blue
                        const Color(0xFF2563EB), // Strong Royal Blue
                        const Color(0xFFF8FAFC), // Off-white Slate
                      ],
                stops: isDark ? const [0.0, 0.65, 1.0] : const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Soft ambient circular glows (Top Left)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? const Color(0xFF3B82F6).withAlpha(18) 
                        : Colors.white.withAlpha(45),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Soft ambient circular glows (Bottom Right)
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? const Color(0xFF93C5FD).withAlpha(12) 
                        : const Color(0xFF2563EB).withAlpha(18),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glassmorphic Outer Container
                          Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(isDark ? 20 : 70),
                                width: 1.8,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withAlpha(isDark ? 15 : 55),
                                  Colors.white.withAlpha(isDark ? 5 : 15),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark 
                                      ? Colors.black.withAlpha(120) 
                                      : const Color(0xFF1E3A8A).withAlpha(35),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 94,
                                height: 94,
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? const Color(0xFF0F1326) 
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark 
                                          ? const Color(0xFF93C5FD).withAlpha(30) 
                                          : const Color(0xFF2563EB).withAlpha(20),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.mail,
                                    size: 46,
                                    color: isDark 
                                        ? const Color(0xFF93C5FD) 
                                        : const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 54),

                          // Title Text Section
                          Text(
                            'TRINCOMALEE DISTRICT',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 7.0,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.white.withAlpha(210),
                            ),
                          ),
                          const SizedBox(height: 14),
                          
                          Text(
                            'Postal Directory',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1.2,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(60),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            'Administrative Registry & Asset Portal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 80),

                          // Loading Indicator
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? const Color(0xFF93C5FD) : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
