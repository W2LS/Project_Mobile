// lib/controller/note_controller.dart

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/note_model.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_initializer.dart'; // Untuk shared_preferences
import 'package:connectivity_plus/connectivity_plus.dart'; // Digunakan untuk cek koneksi

class NoteController extends GetxController {
  // State Data
  var notes = <NoteModel>[].obs; // Daftar notes yang ditampilkan di UI
  var isLoading = false.obs;

  // State untuk Eksperimen (Waktu Eksekusi)
  var localWriteTime = 'N/A'.obs;
  var cloudWriteTime = 'N/A'.obs;
  var localReadTime = 'N/A'.obs;
  var cloudReadTime = 'N/A'.obs;

  // Services
  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = Uuid();

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  // --- LOGIC UTAMA: MEMUAT DATA (Read) ---

  Future<void> loadNotes() async {
    isLoading.value = true;

    // Asumsi: Kita cek koneksi internet
    bool isOnline = await _checkConnectivity();

    if (isOnline) {
      // 1. Baca dari Cloud (Eksperimen Kecepatan Cloud Read)
      final stopwatch = Stopwatch()..start();
      final cloudData = await _supabaseService.getNotes();
      stopwatch.stop();
      cloudReadTime.value = '${stopwatch.elapsedMilliseconds} ms';

      notes.value = cloudData;

      // Sinkronisasi data cloud ke lokal (cache)
      _syncToLocal(cloudData);

    } else {
      // 2. Baca dari Lokal (Eksperimen Kecepatan Local Read)
      final stopwatch = Stopwatch()..start();
      notes.value = _hiveService.getNotes();
      stopwatch.stop();
      localReadTime.value = '${stopwatch.elapsedMilliseconds} ms';

      Get.snackbar("Offline Mode", "Menampilkan data dari penyimpanan lokal.", snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
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

  // --- UTILITY DAN SHARED PREFERENCES ---

  void _syncToLocal(List<NoteModel> cloudNotes) {
    // Menghapus data lama dan menyimpan yang terbaru dari cloud ke Hive
    _hiveService.clearAll();
    for (var note in cloudNotes) {
      _hiveService.saveNote(note);
    }
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Contoh fungsi untuk SharedPreferences (Misal: Eksperimen data sederhana)
  void saveTheme(bool isDark) {
    LocalStorageInitializer.sharedPreferences.setBool('isDarkTheme', isDark);
    Get.snackbar("SharedPreferences", "Tema gelap: ${isDark ? 'ON' : 'OFF'} berhasil disimpan.", snackPosition: SnackPosition.BOTTOM);
  }

  bool getTheme() {
    // Eksperimen waktu baca shared preferences tidak diukur di sini karena sangat cepat
    return LocalStorageInitializer.sharedPreferences.getBool('isDarkTheme') ?? false;
  }

  // --- Fungsi Tambahan untuk UI ---
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