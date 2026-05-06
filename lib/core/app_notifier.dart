import 'package:flutter/foundation.dart';

/// Dipicu ketika ada perubahan data yang perlu di-refresh di HomeScreen
/// (klaim misi, selesaikan misi, laporan baru, dll).
/// Gunakan: homeRefreshNotifier.value++
final homeRefreshNotifier = ValueNotifier<int>(0);
