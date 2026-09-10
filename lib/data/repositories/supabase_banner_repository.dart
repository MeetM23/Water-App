import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/image_compressor.dart';
import '../../domain/models/dashboard_banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_banner_repository.g.dart';

/// Supabase implementation of [BannerRepository].
class SupabaseBannerRepository implements BannerRepository {
  /// Creates a banner repository over a Supabase client.
  SupabaseBannerRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'dashboard-banners';
  static const String _table = 'dashboard_banners';
  static const int _signedUrlSeconds = 60 * 60 * 24; // 24 hours

  @override
  Future<Result<List<DashboardBanner>>> fetchActiveBanners() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final banners =
          rows.map((row) => DashboardBanner.fromJson(row)).toList();


      return Success<List<DashboardBanner>>(banners);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<DashboardBanner>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<DashboardBanner>>> fetchAllBanners() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('sort_order', ascending: true);

      final banners =
          rows.map((row) => DashboardBanner.fromJson(row)).toList();


      return Success<List<DashboardBanner>>(banners);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<DashboardBanner>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<DashboardBanner>> createBanner({
    required File imageFile,
    String? title,
    String? linkUrl,
  }) async {
    try {
      final compressed = await ImageCompressor.compress(imageFile);
      if (compressed == null) {
        return const ResultFailure<DashboardBanner>(
          UnexpectedFailure(cause: 'Image could not be compressed'),
        );
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_banner.jpg';
      final storagePath = 'banners/$fileName';

      await _client.storage.from(_bucket).upload(
            storagePath,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Determine next sort order
      final currentMaxRows = await _client
          .from(_table)
          .select('sort_order')
          .order('sort_order', ascending: false)
          .limit(1);

      final nextSortOrder = currentMaxRows.isNotEmpty
          ? ((currentMaxRows.first['sort_order'] as int?) ?? 0) + 1
          : 0;

      final insertedRow = await _client
          .from(_table)
          .insert({
            'storage_path': storagePath,
            'title': title,
            'link_url': linkUrl,
            'sort_order': nextSortOrder,
            'is_active': true,
          })
          .select()
          .single();

      final banner = DashboardBanner.fromJson(insertedRow);
      return Success<DashboardBanner>(banner);
    } on Object catch (error, stackTrace) {
      return ResultFailure<DashboardBanner>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<DashboardBanner>> replaceBannerImage({
    required String bannerId,
    required String oldStoragePath,
    required File newImageFile,
  }) async {
    try {
      final compressed = await ImageCompressor.compress(newImageFile);
      if (compressed == null) {
        return const ResultFailure<DashboardBanner>(
          UnexpectedFailure(cause: 'Image could not be compressed'),
        );
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_banner.jpg';
      final newStoragePath = 'banners/$fileName';

      await _client.storage.from(_bucket).upload(
            newStoragePath,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final updatedRow = await _client
          .from(_table)
          .update({
            'storage_path': newStoragePath,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bannerId)
          .select()
          .single();

      // Safely cleanup old file
      try {
        await _client.storage.from(_bucket).remove([oldStoragePath]);
      } catch (cleanupError, cleanupStack) {
        AppLog.warn('Could not remove replaced banner image', cleanupError, cleanupStack);
      }

      final banner = DashboardBanner.fromJson(updatedRow);
      return Success<DashboardBanner>(banner);
    } on Object catch (error, stackTrace) {
      return ResultFailure<DashboardBanner>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<DashboardBanner>> toggleBannerStatus({
    required String bannerId,
    required bool isActive,
  }) async {
    try {
      final updatedRow = await _client
          .from(_table)
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bannerId)
          .select()
          .single();

      final banner = DashboardBanner.fromJson(updatedRow);
      return Success<DashboardBanner>(banner);
    } on Object catch (error, stackTrace) {
      return ResultFailure<DashboardBanner>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> reorderBanners(
    List<({String bannerId, int sortOrder})> orderUpdates,
  ) async {
    try {
      for (final update in orderUpdates) {
        await _client.from(_table).update({
          'sort_order': update.sortOrder,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', update.bannerId);
      }
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteBanner({
    required String bannerId,
    required String storagePath,
  }) async {
    try {
      await _client.from(_table).delete().eq('id', bannerId);

      try {
        await _client.storage.from(_bucket).remove([storagePath]);
      } catch (cleanupError, cleanupStack) {
        AppLog.warn('Could not remove storage object for deleted banner', cleanupError, cleanupStack);
      }

      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> getSignedUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_bucket)
          .createSignedUrl(storagePath, _signedUrlSeconds);
      return Success<String>(url);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<int>>> downloadImage(String storagePath) async {
    try {
      final bytes = await _client.storage.from(_bucket).download(storagePath);
      return Success<List<int>>(bytes);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<int>>(_map(error, stackTrace));
    }
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is StorageException || error is PostgrestException) {
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped banner repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// Riverpod provider for [BannerRepository].
@Riverpod(keepAlive: true)
BannerRepository bannerRepository(Ref<BannerRepository> ref) =>
    SupabaseBannerRepository(ref.watch(supabaseClientProvider));
