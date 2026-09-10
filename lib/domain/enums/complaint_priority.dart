import 'package:freezed_annotation/freezed_annotation.dart';

/// Priority levels for dealer complaints.
enum ComplaintPriority {
  @JsonValue('low')
  low,

  @JsonValue('medium')
  medium,

  @JsonValue('high')
  high,

  @JsonValue('urgent')
  urgent;

  /// DB string value.
  String get value => switch (this) {
    low => 'low',
    medium => 'medium',
    high => 'high',
    urgent => 'urgent',
  };
}
