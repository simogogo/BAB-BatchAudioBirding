import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spectrogram_color_theme.dart';
import '../providers/settings_provider.dart';
import '../services/spectrogram_service.dart';

class SpectrogramWidget extends ConsumerWidget {
  final SpectrogramData data;
  final double playbackPosition; // seconds
  final List<(double, double)> highlights; // (start, end) in seconds
  final double widthPerSecond;
  final double height;
  /// Increment this whenever new chunks arrive to force a repaint.
  final int completedFrameCount;

  const SpectrogramWidget({
    super.key,
    required this.data,
    required this.playbackPosition,
    this.highlights = const [],
    this.widthPerSecond = 60.0,
    this.height = 180.0,
    this.completedFrameCount = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Width is always based on the KNOWN total duration, never on partial frames.
    final totalWidth = data.totalDuration * widthPerSecond;
    final settingsAsync = ref.watch(settingsProvider);
    final theme = settingsAsync.valueOrNull?.spectrogramTheme ?? SpectrogramColorTheme.colored;

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: totalWidth,
        child: CustomPaint(
          painter: _SpectrogramPainter(
            data: data,
            playbackPosition: playbackPosition,
            highlights: highlights,
            widthPerSecond: widthPerSecond,
            completedFrameCount: completedFrameCount,
            theme: theme,
          ),
        ),
      ),
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _SpectrogramPainter extends CustomPainter {
  final SpectrogramData data;
  final double playbackPosition;
  final List<(double, double)> highlights;
  final double widthPerSecond;
  final int completedFrameCount;
  final SpectrogramColorTheme theme;

  _SpectrogramPainter({
    required this.data,
    required this.playbackPosition,
    required this.highlights,
    required this.widthPerSecond,
    required this.completedFrameCount,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.frameCount == 0) return;

    final frameWidth = (data.hopSize / data.sampleRate) * widthPerSecond;
    final clip = canvas.getLocalClipBounds();

    final startFrame = (clip.left / frameWidth).floor().clamp(0, data.frameCount - 1);
    final endFrame = (clip.right / frameWidth).ceil().clamp(0, data.frameCount - 1);

    final palette = SpectrogramService.getPalette(theme);
    final bgPaintColor = palette[0].color;
    final isLight = ThemeData.estimateBrightnessForColor(bgPaintColor) == Brightness.light;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(clip.left, 0, clip.width, size.height), Paint()..color = bgPaintColor);

    // Detect stripe boundaries for pending regions (draw as subtle diagonal stripes)
    int? pendingStart;

    for (int i = startFrame; i <= endFrame; i++) {
      final frame = data.frames[i];
      final x = i * frameWidth;

      if (frame == null) {
        // Mark start of pending region
        pendingStart ??= i;
        continue;
      }

      // Flush any pending region before this computed frame
      if (pendingStart != null) {
        _drawPendingRegion(canvas, pendingStart * frameWidth, x, size.height, frameWidth, bgPaintColor, isLight);
        pendingStart = null;
      }

      // Draw computed frame
      final numBins = frame.length;
      final binHeight = size.height / numBins;
      for (int j = 0; j < numBins; j++) {
        final val = frame[j];
        if (val < 15) continue;
        canvas.drawRect(
          Rect.fromLTWH(x, size.height - (j + 1) * binHeight, frameWidth + 0.3, binHeight + 0.3),
          palette[val],
        );
      }
    }

    // Flush trailing pending region
    if (pendingStart != null) {
      _drawPendingRegion(
        canvas,
        pendingStart * frameWidth,
        (endFrame + 1) * frameWidth,
        size.height,
        frameWidth,
        bgPaintColor,
        isLight,
      );
    }

    // Draw highlights (adapt colors to light vs dark background)
    final highlightFill = Paint()
      ..color = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final highlightBorder = Paint()
      ..color = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final h in highlights) {
      final hX = h.$1 * widthPerSecond;
      final hW = (h.$2 - h.$1) * widthPerSecond;
      if (hX + hW < clip.left || hX > clip.right) continue;
      canvas.drawRect(Rect.fromLTWH(hX, 0, hW, size.height), highlightFill);
      canvas.drawRect(Rect.fromLTWH(hX, 0, hW, size.height), highlightBorder);
    }

    // Draw playback cursor
    final cursorX = playbackPosition * widthPerSecond;
    if (cursorX >= clip.left && cursorX <= clip.right) {
      canvas.drawLine(
        Offset(cursorX, 0),
        Offset(cursorX, size.height),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0,
      );
    }
  }

  void _drawPendingRegion(
      Canvas canvas, double left, double right, double height, double frameWidth, Color bgPaintColor, bool isLight) {
    final rect = Rect.fromLTWH(left, 0, right - left, height);
    canvas.drawRect(rect, Paint()..color = bgPaintColor);

    // Subtle diagonal stripes to signal "loading"
    const stripeSpacing = 12.0;
    final stripePaint = Paint()
      ..color = isLight ? bgPaintColor.withValues(alpha: 0.15) : const Color(0xFF252D3A)
      ..style = PaintingStyle.fill;
    final path = Path();
    for (double sx = left - height; sx < right + stripeSpacing; sx += stripeSpacing) {
      path.moveTo(sx, height);
      path.lineTo(sx + height, 0);
      path.lineTo(sx + height + frameWidth, 0);
      path.lineTo(sx + frameWidth, height);
      path.close();
    }
    canvas.clipRect(rect);
    canvas.drawPath(path, stripePaint);
  }

  @override
  bool shouldRepaint(covariant _SpectrogramPainter old) {
    return old.playbackPosition != playbackPosition ||
        old.highlights != highlights ||
        old.completedFrameCount != completedFrameCount ||
        old.theme != theme;
  }
}
