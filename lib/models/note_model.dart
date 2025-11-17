// lib/models/note_model.dart

// 1. SEMUA IMPORTS (Directives)
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 2. PART Directive
part 'note_model.g.dart';

// 3. Deklarasi Global (Akses Supabase Client)
// Ini adalah definisi yang dibutuhkan oleh fungsi toJson() di bawah
final supabase = Supabase.instance.client;

// 4. Deklarasi Class
@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Untuk konversi dari Supabase/JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Untuk konversi ke Supabase/JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_id': supabase.auth.currentUser!.id,
    };
  }
}