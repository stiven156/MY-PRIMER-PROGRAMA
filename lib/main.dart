import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mercados/app.dart';
import 'package:mercados/core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializa Supabase si las credenciales estan configuradas
  final supabaseConfigured = !AppConstants.supabaseUrl.contains('YOUR_') &&
      AppConstants.supabaseUrl.isNotEmpty;

  if (supabaseConfigured) {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: MercadosApp()));
}
