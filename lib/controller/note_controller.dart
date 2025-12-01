// lib/controller/note_controller.dart (FINAL CODE BENAR)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/note_model.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

// 🔥 HAPUS IMPOR LAMA KARENA FILE TIDAK ADA 🔥
// import '../services/local_storage_initializer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoteController extends GetxController {
  var notes = <NoteModel>[].obs;
  var isLoading = false.obs;

  // ✅ PENGELOLAAN TEMA BARU: State Observabel untuk tema
  // Karena kita tidak bisa membaca dari local storage, kita set default false.
  final RxBool _isDarkTheme = false.obs;
  bool get isDarkTheme => _isDarkTheme.value;

  var localWriteTime = 'N/A'.obs;
  var cloudWriteTime = 'N/A'.obs;
  var localReadTime = 'N/A'.obs;
  var cloudReadTime = 'N/A'.obs;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = Uuid();

  @override
  void onInit() {
    super.onInit();
    // 💡 Tidak bisa memuat tema dari storage, gunakan default 'false'
    loadNotes();
  }

  // --- LOGIC UTAMA: MEMUAT DATA (Read) ---
  Future<void> loadNotes() async {
    isLoading.value = true;

    try {
      // 🔥 PERBAIKAN: Selalu asumsikan offline untuk melewati Supabase timeout 🔥
      bool isOnline = await _checkConnectivity();
      List<NoteModel> fetchedData = [];

      if (isOnline) {
        // 1. (DINONAKTIFKAN SEMENTARA): Baca dari Cloud
        Get.snackbar("Aksi Dinonaktifkan", "Mode Cloud Supabase dinonaktifkan untuk troubleshooting.",
            snackPosition: SnackPosition.TOP);

        // Gagal membaca dari cloud, langsung fallback ke lokal
        throw Exception("Skip Supabase"); // Lempar exception untuk masuk ke blok catch/fallback

      } else {
        // 2. Baca dari Lokal (Hive)
        final stopwatch = Stopwatch()..start();
        fetchedData = _hiveService.getNotes();
        stopwatch.stop();
        localReadTime.value = '${stopwatch.elapsedMilliseconds} ms';

        Get.snackbar("Offline Mode", "Menampilkan data dari penyimpanan lokal.", snackPosition: SnackPosition.BOTTOM);
      }

      notes.value = fetchedData;

    } catch (e) {
      // Fallback Utama ke Lokal Storage
      Get.snackbar("Lokal Fallback", "Memuat data dari Hive...", snackPosition: SnackPosition.BOTTOM);

      // Baca data lokal sebagai fallback
      final stopwatch = Stopwatch()..start();
      notes.value = _hiveService.getNotes();
      stopwatch.stop();
      localReadTime.value = '${stopwatch.elapsedMilliseconds} ms (Fallback)';

    } finally {
      // Wajib: Pastikan loading disetel false
      isLoading.value = false;
    }
  }

  // --- LOGIC UTAMA: MENYIMPAN DATA (Create/Update) ---
  Future<void> saveNewNote(String title, String content) async {
    final newNote = NoteModel(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    // 1. Simpan Lokal (Eksperimen Kecepatan Local Write)
    final localWatch = Stopwatch()..start();
    await _hiveService.saveNote(newNote);
    localWatch.stop();
    localWriteTime.value = '${localWatch.elapsedMilliseconds} ms';

    // 2. Simpan Cloud (Eksperimen Kecepatan Cloud Write)
    final isOnline = await _checkConnectivity();
    if (isOnline) {
      final cloudWatch = Stopwatch()..start();
      await _supabaseService.saveNote(newNote);
      cloudWatch.stop();
      cloudWriteTime.value = '${cloudWatch.elapsedMilliseconds} ms';
    } else {
      cloudWriteTime.value = 'Offline - Pending';
    }

    // Perbarui UI dan muat ulang data
    loadNotes();
  }

  // --- LOGIC TEMA (BARU DAN DIBENAHI) ---

  // ✅ Fungsi untuk mengganti tema (HANYA MENGUBAH STATE, TIDAK MENULIS KE STORAGE)
  void toggleTheme(bool isDark) {
    _isDarkTheme.value = isDark;

    // Perbarui GetX agar UI (GetMaterialApp) merespon perubahan tema
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

    Get.snackbar(
        "Tema Diperbarui",
        "Tema gelap: ${isDark ? 'ON' : 'OFF'}. (Tidak tersimpan permanen)",
        snackPosition: SnackPosition.BOTTOM
    );
  }

  // --- UTILITY DAN SHARED PREFERENCES ---

  void _syncToLocal(List<NoteModel> cloudNotes) {
    _hiveService.clearAll();
    for (var note in cloudNotes) {
      _hiveService.saveNote(note);
    }
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // 🔥 METHOD HILANG: deleteNote (DIBENAHI, sebelumnya ada di kode Anda)
  Future<void> deleteNote(String id) async {
    // Hapus lokal dan cloud
    await _hiveService.deleteNote(id);
    final isOnline = await _checkConnectivity();
    if (isOnline) {
      await _supabaseService.deleteNote(id);
    }
    loadNotes();
  }
}