import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../providers/model_provider.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkModel());
  }

  Future<void> _checkModel() async {
    final notifier = ref.read(modelProvider.notifier);
    final modelState = ref.read(modelProvider).valueOrNull;

    if (modelState?.isReady == true) {
      _navigateHome();
      return;
    }

    await notifier.downloadModels();
  }

  void _navigateHome() async {
    if (!mounted) return;
    final settings = await ref.read(settingsProvider.future);
    if (!mounted) return;
    if (!settings.hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final modelAsync = ref.watch(modelProvider);

    // Auto-navigate when ready
    ref.listen<AsyncValue<ModelState>>(modelProvider, (_, next) {
      if (next.valueOrNull?.isReady == true) _navigateHome();
    });

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
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ──────────────────────────────────────────────
                _BirdLogo()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.7, 0.7)),

                const SizedBox(height: 32),

                Text(
                  'Batch Audio Birding',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4CAF50),
                        letterSpacing: -0.5,
                      ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'Powered by BirdNET AI',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8B949E),
                      ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(flex: 2),

                // ── Download status ────────────────────────────────────
                modelAsync.when(
                  loading: () => const _StatusIndicator(message: '...'),
                  error: (e, _) => _ErrorWidget(
                    error: e.toString(),
                    onRetry: () => ref
                        .read(modelProvider.notifier)
                        .downloadModels(),
                  ),
                  data: (modelState) {
                    if (modelState.isReady) {
                      return _StatusIndicator(
                        message: l10n.splashModelReady,
                        color: const Color(0xFF4CAF50),
                        icon: Icons.check_circle_outline,
                      );
                    }
                    if (modelState.hasError) {
                      return _ErrorWidget(
                        error: modelState.error ?? l10n.splashDownloadError,
                        onRetry: () => ref
                            .read(modelProvider.notifier)
                            .downloadModels(),
                      );
                    }
                    return _StatusIndicator(message: l10n.splashDownloadingModel);
                  },
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bird Logo Widget ─────────────────────────────────────────────────────

class _BirdLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF0D2117)],
        ),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.spatial_audio, size: 72, color: Color(0xFF4CAF50)),
    );
  }
}


// ─── Status indicator ─────────────────────────────────────────────────────

class _StatusIndicator extends StatelessWidget {
  final String message;
  final Color? color;
  final IconData? icon;

  const _StatusIndicator({
    required this.message,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color ?? const Color(0xFF8B949E), size: 20),
          const SizedBox(width: 8),
        ] else
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color ?? const Color(0xFF4CAF50),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? const Color(0xFF8B949E),
              ),
        ),
      ],
    );
  }
}

// ─── Error widget ─────────────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const Icon(Icons.wifi_off_rounded,
            color: Color(0xFFF85149), size: 40),
        const SizedBox(height: 12),
        Text(
          l10n.splashDownloadError,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: const Color(0xFFF85149)),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.splashRetry),
        ),
      ],
    );
  }
}
