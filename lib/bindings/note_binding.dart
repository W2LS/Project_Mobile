// lib/bindings/note_binding.dart
import 'package:get/get.dart';
// Sesuaikan path ke controller Anda
import '../controller/note_controller.dart';

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    // Memastikan NoteController tersedia saat rute /notes diakses
    Get.lazyPut<NoteController>(() => NoteController());
  }
}