import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/kategori_ewallet_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class EwalletScreen extends StatelessWidget {
  const EwalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KategoriEwalletController());

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        title: const Text("Pilih E-Wallet"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          // 🧠 Tombol Eksperimen API
          Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(() {
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.testApiSpeed(),
                    icon: const Icon(Icons.api),
                    label: controller.isLoading.value
                        ? const Text("Sedang memproses...")
                        : const Text("Coba Bandingkan API (HTTP vs Dio)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (controller.httpResponseTime.isNotEmpty &&
                      controller.dioResponseTime.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text("⏱ Hasil Uji Kecepatan API", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text("HTTP Response Time: ${controller.httpResponseTime.value}"),
                          Text("Dio Response Time: ${controller.dioResponseTime.value}"),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ),

          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Cari e-wallet...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                onChanged: controller.updateSearch,
              ),
            ),
          ),

          // 🔁 List E-Wallet
          Expanded(
            child: Obx(() {
              final data = controller.filteredEwallet;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: InkWell(
                      onTap: () async {
                        final url = Uri.parse(item['url']!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          Get.snackbar("Error", "Tidak dapat membuka link");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                item['img']!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                item['nama']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF42A5F5),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Pilih Ewallet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
