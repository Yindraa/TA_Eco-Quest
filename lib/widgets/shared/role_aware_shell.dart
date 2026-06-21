import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../kelurahan/kelurahan_scaffold.dart';
import 'main_scaffold.dart';

/// Menentukan scaffold mana yang ditampilkan berdasarkan role user.
/// - role 'kelurahan' → KelurahanScaffold (simpel, tanpa gamifikasi)
/// - role lainnya    → MainScaffold (tampilan user biasa)
class RoleAwareShell extends StatefulWidget {
  const RoleAwareShell({super.key});

  @override
  State<RoleAwareShell> createState() => _RoleAwareShellState();
}

class _RoleAwareShellState extends State<RoleAwareShell> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          _role = data['role'] as String?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return _role == 'kelurahan'
        ? const KelurahanScaffold()
        : const MainScaffold();
  }
}
