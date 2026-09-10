import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';

/// The dimmed surround, the cut-out window and the sweeping scan line.
///
/// The window is not decoration. It is the same rectangle the decoder is told
/// to look inside, so what the dealer aims at is exactly what gets read, and a
/// shelf of neighbouring labels cannot answer for the one in the middle.
class ScannerOverlay extends StatefulWidget {
  /// Creates the overlay for the cut-out [window].
  const ScannerOverlay({required this.window, super.key});

  /// The cut-out, in the coordinate space of the camera preview.
  final Rect window;

  /// The cut-out to use for a preview of [size].
  ///
  /// Capped in absolute terms as well as proportionally: on a tablet a window
  /// that stayed 78% of the width would ask the dealer to hold a phone-sized
  /// label half a metre from the lens.
  static Rect windowFor(Size size) {
    final width = math.min<double>(size.width * 0.78, 320);
    final height = math.min<double>(width * 0.68, size.height * 0.45);

    return Rect.fromCenter(
      // Sat above the middle so the hint line and the busy indicator have room
      // underneath without the dealer's own hand covering them.
      center: Offset(size.width / 2, size.height * 0.42),
      width: width,
      height: height,
    );
  }

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    // Reversing rather than restarting: a line that jumps back to the top
    // reads as a stutter, and this one is the only thing on screen saying the
    // camera is alive while the dealer lines up a label.
    unawaited(_sweep.repeat(reverse: true));
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScannerOverlayPainter(window: widget.window, sweep: _sweep),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.window, required this.sweep})
    : super(repaint: sweep);

  static const double _cornerArm = 22;
  static const double _lineInset = Spacing.x3;

  final Rect window;
  final Animation<double> sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final rounded = RRect.fromRectAndRadius(
      window,
      const Radius.circular(AppRadius.card),
    );

    // The design scrim is tuned to sit over white, where 40% is enough to push
    // a page back. Over a bright camera image it is not, and the point of the
    // dim is that the cut-out is obviously the only live part of the screen.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(rounded),
      ),
      Paint()..color = AppColors.ink.withOpacity(0.6),
    );

    canvas.drawRRect(
      rounded,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.surface.withOpacity(0.35),
    );

    canvas.drawPath(
      _corners(rounded),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary,
    );

    _paintScanLine(canvas);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) =>
      oldDelegate.window != window || oldDelegate.sweep != sweep;

  void _paintScanLine(Canvas canvas) {
    final travel = window.height - _lineInset * 2;
    if (travel <= 0) {
      return;
    }

    final line = Rect.fromLTWH(
      window.left + _lineInset,
      window.top + _lineInset + travel * sweep.value - 1,
      window.width - _lineInset * 2,
      2,
    );

    canvas.drawRect(
      line,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.primary.withOpacity(0),
            AppColors.primary,
            AppColors.primary.withOpacity(0),
          ],
        ).createShader(line),
    );
  }

  /// The four corner brackets, following the curve of [rounded] exactly.
  Path _corners(RRect rounded) {
    final radius = rounded.tlRadiusX;
    final rect = rounded.outerRect;
    final arm = math.max<double>(
      0,
      math.min<double>(_cornerArm, rect.shortestSide / 2 - radius),
    );
    final corner = Radius.circular(radius);

    return Path()
      ..moveTo(rect.left, rect.top + radius + arm)
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: corner)
      ..lineTo(rect.left + radius + arm, rect.top)
      ..moveTo(rect.right - radius - arm, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: corner)
      ..lineTo(rect.right, rect.top + radius + arm)
      ..moveTo(rect.right, rect.bottom - radius - arm)
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: corner)
      ..lineTo(rect.right - radius - arm, rect.bottom)
      ..moveTo(rect.left + radius + arm, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: corner)
      ..lineTo(rect.left, rect.bottom - radius - arm);
  }
}
