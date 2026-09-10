import 'package:freezed_annotation/freezed_annotation.dart';

/// Status of a dealer complaint.
enum ComplaintStatus {
  @JsonValue('open')
  open,

  @JsonValue('in_progress')
  inProgress,

  @JsonValue('resolved')
  resolved,

  @JsonValue('closed')
  closed;

  /// DB string value.
  String get value => switch (this) {
    open => 'open',
    inProgress => 'in_progress',
    resolved => 'resolved',
    closed => 'closed',
  };
}
