import 'package:get/get.dart';
import '../services/api_service.dart';

class KategoriEwalletController extends GetxController {
  var searchQuery = ''.obs;
  var httpResponseTime = ''.obs;
  var dioResponseTime = ''.obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  final List<Map<String, String>> allEwallet = [
    {
      'nama': 'Dana',
      'img': 'https://assets.jalantikus.com/assets/cache/40/40/apps/2019/04/26/dana-1dd40.png',
      'url': 'https://kobodev.my.id/digital/257039'
    },
    {
      'nama': 'Gopay',
      'img': 'https://www.pointstar-consulting.com/wp-content/uploads/2022/02/gopay-integration.png',
      'url': 'https://kobodev.my.id/digital/257041'
    },
    {
      'nama': 'OVO',
      'img': 'https://1.bp.blogspot.com/-ghHXZ-ZGE20/YNXzNQAAxpI/AAAAAAAABC0/-I--vr9AifMIX1MJKn2LJPfcX6ikMd7-QCLcBGAsYHQ/w320-h311/IMG_20210625_221444.jpg',
      'url': 'https://kobodev.my.id/digital/257040'
    },
    {
      'nama': 'Shopeepay',
      'img': 'https://cdn.haitrieu.com/wp-content/uploads/2022/10/Logo-ShopeePay-V.png',
      'url': 'https://kobodev.my.id/digital/257042'
    },
    {
      'nama': 'LinkAja',
      'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/LinkAja.svg/2048px-LinkAja.svg.png',
      'url': 'https://kobodev.my.id/digital/257045'
    },
  ];

  List<Map<String, String>> get filteredEwallet => allEwallet
      .where((item) => item['nama']!.toLowerCase().contains(searchQuery.value.toLowerCase()))
      .toList();

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  /// 🔍 Eksperimen: Bandingkan waktu respon API HTTP vs Dio
  Future<void> testApiSpeed() async {
    isLoading.value = true;

    // Test HTTP biasa
    final httpData = await _apiService.fetchProductsHttp();
    httpResponseTime.value = _apiService.lastHttpDuration;

    // Test Dio
    final dioData = await _apiService.fetchProductsDio();
    dioResponseTime.value = _apiService.lastDioDuration;

    isLoading.value = false;

    print("HTTP result count: ${httpData.length}");
    print("Dio result count: ${dioData.length}");
  }
}
