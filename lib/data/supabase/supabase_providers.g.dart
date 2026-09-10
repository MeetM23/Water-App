// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseClientHash() => r'db61d1e006aa4d404e1ba060b2b67fa31dad3b15';

/// The initialised Supabase client.
///
/// `Supabase.initialize` runs once in main before the app is mounted, so this
/// provider only exposes the resulting client. Widgets never touch it: only
/// repositories depend on this.
///
/// Copied from [supabaseClient].
@ProviderFor(supabaseClient)
final supabaseClientProvider = Provider<SupabaseClient>.internal(
  supabaseClient,
  name: r'supabaseClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseClientRef = ProviderRef<SupabaseClient>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
