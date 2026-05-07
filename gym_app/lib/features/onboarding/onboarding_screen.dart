import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data model for each onboarding slide
// ---------------------------------------------------------------------------

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.blobColor1,
    required this.blobColor2,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Color blobColor1;
  final Color blobColor2;
}

const _slides = [
  _OnboardingSlide(
    icon: Icons.fitness_center,
    iconColor: Color(0xFFFF4F30),
    iconBackground: Color(0x33FF4F30),
    title: 'Gestiona tu Gimnasio',
    subtitle:
        'Controla miembros, pagos, clases y más desde un solo lugar. La herramienta definitiva para dueños de gym.',
    blobColor1: Color(0x40FF4F30),
    blobColor2: Color(0x20FF1060),
  ),
  _OnboardingSlide(
    icon: Icons.people,
    iconColor: Color(0xFF7B2FF7),
    iconBackground: Color(0x337B2FF7),
    title: 'Toda tu Comunidad',
    subtitle:
        'Conecta a tus miembros, crea retos y celebra logros juntos. Construye una comunidad fitness apasionada.',
    blobColor1: Color(0x407B2FF7),
    blobColor2: Color(0x2000D4FF),
  ),
  _OnboardingSlide(
    icon: Icons.bar_chart,
    iconColor: Color(0xFF00D4FF),
    iconBackground: Color(0x3300D4FF),
    title: 'Analítica en Tiempo Real',
    subtitle:
        'Decisiones inteligentes con datos de ingresos, retención y progreso. Tu negocio al siguiente nivel.',
    blobColor1: Color(0x3000D4FF),
    blobColor2: Color(0x2000D26A),
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background blobs (change per page)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _BackgroundBlobs(
              key: ValueKey(_currentPage),
              slide: _slides[_currentPage],
            ),
          ),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Top bar: skip button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicator dots (top)
                      Row(
                        children: List.generate(
                          _slides.length,
                          (i) => _DotIndicator(
                            isActive: i == _currentPage,
                            activeColor: _slides[_currentPage].iconColor,
                          ),
                        ),
                      ),
                      // Skip button
                      if (_currentPage < _slides.length - 1)
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Saltar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 72),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _SlideContent(slide: _slides[index]);
                    },
                  ),
                ),

                // Bottom navigation
                _BottomNavBar(
                  currentPage: _currentPage,
                  totalPages: _slides.length,
                  activeColor: _slides[_currentPage].iconColor,
                  onNext: _goToNext,
                  onPrevious: _goToPrevious,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background Blobs
// ---------------------------------------------------------------------------

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs({super.key, required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [slide.blobColor1, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [slide.blobColor2, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Slide Content
// ---------------------------------------------------------------------------

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon card
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: slide.iconBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: slide.iconColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.iconColor.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 90,
              color: slide.iconColor,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 52),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 150.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 500.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 250.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dot Indicator
// ---------------------------------------------------------------------------

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.isActive, required this.activeColor});

  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : AppColors.textMuted,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation Bar
// ---------------------------------------------------------------------------

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
    required this.onNext,
    required this.onPrevious,
  });

  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  bool get isLast => currentPage == totalPages - 1;
  bool get isFirst => currentPage == 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Back button
          AnimatedOpacity(
            opacity: isFirst ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: isFirst ? null : onPrevious,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Next / Start button
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              width: isLast ? 200 : 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [activeColor, activeColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLast) ...[
                    Text(
                      'Comenzar',
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
