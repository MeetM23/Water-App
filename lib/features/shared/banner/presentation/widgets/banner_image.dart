import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/repositories/supabase_banner_repository.dart';
import '../../../../../data/supabase/supabase_providers.dart';

/// A robust widget for displaying promotional banner images from local storage,
/// remote web URLs, or Supabase 'dashboard-banners' storage bucket.
class BannerImage extends ConsumerWidget {
  /// Creates a banner image for [storagePath].
  const BannerImage({
    required this.storagePath,
    super.key,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  /// The storage path, local path, or HTTP URL for the banner image.
  final String storagePath;

  /// How the image should fit into its container.
  final BoxFit fit;

  /// Optional custom error builder.
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = storagePath.trim();
    if (path.isEmpty || path.startsWith('test_banner_')) {
      return errorBuilder?.call(context) ?? _defaultPlaceholder();
    }

    // 1. Direct absolute file path check
    if (path.startsWith('/') ||
        path.startsWith('file://') ||
        path.contains(':\\') ||
        path.contains(':/')) {
      final cleanPath = path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => errorBuilder?.call(context) ?? _defaultPlaceholder(),
        );
      }
    }

    // 2. Relative file path check in application documents directory
    return FutureBuilder<File?>(
      future: _findLocalBannerFile(path),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data!.existsSync()) {
          return Image.file(
            snapshot.data!,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => errorBuilder?.call(context) ?? _defaultPlaceholder(),
          );
        }

        // 3. Remote HTTP/HTTPS URL
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return Image.network(
            path,
            fit: fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: AppColors.skeletonBase);
            },
            errorBuilder: (_, __, ___) => errorBuilder?.call(context) ?? _defaultPlaceholder(),
          );
        }

        // 4. Supabase Storage Path (bucket: 'dashboard-banners')
        final client = ref.watch(supabaseClientProvider);
        final publicUrl = client.storage.from('dashboard-banners').getPublicUrl(path);

        return Image.network(
          publicUrl,
          fit: fit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(color: AppColors.skeletonBase);
          },
          errorBuilder: (_, __, ___) {
            // Fallback to downloading storage object bytes
            return _BannerBytesLoader(
              storagePath: path,
              fit: fit,
              errorBuilder: errorBuilder,
            );
          },
        );
      },
    );
  }

  static Future<File?> _findLocalBannerFile(String path) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localFile = File('${appDir.path}/$path');
      if (await localFile.exists()) {
        return localFile;
      }
    } catch (_) {}
    return null;
  }

  Widget _defaultPlaceholder() {
    return const ColoredBox(
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
}

class _BannerBytesLoader extends ConsumerWidget {
  const _BannerBytesLoader({
    required this.storagePath,
    required this.fit,
    this.errorBuilder,
  });

  final String storagePath;
  final BoxFit fit;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Uint8List?>(
      future: ref.read(bannerRepositoryProvider).downloadImage(storagePath).then(
            (res) => res.valueOrNull != null ? Uint8List.fromList(res.valueOrNull!) : null,
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(color: AppColors.skeletonBase);
        }
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => errorBuilder?.call(context) ?? _placeholder(),
          );
        }
        return errorBuilder?.call(context) ?? _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
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
}
