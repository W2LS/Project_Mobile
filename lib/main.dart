import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/local_storage_initializer.dart';

import 'core/main_scaffold.dart';
import 'controller/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'bindings/note_binding.dart';
// 🔥 IMPORT SCREEN YANG HILANG 🔥
import 'features/history/catatan_screen.dart'; // <--- Wajib ada

// Warna utama
const Color subMainColor = Color(0xFF42A5F5);

// Global accessor untuk klien Supabase
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi LOCAL STORAGE (Hive & SharedPreferences)
  await LocalStorageInitializer.init();

  // 2. Inisialisasi SUPABASE (Cloud Storage)
  // GANTI DENGAN URL DAN KUNCI ANON ANDA YANG ASLI
  await Supabase.initialize(
    url: 'https://anmwxheszygjldayfhvk.supabase.co', // GANTI INI
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubXd4aGVzenlnamxkYXlmaHZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzOTMzMDUsImV4cCI6MjA3ODk2OTMwNX0.Eeli4GoGAsSyaUQbDfxoVyZbGs6XCp7H_XjpLuo5Ucw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Home | Luminae',
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(primary: subMainColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      getPages: [
        GetPage(
            name: '/login',
            page: () => const LoginScreen(),
            binding: BindingsBuilder(() => Get.lazyPut(() => AuthController()))
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const MainScaffold(),
        ),
        GetPage(
          name: '/notes',
          // 🔥 HAPUS const DI SINI & panggil fungsi biasa
          page: () => CatatanScreen(),
          binding: NoteBinding(),
        ),
      ],
    );
  }
}