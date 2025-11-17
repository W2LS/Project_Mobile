// lib/controller/auth_controller.dart
// Semua logika login dan register menggunakan client Supabase.
// Mengelola sesi pengguna, login, register, dan logout.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <<< Tambahkan Supabase
import '../features/auth/register_screen.dart';
// Asumsi final supabase didefinisikan di main.dart
final supabase = Supabase.instance.client;


class AuthController extends GetxController {
  // State untuk UI dan Validasi
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // State untuk Checkbox
  var rememberMe = false.obs;
  var isAgreedToTerms = false.obs;

  // Variabel untuk Form Login
  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();

  // Variabel untuk Form Register
  final emailRegisterController = TextEditingController();
  final usernameRegisterController = TextEditingController();
  final passwordRegisterController = TextEditingController();
  final phoneRegisterController = TextEditingController();
  final confirmPasswordRegisterController = TextEditingController();

  // --- LOGIC AUTENTIKASI ---

  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = '';

    if (emailLoginController.text.isEmpty || passwordLoginController.text.isEmpty) {
      errorMessage.value = 'Email/Username dan Password tidak boleh kosong.';
      isLoading.value = false;
      return;
    }

    // Validasi: Minimal 8 karakter
    if (passwordLoginController.text.length < 8) {
      errorMessage.value = 'Password harus minimal 8 karakter.';
      isLoading.value = false;
      return;
    }

    // 🔥 IMPLEMENTASI LOGIN SUPABASE 🔥
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text.trim(),
      );

      if (response.user != null) {
        Get.snackbar('Berhasil', 'Login sukses untuk ${response.user!.email}', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed('/home'); // Navigasi ke halaman utama
      }
    } on AuthException catch (e) {
      errorMessage.value = 'Login Gagal: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Kesalahan tak terduga: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Validasi Password
    if (passwordRegisterController.text != confirmPasswordRegisterController.text) {
      errorMessage.value = 'Password dan Konfirmasi Password tidak cocok.';
      isLoading.value = false;
      return;
    }

    // Validasi: Minimal 8 karakter
    if (passwordRegisterController.text.length < 8) {
      errorMessage.value = 'Password harus minimal 8 karakter.';
      isLoading.value = false;
      return;
    }

    // VALIDASI Terms and Conditions
    if (!isAgreedToTerms.value) {
      errorMessage.value = 'Anda harus menyetujui Syarat & Ketentuan.';
      isLoading.value = false;
      return;
    }

    // 🔥 IMPLEMENTASI REGISTER SUPABASE 🔥
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: emailRegisterController.text.trim(),
        password: passwordRegisterController.text.trim(),
        data: {
          'username': usernameRegisterController.text.trim(),
        },
      );

      Get.snackbar('Sukses', 'Pendaftaran berhasil! Cek email untuk verifikasi.', snackPosition: SnackPosition.BOTTOM);
      Get.offNamed('/login'); // Kembali ke halaman Login

    } on AuthException catch (e) {
      errorMessage.value = 'Pendaftaran Gagal: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Kesalahan tak terduga: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 IMPLEMENTASI LOGOUT SUPABASE 🔥
  Future<void> logout() async {
    try {
      Get.snackbar("Info", "Memproses logout...", snackPosition: SnackPosition.BOTTOM);

      await supabase.auth.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Gagal Logout: ${e.toString()}", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Navigasi
  void goToRegister() {
    Get.to(() => const RegisterScreen());
  }

  // Toggle Remember Me
  void toggleRememberMe(bool? value) {
    if (value != null) {
      rememberMe.value = value;
    }
  }

  // Toggle Terms and Conditions
  void toggleTerms(bool? value) {
    if (value != null) {
      isAgreedToTerms.value = value;
    }
  }
}