// lib/features/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';

const Color subMainColor = Color(0xFF42A5F5); // Warna Biru utama

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Header (Sama dengan Login Screen) ---
            _buildCustomHeader(context),
            const SizedBox(height: 30),

            // --- "Create Account" Text ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Form Input Register ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // 1. Username
                  _buildInputField(
                    "Username",
                    Icons.person,
                    controller.usernameRegisterController,
                    false,
                  ),
                  const SizedBox(height: 20),

                  // 2. Email
                  _buildInputField(
                    "Email",
                    Icons.email,
                    controller.emailRegisterController,
                    false,
                    TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // 3. Password
                  _buildInputField(
                    "Password",
                    Icons.lock,
                    controller.passwordRegisterController,
                    true,
                  ),
                  const SizedBox(height: 20),

                  // 4. Repeat Password
                  _buildInputField(
                    "Repeat password",
                    Icons.lock_outline,
                    controller.confirmPasswordRegisterController,
                    true,
                  ),
                  const SizedBox(height: 20),

                  // 5. Terms and Conditions Checkbox
                  Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: controller.isAgreedToTerms.value,
                        onChanged: controller.toggleTerms,
                        activeColor: subMainColor,
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            "I agree to the Terms and Conditions.",
                            style: TextStyle(fontSize: 13, fontFamily: 'PlusJakartaSans'),
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 30),

                  // --- Tombol SIGN UP ---
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subMainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SIGN UP", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'PlusJakartaSans')),
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

                  // ❌ Tombol Sign In Link Dihilangkan di sini

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
          // Tombol Back
          Positioned(
            top: 40,
            left: 15,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget untuk Input Field ---
  Widget _buildInputField(String hintText, IconData icon, TextEditingController controller, bool isPassword, [TextInputType keyboardType = TextInputType.text]) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
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