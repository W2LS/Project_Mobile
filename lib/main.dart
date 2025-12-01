// Inisialisasi Klien Supabase
// Menghubungkan aplikasi Flutter ke backend Supabase menggunakan URL dan Anon Key Anda.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🔥 KOREKSI PATH 🔥
// Menggunakan path yang benar: lib/data/services/...
//import 'data/services/local_storage_initializer.dart';
import 'data/services/location_service.dart'; // <-- Service Lokasi

// 🔥 HAPUS IMPOR LAMA YANG MENYEBABKAN ERROR 🔥
// import 'controller/alamat_controller.dart';
// import 'views/alamat_view.dart';


import 'core/main_scaffold.dart';
import 'controller/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'bindings/note_binding.dart';
import 'features/history/catatan_screen.dart';

// Warna utama
const Color subMainColor = Color(0xFF42A5F5);

// Global accessor untuk klien Supabase
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi LOCAL STORAGE (Hive & SharedPreferences)
  //await LocalStorageInitializer.init();

  // 2. Inisialisasi SUPABASE (Cloud Storage)
  await Supabase.initialize(
    url: 'https://anmwxheszygjldayfhvk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubXd4aGVzenlnamxkYXlmaHZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzOTMzMDUsImV4cCI6MjA3ODk2OTMwNX0.Eeli4GoGAsSyaUQbDfxoVyZbGs6XCp7H_XjpLuo5Ucw',
  );

  // 🔥🔥🔥 DAFTARKAN SERVICES PERMANEN 🔥🔥🔥
  // 1. LocationService
  Get.put<LocationService>(LocationService());

  // 2. Tidak ada AlamatController lagi yang didaftarkan secara permanen di sini
  // Navigasi location diurus oleh Binding di AccountScreen.

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

      initialRoute: '/home',

      getPages: [
        GetPage(
            name: '/login',
            page: () => LoginScreen(),
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
          page: () => CatatanScreen(),
          binding: NoteBinding(),
        ),

        // Hapus GetPage('/alamat')
      ],
    );
  }
}