import 'package:freezed_annotation/freezed_annotation.dart';

/// Categories for dealer complaints.
enum ComplaintCategory {
  @JsonValue('product_issue')
  productIssue,

  @JsonValue('installation_issue')
  installationIssue,

  @JsonValue('warranty_issue')
  warrantyIssue,

  @JsonValue('delivery_issue')
  deliveryIssue,

  @JsonValue('billing_issue')
  billingIssue,

  @JsonValue('technical_issue')
  technicalIssue,

  @JsonValue('other')
  other;

  /// DB string value.
  String get value => switch (this) {
    productIssue => 'product_issue',
    installationIssue => 'installation_issue',
    warrantyIssue => 'warranty_issue',
    deliveryIssue => 'delivery_issue',
    billingIssue => 'billing_issue',
    technicalIssue => 'technical_issue',
    other => 'other',
  };
}
