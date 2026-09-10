import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile.dart';

part 'complaint_message.freezed.dart';
part 'complaint_message.g.dart';

/// A comment or message in a complaint timeline.
@freezed
class ComplaintMessage with _$ComplaintMessage {
  /// Creates a complaint message model.
  const factory ComplaintMessage({
    required String id,
    required String complaintId,
    required String senderId,
    required String message,
    required DateTime createdAt,
    @Default(false) bool isInternal,
    Profile? senderProfile,
  }) = _ComplaintMessage;

  const ComplaintMessage._();

  /// Deserializes a complaint message row.
  factory ComplaintMessage.fromJson(Map<String, dynamic> json) =>
      _$ComplaintMessageFromJson(json);
}
