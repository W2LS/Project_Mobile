import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class TagihanScreen extends StatefulWidget {
  const TagihanScreen({super.key});

  @override
  State<TagihanScreen> createState() => _TagihanScreenState();
}

class _TagihanScreenState extends State<TagihanScreen> {
  // --- State ---
  bool isLoading = true;
  bool isError = false;
  List<String> tagihanList = [];

  @override
  void initState() {
    super.initState();
    _loadTagihanData(); // Panggil fungsi async saat halaman dibuka
  }

  // --- Fungsi Async untuk simulasi fetch data ---
  Future<void> _loadTagihanData() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      // Simulasi delay seolah ambil data dari API
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi kemungkinan error (acak 30%)
      final random = Random().nextInt(10);
      if (random < 3) throw Exception("Koneksi gagal, coba lagi ya!");

      // Kalau sukses, isi data dummy
      tagihanList = [
        "Tagihan Listrik",
        "Tagihan Air",
        "Tagihan Internet",
        "Tagihan Telepon",
        "Tagihan TV Kabel"
      ];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });

      // Tampilkan snackbar error GetX
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  ///  Eksperimen 1: Async–Await berurutan (chained)
  Future<void> _testChainedAsync() async {
    Get.snackbar("Eksperimen", "Mulai percobaan async–await berurutan...",
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);

    try {
      // Step 1: simulasi ambil daftar tagihan
      print(" [ASYNC] Mengambil daftar tagihan...");
      await Future.delayed(const Duration(seconds: 2));
      print(" [ASYNC] Daftar tagihan berhasil diambil.");

      // Step 2: ambil detail tagihan pertama
      print(" [ASYNC] Mengambil detail tagihan pertama...");
      await Future.delayed(const Duration(seconds: 2));
      print(" [ASYNC] Detail tagihan berhasil diambil.");

      Get.snackbar(
        "Selesai (Async–Await)",
        "Semua proses async–await selesai berurutan ✅",
        backgroundColor: Colors.greenAccent.withOpacity(0.8),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  ///  Eksperimen 2: Callback Chaining (fungsi bersarang)
  void _testCallbackChaining() {
    Get.snackbar("Eksperimen", "Mulai percobaan callback chaining...",
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);

    print(" [CALLBACK] Mengambil daftar tagihan...");
    Future.delayed(const Duration(seconds: 2)).then((_) {
      print(" [CALLBACK] Daftar tagihan berhasil diambil.");

      print(" [CALLBACK] Mengambil detail tagihan pertama...");
      Future.delayed(const Duration(seconds: 2)).then((_) {
        print(" [CALLBACK] Detail tagihan berhasil diambil.");

        Get.snackbar(
          "Selesai (Callback)",
          "Semua proses callback chaining selesai ",
          backgroundColor: Colors.lightGreen.withOpacity(0.8),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }).catchError((error) {
        print("❌ [CALLBACK] Error detail tagihan: $error");
      });
    }).catchError((error) {
      print("❌ [CALLBACK] Error daftar tagihan: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        title: const Text("Kategori Tagihan"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Muat Ulang",
            onPressed: _loadTagihanData, // bisa refresh manual
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: "Coba Async–Await",
            onPressed: _testChainedAsync,
          ),
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: "Coba Callback",
            onPressed: _testCallbackChaining,
          ),
        ],
      ),
      body: Center(
        child: _buildBodyContent(),
      ),
    );
  }

  // --- Fungsi untuk menampilkan tampilan sesuai kondisi ---
  Widget _buildBodyContent() {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF42A5F5)),
          SizedBox(height: 10),
          Text("Memuat data tagihan...", style: TextStyle(fontSize: 14)),
        ],
      );
    }

    if (isError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.redAccent, size: 60),
          const SizedBox(height: 10),
          const Text(
            "Gagal memuat data.\nCoba tekan refresh 🔄",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _loadTagihanData,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
            ),
          )
        ],
      );
    }

    // Kalau sukses tampilkan data
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tagihanList.length,
      itemBuilder: (context, index) {
        final item = tagihanList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Color(0xFF42A5F5)),
            title: Text(item,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: const Text("Klik untuk melihat detail tagihan"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Get.snackbar(
                "Tagihan Dipilih",
                "Kamu memilih $item",
                backgroundColor: Colors.blueAccent.withOpacity(0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        );
      },
    );
  }
}
