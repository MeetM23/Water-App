import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// The initialised Supabase client.
///
/// `Supabase.initialize` runs once in main before the app is mounted, so this
/// provider only exposes the resulting client. Widgets never touch it: only
/// repositories depend on this.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref<SupabaseClient> ref) =>
    Supabase.instance.client;
