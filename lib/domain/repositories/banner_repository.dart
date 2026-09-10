import 'dart:io';

import '../../core/errors/result.dart';
import '../models/dashboard_banner.dart';

/// Contract for dashboard banner operations.
abstract class BannerRepository {
  /// Fetches active banners for the User Dashboard carousel.
  Future<Result<List<DashboardBanner>>> fetchActiveBanners();

  /// Fetches all banners (active and inactive) for Admin management.
  Future<Result<List<DashboardBanner>>> fetchAllBanners();

  /// Uploads a new banner image file to storage and creates a database record.
  Future<Result<DashboardBanner>> createBanner({
    required File imageFile,
    String? title,
    String? linkUrl,
  });

  /// Replaces the image file for an existing banner.
  Future<Result<DashboardBanner>> replaceBannerImage({
    required String bannerId,
    required String oldStoragePath,
    required File newImageFile,
  });

  /// Toggles active status of a banner.
  Future<Result<DashboardBanner>> toggleBannerStatus({
    required String bannerId,
    required bool isActive,
  });

  /// Updates sort order for a list of banners.
  Future<Result<void>> reorderBanners(List<({String bannerId, int sortOrder})> orderUpdates);

  /// Deletes a banner record and its associated storage file.
  Future<Result<void>> deleteBanner({
    required String bannerId,
    required String storagePath,
  });

  /// Resolves an image storage path to a displayable signed or public URL.
  Future<Result<String>> getSignedUrl(String storagePath);

  /// Downloads raw bytes of a banner image for display/caching.
  Future<Result<List<int>>> downloadImage(String storagePath);
}
