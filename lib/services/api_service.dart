import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://dummyjson.com";

  /// Variabel untuk menyimpan durasi terakhir
  String lastHttpDuration = '';
  String lastDioDuration = '';

  /// 🟢 Versi 1: Fetch pakai HTTP (manual)
  Future<List<dynamic>> fetchProductsHttp() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      stopwatch.stop();

      lastHttpDuration = '${stopwatch.elapsedMilliseconds} ms';
      print('✅ [HTTP] Response Time: $lastHttpDuration');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 [HTTP] Data berhasil diambil (${data['products'].length} produk)');
        return data['products'];
      } else {
        print('⚠️ [HTTP] Status Code: ${response.statusCode}');
        throw Exception('Gagal fetch data HTTP');
      }
    } catch (e) {
      print('❌ [HTTP] Error: $e');
      return [];
    }
  }

  /// 🔵 Versi 2: Fetch pakai Dio (lebih lengkap)
  Future<List<dynamic>> fetchProductsDio() async {
    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.get('/products');
      stopwatch.stop();

      lastDioDuration = '${stopwatch.elapsedMilliseconds} ms';
      print('✅ [DIO] Response Time: $lastDioDuration');

      if (response.statusCode == 200) {
        print('📦 [DIO] Data berhasil diambil (${response.data['products'].length} produk)');
        return response.data['products'];
      } else {
        print('⚠️ [DIO] Status Code: ${response.statusCode}');
        throw Exception('Gagal fetch data Dio');
      }
    } on DioException catch (dioError) {
      print('❌ [DIO] Error DioException: ${dioError.message}');
      return [];
    } catch (e) {
      print('❌ [DIO] Error umum: $e');
      return [];
    }
  }
}
