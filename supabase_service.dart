import 'package:supabase_flutter/supabase_flutter.dart';

import 'mock_data.dart';
import 'models.dart';

class SupabaseService {
  SupabaseService._();

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool _initialized = false;
  static bool _configured = false;

  static bool get isConfigured => _configured;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (_url.isEmpty && _publishableKey.isEmpty) {
      _initialized = true;
      return;
    }
    if (_url.isEmpty || _publishableKey.isEmpty) {
      throw StateError(
        'Set both SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to connect '
        'Supabase, or leave both unset to use demo data.',
      );
    }

    await Supabase.initialize(url: _url, publishableKey: _publishableKey);
    _configured = true;
    _initialized = true;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _requireConfigured();
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required bool isSeller,
  }) async {
    _requireConfigured();
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'account_type': isSeller ? 'seller' : 'customer'},
    );
  }

  static Future<void> resetPassword(String email) async {
    _requireConfigured();
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  static Future<void> signOut() async {
    if (_configured) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  static void _requireConfigured() {
    if (!_configured) {
      throw StateError(
        'Supabase Auth is not configured. Set SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY when starting the app.',
      );
    }
  }

  static Future<List<Seller>> fetchSellers() async {
    if (!_configured) return kSellers;

    final rows = await Supabase.instance.client
        .from('sellers')
        .select()
        .order('name');
    return rows.map((row) => Seller.fromSupabase(row)).toList(growable: false);
  }
}
