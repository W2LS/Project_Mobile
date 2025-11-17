// lib/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class HiveService {
  // Akses Box Hive yang sudah dibuka di LocalStorageInitializer
  final Box<NoteModel> notesBox = Hive.box<NoteModel>('notesBox');

  // C: Create/Add Note
  Future<void> saveNote(NoteModel note) async {
    // Menggunakan put(key, value) di mana key adalah note.id
    await notesBox.put(note.id, note);
  }

  // R: Read All Notes
  List<NoteModel> getNotes() {
    // Mengambil semua value (notes) dari box
    return notesBox.values.toList();
  }

  // U: Update Note (Sama seperti Create, karena menggunakan key yang sama)
  Future<void> updateNote(NoteModel note) async {
    await notesBox.put(note.id, note);
  }

  // D: Delete Note
  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  // Hapus semua data (Berguna untuk reset eksperimen)
  Future<int> clearAll() async {
    return await notesBox.clear();
  }
}