import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'app_logger.dart';

/// One attempt in the compression ladder: a long-edge cap and a JPEG quality.
class CompressionAttempt {
  /// Creates an attempt.
  const CompressionAttempt({required this.maxEdge, required this.quality});

  /// Longest permitted edge in pixels.
  final int maxEdge;

  /// JPEG quality, 1 to 100.
  final int quality;

  @override
  String toString() =>
      'CompressionAttempt(maxEdge: $maxEdge, quality: $quality)';

  @override
  bool operator ==(Object other) =>
      other is CompressionAttempt &&
      other.maxEdge == maxEdge &&
      other.quality == quality;

  @override
  int get hashCode => Object.hash(maxEdge, quality);
}

/// Decides how hard to squeeze a photograph, without touching any plugin.
///
/// Kept free of platform channels on purpose: the ladder is the part worth
/// testing, and it can then run under `flutter test` with no device.
abstract final class CompressionPlan {
  /// Longest edge allowed on the first attempt.
  static const int maxEdge = 1600;

  /// Starting JPEG quality.
  static const int startQuality = 82;

  /// Lowest quality worth trying before giving up on the size budget.
  static const int minQuality = 45;

  /// Size budget for an uploaded image.
  static const int targetBytes = 300 * 1024;

  /// The ordered attempts to try until one lands under [targetBytes].
  ///
  /// Quality drops first because it costs less visible detail than shrinking;
  /// only once quality is exhausted does the long edge come down.
  static List<CompressionAttempt> ladder() => <CompressionAttempt>[
    const CompressionAttempt(maxEdge: maxEdge, quality: startQuality),
    const CompressionAttempt(maxEdge: maxEdge, quality: 70),
    const CompressionAttempt(maxEdge: maxEdge, quality: 58),
    const CompressionAttempt(maxEdge: 1280, quality: 58),
    const CompressionAttempt(maxEdge: 1280, quality: minQuality),
    const CompressionAttempt(maxEdge: 1024, quality: minQuality),
  ];

  /// Whether [bytes] satisfies the upload budget.
  static bool isWithinBudget(int bytes) => bytes <= targetBytes;

  /// The next attempt after [current], or null when the ladder is exhausted.
  static CompressionAttempt? next(CompressionAttempt current) {
    final steps = ladder();
    final index = steps.indexOf(current);
    if (index < 0 || index + 1 >= steps.length) {
      return null;
    }
    return steps[index + 1];
  }
}

/// Compresses product photography before it is uploaded.
///
/// Walks [CompressionPlan.ladder] until the encoded result fits the budget,
/// then returns the smallest result it achieved. A photograph that cannot be
/// squeezed under the budget is still returned at the last attempt rather than
/// failing the upload: a slightly large image beats a lost one.
abstract final class ImageCompressor {
  /// Compresses [source] and writes the result beside it.
  ///
  /// Returns null when the plugin could not decode the file at all.
  static Future<File?> compress(File source, {String? targetPath}) async {
    final destination =
        targetPath ??
        '${source.parent.path}/mw_${source.uri.pathSegments.last}.jpg';

    File? best;
    var bestBytes = -1;

    for (final attempt in CompressionPlan.ladder()) {
      final result = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        destination,
        minWidth: attempt.maxEdge,
        minHeight: attempt.maxEdge,
        quality: attempt.quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null) {
        AppLog.warn('Image compression returned nothing for $attempt');
        continue;
      }

      final file = File(result.path);
      final bytes = await file.length();
      best = file;
      bestBytes = bytes;

      if (CompressionPlan.isWithinBudget(bytes)) {
        return file;
      }
    }

    if (best != null) {
      AppLog.warn(
        'Image stayed above the size budget at $bestBytes bytes after every '
        'compression attempt',
      );
    }
    return best;
  }
}
