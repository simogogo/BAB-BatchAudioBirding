import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // 1. Persist state in SharedPreferences
    await ref.read(settingsProvider.notifier).setHasSeenOnboarding(true);
    if (mounted) {
      // 2. Navigate straight to Home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF30363D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define beautiful custom pages
    final List<Widget> pages = [
      // Page 1: Welcome
      _OnboardingPage(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        titleColor: const Color(0xFF4CAF50),
        iconWidget: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D6749).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
          ),
        ),
      ),
      // Page 2: AI analysis
      _OnboardingPage(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        titleColor: const Color(0xFF00BCD4),
        iconWidget: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF00BCD4), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BCD4).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.analytics_rounded, size: 72, color: Color(0xFF00BCD4)),
        ),
      ),
      // Page 3: Smart Filters
      _OnboardingPage(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        titleColor: const Color(0xFFFF9800),
        iconWidget: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFFFF9800), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.playlist_add_check_rounded, size: 72, color: Color(0xFFFF9800)),
        ),
      ),
      // Page 4: Ready to Start
      _OnboardingPage(
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        titleColor: const Color(0xFF4CAF50),
        iconWidget: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.rocket_launch_rounded, size: 72, color: Color(0xFF4CAF50)),
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF0D2117), Color(0xFF0D1117)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: AnimatedCrossFade(
                  firstChild: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          l10n.onboardingSkip,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(pages.length, (index) => _buildDot(index)),
                      ),
                      TextButton(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Text(
                          l10n.onboardingNext,
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  secondChild: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _completeOnboarding,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                        shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      ),
                      child: Text(
                        l10n.onboardingStart,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  crossFadeState: _currentPage == pages.length - 1
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget iconWidget;
  final Color titleColor;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.iconWidget,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          iconWidget
              .animate()
              .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
          const Spacer(flex: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8B949E),
                  height: 1.5,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0.0),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
