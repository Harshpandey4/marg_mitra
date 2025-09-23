import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _startAnimation();
    _navigateToLogin();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
  }

  void _navigateToLogin() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBBDEFB), // Material Blue
              Color(0xFFBBDEFB), // Darker Blue
              Color(0xFF0D47A1), // Deep Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Section
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLogo(isTablet),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // App Name
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Marg Mitra',
                          style: TextStyle(
                            fontSize: isTablet ? 36 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Roadside Safety Partner',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.yellow.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Loading Indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isTablet) {
    final logoSize = isTablet ? 120.0 : 100.0;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(logoSize * 0.1), // Add some padding
          child: Image.asset(
            'assets/app_logo.png',
            width: logoSize * 0.8,
            height: logoSize * 0.8,
            fit: BoxFit.contain, // This ensures the logo fits properly within the circle
            errorBuilder: (context, error, stackTrace) {
              // Fallback to original icon design if image fails to load
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main car icon
                    Icon(
                      Icons.directions_car_rounded,
                      size: logoSize * 0.5,
                      color: const Color(0xFF1976D2),
                    ),
                    // Road/path indicator
                    Positioned(
                      bottom: logoSize * 0.25,
                      child: Container(
                        width: logoSize * 0.6,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    // Safety indicator
                    Positioned(
                      top: logoSize * 0.2,
                      right: logoSize * 0.2,
                      child: Container(
                        width: logoSize * 0.15,
                        height: logoSize * 0.15,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: logoSize * 0.08,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}