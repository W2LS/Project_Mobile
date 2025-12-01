// lib/features/history/catatan_screen.dart (FINAL CODE BENAR)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/note_controller.dart';

const Color subMainColor = Color(0xFF42A5F5);

class CatatanScreen extends StatelessWidget {
  const CatatanScreen({super.key});

  // --- Widget Utama Build ---
  @override
  Widget build(BuildContext context) {
    // Gunakan Get.find() di sini.
    final NoteController controller = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eksperimen Penyimpanan Lokal vs Cloud"),
        backgroundColor: subMainColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadNotes, // Muat ulang data (Uji Baca)
          ),
        ],
      ),
      // 🔥 PERBAIKAN: Gunakan Obx untuk merebuild seluruh body ketika state berubah 🔥
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Panggil Tabel Eksperimen
              _buildBenchmarkTable(controller), // Akan mengakses .value di dalam

              const SizedBox(height: 30),

              // 2. Daftar Notes
              Text("Daftar Catatan (${controller.notes.length} item)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),

              if (controller.notes.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text("Tidak ada catatan. Tambahkan satu untuk menguji tulis/baca!"),
                )),

              // Notes List
              ...controller.notes.map((note) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("ID: ${note.id.substring(0, 8)}... | Dibuat: ${note.createdAt.day}/${note.createdAt.month}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteNote(note.id),
                    ),
                    onTap: () {
                      Get.defaultDialog(title: note.title, content: Text(note.content));
                    }
                ),
              )).toList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(controller),
        backgroundColor: subMainColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  // --- Widget Helper: Tabel Hasil Eksperimen (TIDAK PERLU Obx/GetBuilder) ---
  Widget _buildBenchmarkTable(NoteController controller) {
    // Karena _buildBenchmarkTable dipanggil di dalam Obx, kita bisa mengakses state langsung
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tabel Hasil Pengujian Waktu (Ms)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 15),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              border: TableBorder.symmetric(inside: const BorderSide(color: Colors.grey)),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text("Aksi", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text("Lokal (Hive)", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text("Cloud (Supabase)", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(8.0), child: Text("Waktu Tulis (Write)")),
                    // Akses nilai dengan .value (di dalam Obx)
                    Padding(padding: EdgeInsets.all(8.0), child: Text(controller.localWriteTime.value)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text(controller.cloudWriteTime.value)),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(8.0), child: Text("Waktu Baca (Read)")),
                    Padding(padding: EdgeInsets.all(8.0), child: Text(controller.localReadTime.value)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text(controller.cloudReadTime.value)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shared Prefs Switch - Diperbarui menggunakan state isDarkTheme
            const Text("Contoh Data Sederhana (Tema Gelap):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SwitchListTile(
              // 🔥 KOREKSI 1 & 2: Ganti getTheme() dengan getter isDarkTheme
              title: Text("Toggle Tema Gelap: ${controller.isDarkTheme ? 'Aktif' : 'Nonaktif'}"),

              // 🔥 KOREKSI 3: Ganti getTheme() dengan getter isDarkTheme
              value: controller.isDarkTheme,

              // 🔥 KOREKSI 4: Ganti saveTheme() dengan method toggleTheme()
              onChanged: (val) => controller.toggleTheme(val),
              dense: true,
              activeColor: subMainColor,
            )
          ],
        ),
      ),
    );
  }

  // --- Dialog Tambah Note ---
  void _showAddNoteDialog(NoteController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    Get.defaultDialog(
      title: "Tambah Catatan (Uji Tulis)",
      content: Column(
        children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul")),
          TextField(controller: contentController, decoration: const InputDecoration(labelText: "Isi Catatan")),
        ],
      ),
      textConfirm: "Simpan & Ukur Waktu",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: subMainColor,
      onConfirm: () {
        if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
          controller.saveNewNote(titleController.text, contentController.text);
          Get.back();
        } else {
          Get.snackbar("Error", "Judul dan isi tidak boleh kosong.");
        }
      },
    );
  }
}