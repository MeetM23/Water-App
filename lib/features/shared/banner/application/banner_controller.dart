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
/// Designed to be completely stable and fail-safe:
/// - Keep alive in memory (`keepAlive: true`).
/// - Synchronously initialised with a stable default list.
/// - Performs an async fetch once in the background.
/// - Never enters an infinite loading or rebuild loop.
@Riverpod(keepAlive: true)
class ActiveBanners extends _$ActiveBanners {
  static final List<DashboardBanner> _defaultBanners = <DashboardBanner>[
    DashboardBanner(
      id: 'test_1',
      storagePath: 'test_banner_1',
      title: 'BANNER 1 — Pure Water Solution',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DashboardBanner(
      id: 'test_2',
      storagePath: 'test_banner_2',
      title: 'BANNER 2 — Genuine RO Components',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DashboardBanner(
      id: 'test_3',
      storagePath: 'test_banner_3',
      title: 'BANNER 3 — Premium Quality Filters',
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  List<DashboardBanner> build() {
    Future.microtask(() => loadActiveBanners());
    return _defaultBanners;
  }

  Future<void> loadActiveBanners() async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.fetchActiveBanners();

      result.fold(
        onSuccess: (banners) {
          if (banners.isNotEmpty) {
            state = banners;
          }
        },
        onFailure: (_) {},
      );
    } catch (e, st) {
      AppLog.warn('Could not load active banners', e, st);
    }
  }

  void updateBanners(List<DashboardBanner> banners) {
    final active = banners.where((b) => b.isActive).toList();
    state = active.isEmpty ? _defaultBanners : active;
  }
}

/// Controller managing all banners for Admin Banner Management.
@riverpod
class AdminBannersController extends _$AdminBannersController {
  static List<DashboardBanner> _localBanners = <DashboardBanner>[
    DashboardBanner(
      id: 'test_1',
      storagePath: 'test_banner_1',
      title: 'BANNER 1 — Pure Water Solution',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DashboardBanner(
      id: 'test_2',
      storagePath: 'test_banner_2',
      title: 'BANNER 2 — Genuine RO Components',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DashboardBanner(
      id: 'test_3',
      storagePath: 'test_banner_3',
      title: 'BANNER 3 — Premium Quality Filters',
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

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
        if (loaded.isNotEmpty) {
          _localBanners = loaded;
          return loaded;
        }
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

  @override
  Future<List<DashboardBanner>> build() async {
    await _loadDiskBanners();
    final repository = ref.watch(bannerRepositoryProvider);
    final result = await repository.fetchAllBanners();

    final loaded = result.fold(
      onSuccess: (banners) => banners.isEmpty ? _localBanners : banners,
      onFailure: (_) => List<DashboardBanner>.from(_localBanners),
    );
    ref.read(activeBannersProvider.notifier).updateBanners(loaded);
    return loaded;
  }

  /// Refreshes the banner list from the backend or local cache.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _loadDiskBanners();
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.fetchAllBanners();
      final loaded = result.fold(
        onSuccess: (banners) => banners.isEmpty ? _localBanners : banners,
        onFailure: (_) => List<DashboardBanner>.from(_localBanners),
      );
      ref.read(activeBannersProvider.notifier).updateBanners(loaded);
      return loaded;
    });
  }

  /// Creates a new banner from an image file.
  Future<void> addBanner({
    required File imageFile,
    String? title,
  }) async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.createBanner(
        imageFile: imageFile,
        title: title,
      );

      result.fold(
        onSuccess: (_) => refresh(),
        onFailure: (_) {
          final newBanner = DashboardBanner(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            storagePath: imageFile.path,
            title: title,
            sortOrder: _localBanners.length + 1,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _localBanners.add(newBanner);
          _saveDiskBanners();
          state = AsyncValue.data(List<DashboardBanner>.from(_localBanners));
          ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);
        },
      );
    } catch (_) {
      final newBanner = DashboardBanner(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        storagePath: imageFile.path,
        title: title,
        sortOrder: _localBanners.length + 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _localBanners.add(newBanner);
      _saveDiskBanners();
      state = AsyncValue.data(List<DashboardBanner>.from(_localBanners));
      ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);
    }
  }

  /// Replaces the image of an existing banner.
  Future<void> replaceImage({
    required String bannerId,
    required String oldStoragePath,
    required File newImageFile,
  }) async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.replaceBannerImage(
        bannerId: bannerId,
        oldStoragePath: oldStoragePath,
        newImageFile: newImageFile,
      );

      result.fold(
        onSuccess: (_) => refresh(),
        onFailure: (_) {
          _updateLocalBanner(
            bannerId,
            (b) => b.copyWith(storagePath: newImageFile.path),
          );
        },
      );
    } catch (_) {
      _updateLocalBanner(
        bannerId,
        (b) => b.copyWith(storagePath: newImageFile.path),
      );
    }
  }

  /// Toggles active status of a banner.
  Future<void> toggleStatus(String bannerId, bool isActive) async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.toggleBannerStatus(
        bannerId: bannerId,
        isActive: isActive,
      );

      result.fold(
        onSuccess: (_) => refresh(),
        onFailure: (_) {
          _updateLocalBanner(bannerId, (b) => b.copyWith(isActive: isActive));
        },
      );
    } catch (_) {
      _updateLocalBanner(bannerId, (b) => b.copyWith(isActive: isActive));
    }
  }

  /// Moves a banner up or down in sort order.
  Future<void> moveBanner(String bannerId, int direction) async {
    final currentList =
        List<DashboardBanner>.from(state.valueOrNull ?? _localBanners);
    final index = currentList.indexWhere((b) => b.id == bannerId);
    if (index == -1) return;

    final targetIndex = index + direction;
    if (targetIndex < 0 || targetIndex >= currentList.length) return;

    final temp = currentList[index];
    currentList[index] = currentList[targetIndex];
    currentList[targetIndex] = temp;

    final reordered = <DashboardBanner>[];
    for (var i = 0; i < currentList.length; i++) {
      reordered.add(currentList[i].copyWith(sortOrder: i + 1));
    }

    _localBanners.clear();
    _localBanners.addAll(reordered);
    await _saveDiskBanners();
    state = AsyncValue.data(List<DashboardBanner>.from(_localBanners));
    ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);

    try {
      final updates = <({String bannerId, int sortOrder})>[];
      for (var i = 0; i < reordered.length; i++) {
        updates.add((bannerId: reordered[i].id, sortOrder: i + 1));
      }
      final repository = ref.read(bannerRepositoryProvider);
      await repository.reorderBanners(updates);
    } catch (_) {}
  }

  /// Deletes a banner.
  Future<void> deleteBanner({
    required String bannerId,
    required String storagePath,
  }) async {
    try {
      final repository = ref.read(bannerRepositoryProvider);
      final result = await repository.deleteBanner(
        bannerId: bannerId,
        storagePath: storagePath,
      );

      result.fold(
        onSuccess: (_) => refresh(),
        onFailure: (_) {
          _localBanners.removeWhere((b) => b.id == bannerId);
          _saveDiskBanners();
          state = AsyncValue.data(List<DashboardBanner>.from(_localBanners));
          ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);
        },
      );
    } catch (_) {
      _localBanners.removeWhere((b) => b.id == bannerId);
      _saveDiskBanners();
      state = AsyncValue.data(List<DashboardBanner>.from(_localBanners));
      ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);
    }
  }

  void _updateLocalBanner(
    String bannerId,
    DashboardBanner Function(DashboardBanner) updater,
  ) {
    final idx = _localBanners.indexWhere((b) => b.id == bannerId);
    if (idx != -1) {
      _localBanners[idx] = updater(_localBanners[idx]);
    }
    final currentList = state.valueOrNull ?? <DashboardBanner>[];
    final currentIdx = currentList.indexWhere((b) => b.id == bannerId);
    if (currentIdx != -1) {
      final updatedList = List<DashboardBanner>.from(currentList);
      updatedList[currentIdx] = updater(updatedList[currentIdx]);
      state = AsyncValue.data(updatedList);
    }
    _saveDiskBanners();
    ref.read(activeBannersProvider.notifier).updateBanners(_localBanners);
  }
}
