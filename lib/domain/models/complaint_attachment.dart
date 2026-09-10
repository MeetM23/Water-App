import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_attachment.freezed.dart';
part 'complaint_attachment.g.dart';

/// An attachment metadata object for a complaint.
@freezed
class ComplaintAttachment with _$ComplaintAttachment {
  /// Creates a complaint attachment metadata model.
  const factory ComplaintAttachment({
    required String id,
    required String complaintId,
    required String storagePath,
    required String fileName,
    required DateTime createdAt,
    int? fileSize,
  }) = _ComplaintAttachment;

  const ComplaintAttachment._();

  /// Deserializes a complaint attachment row.
  factory ComplaintAttachment.fromJson(Map<String, dynamic> json) =>
      _$ComplaintAttachmentFromJson(json);
}
