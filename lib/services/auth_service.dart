import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fungsi Registrasi Baru (UC-01)
  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      // Data fullName dikirim ke metadata agar ditangkap oleh Trigger di Supabase[cite: 1]
      data: {'full_name': fullName},
    );
  }

  // Fungsi Login
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
