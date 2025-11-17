// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import 'register_screen.dart';

const Color subMainColor = Color(0xFF42A5F5);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Custom Header ---
            _buildCustomHeader(context),
            const SizedBox(height: 30),

            // --- "Sign In Now" Text ---
            const Text(
              "Sign In Now",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            const SizedBox(height: 30),

            // --- Form Input ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildInputField(
                    "Username / Email",
                    Icons.person,
                    controller.emailLoginController,
                    false,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    "Password",
                    Icons.lock,
                    controller.passwordLoginController,
                    true,
                  ),
                  const SizedBox(height: 20),

                  // --- Remember Me & Forgot Password ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                            activeColor: subMainColor,
                          ),
                          const Text("Remember me", style: TextStyle(fontSize: 13, fontFamily: 'PlusJakartaSans')),
                        ],
                      )),
                      TextButton(
                        onPressed: () {
                          Get.snackbar("Info", "Fitur Lupa Password belum tersedia.", snackPosition: SnackPosition.BOTTOM);
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'PlusJakartaSans'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- Tombol Sign In ---
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subMainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SIGN IN", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'PlusJakartaSans')),
                    ),
                  )),

                  // --- Error Message ---
                  Obx(() => controller.errorMessage.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'PlusJakartaSans')),
                  )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 40),

                  // --- Sign Up Link ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't you have an account? ", style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'PlusJakartaSans')),
                      TextButton(
                        onPressed: controller.goToRegister,
                        child: const Text("Sign Up from here", style: TextStyle(color: subMainColor, fontWeight: FontWeight.bold, fontFamily: 'PlusJakartaSans')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Custom Header ---
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: Get.width,
      height: 200,
      decoration: const BoxDecoration(
        color: subMainColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Icon/Logo di Tengah
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.verified_user, size: 50, color: subMainColor),
          ),
          // Tombol Back (Menggunakan Navigator.canPop(context))
          Positioned(
            top: 40,
            left: 15,
            child: SafeArea(
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Get.back();
                    }
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget untuk Input Field ---
  Widget _buildInputField(String hintText, IconData icon, TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'PlusJakartaSans'),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: subMainColor),
          suffixIcon: isPassword
              ? IconButton(
            icon: const Icon(Icons.visibility_off, color: Colors.grey),
            onPressed: () {
              // Implementasi toggle visibility
            },
          )
              : null,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'PlusJakartaSans'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }
}