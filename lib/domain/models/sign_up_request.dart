import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/user_role.dart';

part 'sign_up_request.freezed.dart';

/// Everything collected on the sign-up form.
///
/// [role] is limited to wholesaler and retailer by the form. The database
/// clamps it again in handle_new_user(), so posting owner here changes nothing.
@freezed
class SignUpRequest with _$SignUpRequest {
  /// Creates a sign-up request.
  const factory SignUpRequest({
    required String email,
    required String password,
    required String fullName,
    required String firmName,
    required String phone,
    required String city,
    required String state,
    required UserRole role,
    String? gstNumber,
    String? address,
  }) = _SignUpRequest;

  const SignUpRequest._();

  /// The user metadata sent to Supabase Auth, which the database trigger reads
  /// when it creates the matching profiles row.
  Map<String, dynamic> toUserMetadata() => <String, dynamic>{
    'full_name': fullName,
    'firm_name': firmName,
    'phone': phone,
    'city': city,
    'state': state,
    'role': role.name,
    if (gstNumber != null && gstNumber!.isNotEmpty) 'gst_number': gstNumber,
    if (address != null && address!.isNotEmpty) 'address': address,
  };
}
