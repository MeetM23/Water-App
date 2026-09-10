import 'package:json_annotation/json_annotation.dart';

/// Where an account sits in the owner approval flow.
enum AccountStatus {
  /// Signed up, waiting for the owner to decide.
  @JsonValue('pending')
  pending,

  /// Approved and able to use the app.
  @JsonValue('approved')
  approved,

  /// Turned down by the owner, with a reason.
  @JsonValue('rejected')
  rejected,

  /// Previously approved, since paused by the owner.
  @JsonValue('suspended')
  suspended,
}
