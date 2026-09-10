import 'package:json_annotation/json_annotation.dart';

/// Which catalogue and which prices an account is entitled to.
///
/// The value is decided by the database, never by the client. The app uses it
/// only to choose a start route and to label the UI; it grants nothing.
enum UserRole {
  /// Maruti Water Solution staff. Manages products and the dealer network.
  @JsonValue('owner')
  owner,

  /// Buys at wholesale prices.
  @JsonValue('wholesaler')
  wholesaler,

  /// Buys at retail prices.
  @JsonValue('retailer')
  retailer,
}
