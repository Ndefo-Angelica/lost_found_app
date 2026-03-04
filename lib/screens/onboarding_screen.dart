import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.search,
      title: 'Report Lost Items Easily',
      description:
          'Quickly report your lost items across Cameroon with detailed descriptions and photos to help the community identify them.',
      color1: AppColors.primary,
      color2: AppColors.primaryDark,
      iconColor: Colors.white,
    ),
    OnboardingSlide(
      icon: Icons.inventory_2,
      title: 'Find and Return Items Quickly',
      description:
          'Browse found items in Yaoundé, Douala, and other cities. Help reunite people with their belongings.',
      color1: AppColors.success,
      color2: AppColors.successDark,
      iconColor: Colors.white,
    ),
    OnboardingSlide(
      icon: Icons.security,
      title: 'Secure and Verified Communication',
      description:
          'Connect safely with verified users across Cameroon through our secure messaging system.',
      color1: AppColors.purple,
      color2: AppColors.purpleDark,
      iconColor: Colors.white,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [slide.color1, slide.color2],
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: slide.color1.withValues(alpha: 0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 80,
                                    color: slide.iconColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 60),
                          
                          // Title
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          
                          // Description
                          Text(
                            slide.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: index == _currentPage ? 32 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: index == _currentPage
                          ? LinearGradient(
                              colors: [
                                _slides[index].color1,
                                _slides[index].color2,
                              ],
                            )
                          : null,
                      color: index == _currentPage ? null : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  text: _currentPage == _slides.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: _nextPage,
                  icon: _currentPage == _slides.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color1;
  final Color color2;
  final Color iconColor;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color1,
    required this.color2,
    required this.iconColor,
  });
}