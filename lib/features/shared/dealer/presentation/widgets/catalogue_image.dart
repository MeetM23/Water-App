import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/cache/hive_catalogue_cache.dart';
import '../../../../../data/repositories/supabase_catalog_repository.dart';
import '../../application/session_guard.dart';

part 'catalogue_image.g.dart';

/// Bytes for one catalogue image, cache first.
///
/// Deliberately NOT `cached_network_image`. That package keys its disk cache
/// by URL, and every URL here is a signed URL that expires within the hour —
/// so on the cold offline start this whole feature exists for, every key is a
/// miss and every image is blank. Keying by storage path instead means the
/// bytes survive the signature.
@riverpod
Future<Uint8List?> catalogueImageBytes(
  Ref<AsyncValue<Uint8List?>> ref,
  String storagePath,
) async {
  final cache = ref.watch(catalogueCacheProvider);

  final cached = cache.readImage(storagePath);
  if (cached != null) {
    return cached;
  }

  final result = await ref
      .read(catalogRepositoryProvider)
      .downloadImage(storagePath);

  final failure = result.failureOrNull;
  if (failure != null) {
    // The storage read policy is `is_approved()`, so a 403 here is one of the
    // few places a mid-session suspension announces itself loudly rather than
    // as an empty result. Worth reporting even though the image itself is not.
    ref.read(sessionGuardProvider).handle(failure);
    return null;
  }

  final bytes = result.valueOrNull;
  if (bytes == null) {
    // No bytes and no cache. The caller draws its placeholder; a dealer with
    // no signal and no cached image still gets a readable card.
    return null;
  }

  await cache.writeImage(storagePath, bytes);
  return bytes;
}

/// A product image that works offline.
class CatalogueImage extends ConsumerWidget {
  /// Creates an image for [storagePath].
  const CatalogueImage({
    required this.storagePath,
    super.key,
    this.fit = BoxFit.cover,
  });

  /// Where the file lives in the private bucket, or null for no image.
  final String? storagePath;

  /// How the image fills its box.
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = storagePath;
    if (path == null) {
      return const _Placeholder();
    }

    if (path.startsWith('/') ||
        path.startsWith('file://') ||
        File(path).existsSync()) {
      final cleanPath =
          path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          cacheWidth: 640,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => const _Placeholder(),
        );
      }
    }

    final bytes = ref.watch(catalogueImageBytesProvider(path));

    return bytes.when(
      loading: () => const ColoredBox(color: AppColors.skeletonBase),
      error: (_, __) => const _Placeholder(),
      data: (Uint8List? value) => value == null
          ? const _Placeholder()
          : Image.memory(
              value,
              fit: fit,
              // Decoding at display size rather than full resolution keeps a
              // grid of 1600px photographs from evicting itself out of the
              // image cache on a low-memory phone.
              cacheWidth: 640,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const _Placeholder(),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.primaryTint,
    child: Center(
      child: Icon(
        Icons.water_drop_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    ),
  );
}
