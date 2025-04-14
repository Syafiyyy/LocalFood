import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:group_project/core/theme/app_theme.dart';
import 'package:group_project/core/constants/app_constants.dart';
import 'package:group_project/features/auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Start animations
    _animationController.forward();

    // Wait for animations and check auth state
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    // Wait for animations to complete
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Get auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Navigate based on auth state
    switch (authProvider.authState) {
      case AuthState.authenticated:
        Navigator.pushReplacementNamed(context, RouteConstants.home);
        break;
      case AuthState.unauthenticated:
      case AuthState.error:
        Navigator.pushReplacementNamed(context, RouteConstants.login);
        break;
      default:
        // For any other state, wait for auth provider to update
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    final authProvider = Provider.of<AuthProvider>(context);

    // When auth state changes, navigate accordingly
    if (authProvider.authState == AuthState.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, RouteConstants.home);
      });
    } else if (authProvider.authState == AuthState.unauthenticated ||
        authProvider.authState == AuthState.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, RouteConstants.login);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo with enhanced animation
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/localicious.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name with gradient text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        AppConstants.appName,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                      ),
                    ),

                    // App Tagline with enhanced styling
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textColorSecondary,
                                  letterSpacing: 1.2,
                                  height: 1.4,
                                ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Enhanced loading indicator
                    if (authProvider.authState == AuthState.loading ||
                        authProvider.authState == AuthState.initial)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                          strokeWidth: 3,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
