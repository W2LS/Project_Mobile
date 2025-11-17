// lib/services/supabase_service.dart
// Database (CRUD Notes)
// Menjalankan operasi Cloud Write Time (Insert) dan Cloud Read Time (Select) yang Anda benchmark di NoteController. Row Level Security (RLS) di Supabase-lah yang memfilter data berdasarkan auth.uid().

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

// Akses Supabase client yang sudah diinisialisasi di main.dart
final supabase = Supabase.instance.client;

class SupabaseService {
  // Nama tabel yang sudah Anda buat dan atur RLS-nya
  final String _notesTable = 'notes';

  // C: Create/Add Note
  Future<NoteModel?> saveNote(NoteModel note) async {
    // Memastikan ada user yang login untuk mendapatkan user_id
    if (supabase.auth.currentUser == null) return null;

    final Map<String, dynamic> data = note.toJson();
    // Tambahkan user_id secara eksplisit (meskipun sudah ada di toJson) untuk keamanan
    data['user_id'] = supabase.auth.currentUser!.id;

    final response = await supabase
        .from(_notesTable)
        .insert(data)
        .select()
        .single(); // Ambil satu row yang baru dimasukkan

    // Konversi hasil Supabase ke model Flutter
    return NoteModel.fromJson(response);
  }

  // R: Read All Notes milik user yang sedang login
  Future<List<NoteModel>> getNotes() async {
    if (supabase.auth.currentUser == null) return [];

    // Ambil data dari tabel, filter hanya yang memiliki user_id sesuai user yang login
    final List<Map<String, dynamic>> response = await supabase
        .from(_notesTable)
        .select()
        .eq('user_id', supabase.auth.currentUser!.id) // Filter sesuai RLS
        .order('created_at', ascending: false);

    return response.map((json) => NoteModel.fromJson(json)).toList();
  }

  // U: Update Note
  Future<void> updateNote(NoteModel note) async {
    final Map<String, dynamic> data = note.toJson();

    await supabase
        .from(_notesTable)
        .update(data)
        .eq('id', note.id); // Update berdasarkan ID note
  }

  // D: Delete Note
  Future<void> deleteNote(String id) async {
    await supabase
        .from(_notesTable)
        .delete()
        .eq('id', id); // Hapus berdasarkan ID note
  }
}