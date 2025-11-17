import 'package:get/get.dart';

class KategoriTagihanController extends GetxController {
  // List semua kategori
  final List<Map<String, String>> _kategori = [
    {
      "nama": "PDAM",
      "img":
      "https://play-lh.googleusercontent.com/qRt31-ItSjuMMtqMvaZXV1_SYXFKtqGRA8cEFdQjSV7BFEHzx3TTCK4EebX_9gHN_Dk",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "Listrik PLN",
      "img":
      "https://play-lh.googleusercontent.com/C_ABhRDwsX3DW8xmfPiukQCIcjTWL5O18IdszUSYL5FqT142eNKSZsMcwRd4djMUDIY",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "BPJS Kesehatan",
      "img":
      "https://www.swarapublik.com/wp-content/uploads/2023/08/photo.jpg",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "BPJS Ketenagakerjaan",
      "img":
      "https://lh3.googleusercontent.com/iNA5reAlJ2pYEnrI0xjU8vIHTuAcJgJKenaO9EIkwsAVD-qTBI9iHhikYSF7g129RQ",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "TV Pascabayar",
      "img":
      "https://static.vecteezy.com/system/resources/thumbnails/007/688/855/small_2x/tv-logo-free-vector.jpg",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "Internet / Wifi",
      "img":
      "https://i.pinimg.com/736x/e6/14/81/e61481c0d5df8baddc2c9fdf1f38a3ee.jpg",
      "url": "https://kobodev.my.id/digital/257023"
    },
    {
      "nama": "Multifinance",
      "img":
      "https://cdn.icon-icons.com/icons2/1149/PNG/512/1486504348-business-coins-finance-banking-bank-marketing_81341.png",
      "url": "https://kobodev.my.id/digital/257023"
    },
  ];

  // Text pencarian
  var searchText = ''.obs;

  // Getter hasil filter
  List<Map<String, String>> get filteredKategori {
    if (searchText.isEmpty) return _kategori;
    return _kategori
        .where((item) => item['nama']!
        .toLowerCase()
        .contains(searchText.value.toLowerCase()))
        .toList();
  }

  // Update teks pencarian
  void updateSearch(String text) {
    searchText.value = text;
  }
}
