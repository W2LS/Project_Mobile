import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Konstanta Warna & API (sesuaikan jika perlu) ---
const Color primaryColor = Color(0xFF6495ED); // Warna biru dari CSS
const Color screenBackgroundColor = Color(0xFFF0F8FF); // Background utama
const String openApiToken = "eyJhcHAiOiIxMDI5NTkiLCJhdXRoIjoiMjAyMjA1MTUiLCJzaWduIjoiWjhUUWgzRktGY2FIYzJcL3BlVkIrY3c9PSJ9";

// --- Model Data Produk (Sederhana) ---
class Product {
  final String name;
  final String shortDesc;
  final String price;
  final String originalPrice;
  final String imageUrl;
  final String detailDesc;
  final String purchaseUrl;

  Product({
    required this.name,
    required this.shortDesc,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.detailDesc,
    required this.purchaseUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['nama_produk'] ?? 'N/A',
      shortDesc: json['deskripsi_singkat'] ?? '',
      price: json['harga_produk'] ?? '0',
      originalPrice: json['harga_produk_asli'] ?? '0',
      imageUrl: json['url_gambar_produk'] ?? '',
      detailDesc: json['deskripsi_panjang'] ?? '',
      purchaseUrl: json['url_produk'] ?? '#',
    );
  }
}

// --- Data Operator (Hanya pakai Idkategori1) ---
// --- PENTING: LENGKAPI DATA INI DARI FILE HTML ANDA ---
const List<Map<String, dynamic>> kategoriData = [
  {
    "Idkategori1": "664083", // ID Reguler Telkomsel
    "provider": "Telkomsel",
    "nomorpemanggil": ["0811", "0812", "0813", "0821", "0822", "0852", "0853", "0823", "0851"]
  },
  {
    "Idkategori1": "529222", // ID Reguler Tri
    "provider": "Tri",
    "nomorpemanggil": ["0895", "0896", "0897", "0898", "0899"]
  },
  {
    "Idkategori1": "664083", // ID Reguler Axis (Sama dengan Tsel di data Anda?) -> Sesuaikan jika ID beda
    "provider": "Axis",
    "nomorpemanggil": ["0838", "0831", "0832", "0833"]
  },
  {
    "Idkategori1": "529287", // ID Reguler Indosat
    "provider": "Indosat",
    "nomorpemanggil": ["0814", "0815", "0816", "0855", "0856", "0857", "0858"]
  },
  {
    "Idkategori1": "529114", // ID Reguler XL
    "provider": "XL Axiata",
    "nomorpemanggil": ["0818", "0817", "0819", "0859", "0877", "0878"]
  },
  {
    "Idkategori1": "114413", // ID Reguler Smartfren
    "provider": "Smartfren",
    "nomorpemanggil": ["0881", "0882", "0883", "0884", "0885", "0886", "0887", "0888", "0889"]
  },
  {
    "Idkategori1": "529247", // ID Reguler Byu
    "provider": "Byu",
    "nomorpemanggil": ["085154", "085155", "085156", "085157", "085158", "085159", "085160", "085161", "085162", "085163", "085171", "085172", "085173", "085174", "085175", "085176", "085177", "085178", "085179", "085180"]
  },
];
// --- BATAS DATA OPERATOR ---

class PulsaScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const PulsaScreen({super.key, this.initialPhoneNumber});

  @override
  State<PulsaScreen> createState() => _PulsaScreenState();
}

