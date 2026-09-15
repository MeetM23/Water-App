import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../data/repositories/supabase_banner_repository.dart';
import '../../../../domain/models/dashboard_banner.dart';

part 'banner_controller.g.dart';

/// Provider for active banners displayed on the User Dashboard.
///
/// Supabase is the single source of truth:
/// - Fetches active banners from `dashboard_banners` table.
/// - Returns empty list `[]` when no active banners exist.
/// - Caches fresh remote banners to disk for offline fallback.
@Riverpod(keepAlive: true)
class ActiveBanners extends _$ActiveBanners {
  @override
  List<DashboardBanner> build() {
    Future.microtask(() => loadActiveBanners());
    return <DashboardBanner>[];
  }

  Future<void> loadActiveBanners() async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.fetchActiveBanners();

      await result.fold(
        onSuccess: (remoteBanners) async {
          state = remoteBanners;
          await AdminBannersController._saveDiskBannersList(remoteBanners);
        },
        onFailure: (_) async {
          final diskBanners = await AdminBannersController._loadDiskBanners();
          final activeDisk = diskBanners.where((b) => b.isActive).toList();
          state = activeDisk;
        },
      );
    } catch (e, st) {
      AppLog.warn('Could not load active banners', e, st);
    }
  }

  void updateBanners(List<DashboardBanner> banners) {
    final active = banners.where((b) => b.isActive).toList();
    state = active;
  }
}

/// Controller managing all banners for Admin Banner Management.
@riverpod
class AdminBannersController extends _$AdminBannersController {
  static List<DashboardBanner> _localBanners = <DashboardBanner>[];

  static Future<List<DashboardBanner>> _loadDiskBanners() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/banners/banners_store.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonList = jsonDecode(content) as List<dynamic>;
        final loaded = jsonList
            .map((e) => DashboardBanner.fromJson(e as Map<String, dynamic>))
            .toList();
        _localBanners = loaded;
        return loaded;
      }
    } catch (e, st) {
      AppLog.warn('Could not read banners from disk', e, st);
    }
    return _localBanners;
  }

  static Map<String, dynamic> _bannerToMap(DashboardBanner b) => <String, dynamic>{
        'id': b.id,
        'storage_path': b.storagePath,
        'sort_order': b.sortOrder,
        'is_active': b.isActive,
        'created_at': b.createdAt.toIso8601String(),
        'updated_at': b.updatedAt.toIso8601String(),
        'title': b.title,
        'link_url': b.linkUrl,
      };

  static Future<void> _saveDiskBanners() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final bannerDir = Directory('${appDir.path}/banners');
      if (!await bannerDir.exists()) {
        await bannerDir.create(recursive: true);
      }
      final file = File('${bannerDir.path}/banners_store.json');
      final jsonList = _localBanners.map(_bannerToMap).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e, st) {
      AppLog.warn('Could not save banners to disk', e, st);
    }
  }

  static Future<void> _saveDiskBannersList(List<DashboardBanner> banners) async {
    _localBanners = List<DashboardBanner>.from(banners);
    await _saveDiskBanners();
  }

  @override
  Future<List<DashboardBanner>> build() async {
    final repository = ref.watch(bannerRepositoryProvider);
    final result = await repository.fetchAllBanners();

    return result.fold(
      onSuccess: (banners) {
        _saveDiskBannersList(banners);
        ref.read(activeBannersProvider.notifier).updateBanners(banners);
        return banners;
      },
      onFailure: (_) async {
        final disk = await _loadDiskBanners();
        ref.read(activeBannersProvider.notifier).updateBanners(disk);
        return disk;
      },
    );
  }

  /// Refreshes the banner list from Supabase and syncs active banners.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.fetchAllBanners();
      return result.fold(
        onSuccess: (banners) {
          _saveDiskBannersList(banners);
          ref.read(activeBannersProvider.notifier).updateBanners(banners);
          return banners;
        },
        onFailure: (failure) async {
          final disk = await _loadDiskBanners();
          ref.read(activeBannersProvider.notifier).updateBanners(disk);
          return disk;
        },
      );
    });
  }

  /// Creates a new banner from an image file in Supabase Storage.
  Future<void> addBanner({
    required File imageFile,
    String? title,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(bannerRepositoryProvider);
    final result = await repository.createBanner(
      imageFile: imageFile,
      title: title,
    );

    await result.fold(
      onSuccess: (_) => refresh(),
      onFailure: (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
        await refresh();
      },
    );
  }

  /// Replaces the image of an existing banner in Supabase.
  Future<void> replaceImage({
    required String bannerId,
    required String oldStoragePath,
    required File newImageFile,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(bannerRepositoryProvider);
    final result = await repository.replaceBannerImage(
      bannerId: bannerId,
      oldStoragePath: oldStoragePath,
      newImageFile: newImageFile,
    );

    await result.fold(
      onSuccess: (_) => refresh(),
      onFailure: (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
        await refresh();
      },
    );
  }

  /// Toggles active status of a banner in Supabase.
  Future<void> toggleStatus(String bannerId, bool isActive) async {
    final repository = ref.read(bannerRepositoryProvider);
    final result = await repository.toggleBannerStatus(
      bannerId: bannerId,
      isActive: isActive,
    );

    await result.fold(
      onSuccess: (_) => refresh(),
      onFailure: (failure) async {
        await refresh();
      },
    );
  }

  /// Moves a banner up or down in sort order in Supabase.
  Future<void> moveBanner(String bannerId, int direction) async {
    final currentList = List<DashboardBanner>.from(state.valueOrNull ?? <DashboardBanner>[]);
    final index = currentList.indexWhere((b) => b.id == bannerId);
    if (index == -1) return;

    final targetIndex = index + direction;
    if (targetIndex < 0 || targetIndex >= currentList.length) return;

    final temp = currentList[index];
    currentList[index] = currentList[targetIndex];
    currentList[targetIndex] = temp;

    final updates = <({String bannerId, int sortOrder})>[];
    for (var i = 0; i < currentList.length; i++) {
      updates.add((bannerId: currentList[i].id, sortOrder: i + 1));
    }

    final repository = ref.read(bannerRepositoryProvider);
    final result = await repository.reorderBanners(updates);

    await result.fold(
      onSuccess: (_) => refresh(),
      onFailure: (_) => refresh(),
    );
  }

  /// Deletes a banner and its storage object from Supabase.
  Future<void> deleteBanner({
    required String bannerId,
    required String storagePath,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(bannerRepositoryProvider);
    final result = await repository.deleteBanner(
      bannerId: bannerId,
      storagePath: storagePath,
    );

    await result.fold(
      onSuccess: (_) => refresh(),
      onFailure: (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
        await refresh();
      },
    );
  }
}
