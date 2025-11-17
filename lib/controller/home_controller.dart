// lib/controller/home_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import Layar untuk Navigasi (Harus ada untuk Get.to)
import '/features/history/mutasi_screen.dart';
import '/features/top_up/isi_saldo_screen.dart';
import '/features/product/pulsa_screen.dart';
import '/features/product/game_category_screen.dart';
import '/features/product/internet_category_screen.dart';
import '/features/product/tagihan_screen.dart';
import '/features/product/ewallet_screen.dart';
// Note: CatatanScreen tidak perlu di-import di sini jika menggunakan Get.toNamed('/notes')


class HomeController extends GetxController {
  // --- STATE (Rx variables dari HomeScreen lama) ---
  var greeting = "".obs;
  // Gunakan data hardcode dari HomeScreen lama sebagai placeholder
  var saldoUser = 1250000.0.obs;
  var namaUser = "User Luminae".obs;
  var fotoProfil = "https://via.placeholder.com/150".obs;
  var isOnline = true.obs;

  // Untuk dynamic text animation
  final List<String> _words1 = ["Instan", "Otomatis", "Aman"];
  final List<String> _words2 = ["Saldo", "Mudah", "Aman"];
  var currentIndex1 = 0.obs;
  var currentIndex2 = 0.obs;
  Timer? _timer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    _setGreeting();
    _startTextAnimation();
    _checkInitialConnection();
    _listenToConnectivity();
    // Anda bisa tambahkan loadUserData() di sini nanti
  }

  @override
  void onClose() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  // --- LOGIC METHODS ---

  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      isOnline.value = (result != ConnectivityResult.none);
    });
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    isOnline.value = (connectivityResult != ConnectivityResult.none);
  }

  void _setGreeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 7)).hour;
    if (hour >= 4 && hour < 10) greeting.value = "Selamat pagi,";
    else if (hour >= 10 && hour < 15) greeting.value = "Selamat siang,";
    else if (hour >= 15 && hour < 18) greeting.value = "Selamat sore,";
    else greeting.value = "Selamat malam,";
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      currentIndex1.value = (currentIndex1.value + 1) % _words1.length;
      currentIndex2.value = (currentIndex2.value + 1) % _words2.length;
    });
  }

  String get dynamicText1 => _words1[currentIndex1.value];
  String get dynamicText2 => _words2[currentIndex2.value];

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  // --- NAVIGASI DAN PENGGANTI PARAMETER LAMA ---

  void navigateTo(String routeName) {
    switch (routeName) {
    // 🔥 PERBAIKAN UTAMA: Arahkan ke rute /notes yang sudah diconfigure binding-nya 🔥
      case 'CatatanScreen':
        Get.toNamed('/notes');
        break;

      case 'MutasiSaldoScreen':
      // Navigasi ke rute yang masih menggunakan widget lama, tapi tanpa parameter yang hilang
        Get.to(() => MutasiSaldoScreen(
          idUser: "ID_USER_ANDA", // Hardcode placeholder sementara
          tokenUser: "TOKEN_USER_ANDA",
          namaUser: namaUser.value,
          saldoUser: saldoUser.value,
          fotoProfil: fotoProfil.value,
        ));
        break;
      case 'IsiSaldoScreen':
        Get.to(() => IsiSaldoScreen(saldoUser: saldoUser.value));
        break;

    // Navigasi ke menu produk/layanan
      case 'PulsaScreen':
        Get.to(() => const PulsaScreen());
        break;
      case 'InternetCategoryScreen':
        Get.to(() => const InternetCategoryScreen());
        break;
      case 'GameCategoryScreen':
        Get.to(() => const GameCategoryScreen());
        break;
      case 'TagihanScreen':
        Get.to(() => const TagihanScreen());
        break;
      case 'EwalletScreen':
        Get.to(() => const EwalletScreen());
        break;
      default:
        Get.snackbar("Info", "Halaman $routeName belum tersedia.");
        break;
    }
  }
}