class _PulsaScreenState extends State<PulsaScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  String _detectedProvider = "Pulsa All Operator";
  String _activeCategoryApiId = "";
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];
  bool _isGridView = true;
  List<String> _favoriteNumbers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      _phoneController.text = widget.initialPhoneNumber!;
      _detectOperatorAndFetch(widget.initialPhoneNumber!);
    }
    _loadPreferences();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isGridView = (prefs.getString('pulsaViewMode') ?? 'grid') == 'grid';
      _favoriteNumbers = prefs.getStringList('favoritePulsaNumbers') ?? [];
    });
  }

  Future<void> _saveViewMode(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pulsaViewMode', isGrid ? 'grid' : 'list');
  }

  Future<void> _saveFavorite() async {
    final number = _phoneController.text.trim();
    if (number.isNotEmpty && !_favoriteNumbers.contains(number)) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _favoriteNumbers.add(number);
        prefs.setStringList('favoritePulsaNumbers', _favoriteNumbers);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor $number disimpan ke favorit.'), backgroundColor: Colors.green),
        );
        _phoneController.clear();
        _products = [];
        _detectedProvider = "Pulsa All Operator";
      });
    } else if (_favoriteNumbers.contains(number)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor sudah ada di favorit.'), backgroundColor: Colors.orange),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor HP dulu.'), backgroundColor: Colors.red),
      );
    }
  }

  // --- Fungsi untuk menghapus nomor dari favorit (PERBAIKAN) ---
  Future<void> _deleteFavorite(String numberToDelete) async { // <-- numberToDelete didefinisikan di sini
    // Implementasi dialog konfirmasi hapus
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) { // Menggunakan dialogContext
        return AlertDialog(
          title: const Text('Hapus Favorit?'),
          content: Text('Anda yakin ingin menghapus nomor "$numberToDelete" dari favorit?'), // <-- Penggunaan numberToDelete (OK)
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Batal
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Hapus
              },
            ),
          ],
        );
      },
    );

    // Pastikan widget masih ada setelah dialog
    if(confirmDelete == true && mounted){
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return; // Cek lagi setelah await prefs
      setState(() {
        // Gunakan numberToDelete di sini (OK)
        _favoriteNumbers.remove(numberToDelete);
        prefs.setStringList('favoritePulsaNumbers', _favoriteNumbers);
      });
      // Pastikan context masih valid sebelum panggil ScaffoldMessenger
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Gunakan numberToDelete di sini (OK)
          SnackBar(content: Text('Nomor $numberToDelete dihapus.'), backgroundColor: Colors.red),
        );
      }
    }
  }
  // --- BATAS PERBAIKAN ---

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nomor disalin: $text"), backgroundColor: Colors.blue),
    );
  }

  void _detectOperatorAndFetch(String number) {
    String cleanedNumber = number.replaceAll(RegExp(r'\D'), '');
    if (cleanedNumber.startsWith('62')) {
      cleanedNumber = '0${cleanedNumber.substring(2)}';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_phoneController.text != cleanedNumber && mounted) {
        _phoneController.value = TextEditingValue(
          text: cleanedNumber,
          selection: TextSelection.collapsed(offset: cleanedNumber.length),
        );
      }
    });

    if (cleanedNumber.length < 4) {
      if (mounted) {
        setState(() {
          _detectedProvider = "Pulsa All Operator";
          _products = [];
          _activeCategoryApiId = "";
          _errorMessage = null;
        });
      }
      return;
    }

    Map<String, dynamic>? detectedOperatorData;
    String? longestMatchPrefix;

    for (var operatorData in kategoriData) {
      List<String> prefixes = List<String>.from(operatorData['nomorpemanggil']);
      for (var prefix in prefixes) {
        if (cleanedNumber.startsWith(prefix)) {
          if (longestMatchPrefix == null || prefix.length > longestMatchPrefix.length) {
            longestMatchPrefix = prefix;
            detectedOperatorData = operatorData;
          }
        }
      }
    }

    if (mounted) {
      if (detectedOperatorData != null) {
        String newApiId = detectedOperatorData['Idkategori1'] ?? "";

        setState(() {
          _detectedProvider = detectedOperatorData!['provider'] ?? "Operator Unknown";
          if (newApiId != _activeCategoryApiId || _products.isEmpty) {
            _activeCategoryApiId = newApiId;
            if (_activeCategoryApiId.isNotEmpty) {
              _fetchProducts(_activeCategoryApiId);
            } else {
              _products = [];
              _errorMessage = "Produk reguler tidak tersedia untuk operator ini.";
            }
          } else {
            _errorMessage = null;
          }
        });

      } else {
        setState(() {
          _detectedProvider = "Operator Tidak Dikenal";
          _products = [];
          _activeCategoryApiId = "";
          _errorMessage = "Nomor tidak dikenali.";
        });
      }
    }
  }

  Future<void> _fetchProducts(String categoryId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
    });

    final url = Uri.parse(
        "https://openapi.bukaolshop.net/v1/app/produk?token=$openApiToken&id_kategori=$categoryId&page=1");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _products = data.map((item) => Product.fromJson(item)).toList();
          _products.sort((a, b) => (double.tryParse(a.price) ?? 0).compareTo(double.tryParse(b.price) ?? 0));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat produk (Error: ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Terjadi kesalahan jaringan.";
        _isLoading = false;
      });
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      _saveViewMode(_isGridView);
    });
  }

  void _showProductModal(Product product) {
    String formattedPrice = _currencyFormat.format(double.tryParse(product.price) ?? 0);
    String purchaseLink = "${product.purchaseUrl}?catatan=${Uri.encodeComponent(_phoneController.text)}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16, right: 16, top: 16
          ),
          child: Wrap(
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
              ),
              const Center(child: Text("Detail Produk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const Divider(height: 20),
              Table(
                columnWidths: const { 0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                children: [
                  TableRow(children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("No Tujuan:", style: TextStyle(color: Colors.grey))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(_phoneController.text, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                  TableRow(children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Produk:", style: TextStyle(color: Colors.grey))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(product.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                  TableRow(children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Harga:", style: TextStyle(color: Colors.grey))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(formattedPrice, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
                  ]),
                ],
              ),
              if (product.detailDesc.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text("Deskripsi:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text(product.detailDesc),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Kembali"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(purchaseLink);
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          if(mounted){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tidak bisa membuka link: $purchaseLink'), backgroundColor: Colors.red),
                            );
                          }
                        } else {
                          if(mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Proses"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFavoritesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16, right: 16, top: 16
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                    ),
                    const Text("Nomor Favorit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _favoriteNumbers.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Text("Belum ada nomor favorit."),
                    )
                        : Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _favoriteNumbers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (context, index) {
                          final number = _favoriteNumbers[index];
                          return ListTile(
                            dense: true,
                            title: Text(number),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                // Panggil _deleteFavorite DARI LUAR MODAL
                                // karena _deleteFavorite butuh akses SharedPreferences
                                // dan setState utama
                                _deleteFavorite(number).then((_) {
                                  // Refresh list di modal setelah hapus berhasil
                                  modalSetState(() {});
                                });
                              },
                            ),
                            onTap: () {
                              _copyToClipboard(number);
                              _phoneController.text = number;
                              _detectOperatorAndFetch(number);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 150 + 10.0),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildProductList(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          Positioned(
            top: statusBarHeight + 60,
            left: 16,
            right: 16,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_detectedProvider, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Masukkan nomor telepon",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.phone_android_outlined),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                ),
                                onChanged: _detectOperatorAndFetch,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
                              onPressed: _toggleViewMode,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Kontak belum diimplementasi.')));
                          },
                          icon: const Icon(Icons.contact_phone_outlined, size: 18),
                          label: const Text("Kontak"),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Scan belum diimplementasi.')));
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 18),
                          label: const Text("Scan"),
                        ),
                        TextButton.icon(
                          onPressed: _showFavoritesModal,
                          icon: const Icon(Icons.favorite_border, size: 18),
                          label: const Text("Favorite"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26), // <-- Ubah warna & ukuran
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,));
    }
    if (_phoneController.text.isEmpty || _activeCategoryApiId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network("https://i.ibb.co/R3n0187/undraw-Note-list-re-r4u9-2.png", width: 150, errorBuilder: (c,e,s)=> Icon(Icons.phone_android, size: 80, color: Colors.grey[300])),
            const SizedBox(height: 10),
            const Text("Masukkan Nomor HP"),
          ],
        ),
      );
    }
    if (!_isLoading && _products.isEmpty && _activeCategoryApiId.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network("https://i.ibb.co/R3n0187/undraw-Note-list-re-r4u9-2.png", width: 150, errorBuilder: (c,e,s)=> Icon(Icons.search_off, size: 80, color: Colors.grey[300])),
            const SizedBox(height: 10),
            Text("Produk untuk $_detectedProvider\ntidak ditemukan.", textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isGridView ? 2 : 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: _isGridView ? (1 / 0.8) : (1 / 0.25),
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        String displayPrice = _currencyFormat.format(double.tryParse(product.price) ?? 0);

        return InkWell(
          onTap: () => _showProductModal(product),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis,),
                      if (product.shortDesc.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(product.shortDesc, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(displayPrice, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
} // <-- Akhir class _PulsaScreenState