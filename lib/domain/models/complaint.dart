import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/complaint_category.dart';
import '../enums/complaint_priority.dart';
import '../enums/complaint_status.dart';
import 'catalog_product.dart';
import 'complaint_attachment.dart';
import 'complaint_message.dart';
import 'profile.dart';

part 'complaint.freezed.dart';
part 'complaint.g.dart';

/// A dealer or owner complaint ticket.
@freezed
class Complaint with _$Complaint {
  /// Creates a complaint model.
  const factory Complaint({
    required String id,
    required String ticketNumber,
    required String userId,
    required String subject,
    required ComplaintCategory category,
    required String description,
    required ComplaintPriority priority,
    required ComplaintStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? productId,
    String? referenceNumber,
    DateTime? resolvedAt,
    Profile? userProfile,
    CatalogProduct? product,
    @Default(<ComplaintMessage>[]) List<ComplaintMessage> messages,
    @Default(<ComplaintAttachment>[]) List<ComplaintAttachment> attachments,
  }) = _Complaint;

  const Complaint._();

  /// Deserializes a complaint row.
  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
}
