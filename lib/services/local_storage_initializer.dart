// lib/services/local_storage_initializer.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageInitializer {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    // 1. Inisialisasi Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // 2. Daftarkan Hive Adapter (Wajib)
    if (!Hive.isAdapterRegistered(0)) { // 0 adalah typeId dari NoteModel
      Hive.registerAdapter(NoteModelAdapter());
    }

    // 3. Buka Box/Tabel Hive yang diperlukan
    await Hive.openBox<NoteModel>('notesBox');

    // 4. Inisialisasi SharedPreferences
    sharedPreferences = await SharedPreferences.getInstance();
  }
}