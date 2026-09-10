import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_banner.freezed.dart';

/// Represents a promotional or informational banner displayed on the User Dashboard carousel.
@Freezed(fromJson: false, toJson: false)
class DashboardBanner with _$DashboardBanner {
  /// Creates a dashboard banner model.
  const factory DashboardBanner({
    required String id,
    required String storagePath,
    required int sortOrder,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? title,
    String? linkUrl,
  }) = _DashboardBanner;

  /// Deserializes a banner object from JSON.
  factory DashboardBanner.fromJson(Map<String, dynamic> json) =>
      DashboardBanner(
        id: json['id'] as String,
        storagePath: json['storage_path'] as String,
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        title: json['title'] as String?,
        linkUrl: json['link_url'] as String?,
      );
}
