import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart'; // Uncomment jika ingin pakai url_launcher

// Warna primer (bisa diambil dari theme nanti)
const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF);

// --- Model Data untuk Riwayat Transaksi ---
class TransactionHistory {
  final String productName;
  final String status;
  final String transactionLink;
  final String imageUrl;

  TransactionHistory({
    required this.productName,
    required this.status,
    required this.transactionLink,
    required this.imageUrl,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      productName: json['nama_barang'] ?? 'Produk Tidak Dikenal',
      status: json['status_bayar'] ?? 'N/A',
      transactionLink: json['link_transaksi'] ?? '#',
      imageUrl: json['url_gambar_produk'] ?? '',
    );
  }
}

class HistoryScreen extends StatefulWidget {
  // Terima ID User & Token User (contoh, idealnya dari state management)
  final String idUser;
  final String tokenUser;

  const HistoryScreen({
    super.key,
    this.idUser = "ID_USER_ANDA", // GANTI INI
    this.tokenUser = "TOKEN_USER_ANDA", // GANTI INI
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Variabel API (dari script Anda)
  final String _apiToken = "eyJhcHAiOiIxMDI5NTkiLCJhdXRoIjoiMjAyMjA1MTUiLCJzaWduIjoiWjhUUWgzRktGY2FIYzJcL3BlVkIrY3c9PSJ9";

  List<TransactionHistory> _allTransactions = [];
  List<TransactionHistory> _filteredTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi fetch data riwayat
  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse(
        'https://openapi.bukaolshop.net/v1/user/transaksi?token=$_apiToken&token_user=${widget.tokenUser}&id_user=${widget.idUser}');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _allTransactions = (data['data'] as List)
                .map((item) => TransactionHistory.fromJson(item))
                .toList();
            _filteredTransactions = _allTransactions; // Awalnya tampilkan semua
            _isLoading = false;
          });
        } else {
          setState(() {
            _allTransactions = [];
            _filteredTransactions = [];
            _isLoading = false;
            // Tidak perlu error jika data kosong, tampilkan placeholder
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat riwayat (Error: ${response.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Terjadi kesalahan jaringan.";
      });
    }
  }

  // Fungsi filter pencarian
  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        // Cari berdasarkan nama produk atau status
        return tx.productName.toLowerCase().contains(query) ||
            tx.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Widget untuk item transaksi
  Widget _buildHistoryItem(BuildContext context, TransactionHistory tx) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              tx.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.contain, // Agar gambar tidak terdistorsi
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50, height: 50,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                );
              },
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${tx.status}",
                    style: TextStyle(fontSize: 14, color: _getStatusColor(tx.status)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            TextButton(
              child: const Text("Cek", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                print("Membuka: ${tx.transactionLink}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Membuka link transaksi...')),
                );
                // final Uri url = Uri.parse(tx.transactionLink);
                // launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk warna status
  Color _getStatusColor(String status) {
    // Sesuaikan warna berdasarkan kemungkinan status dari API Anda
    status = status.toLowerCase();
    if (status.contains('sukses') || status.contains('paid') || status.contains('success')) {
      return Colors.green;
    } else if (status.contains('gagal') || status.contains('failed') || status.contains('cancel')) {
      return Colors.red;
    } else if (status.contains('pending') || status.contains('menunggu')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  // Widget untuk placeholder "Tidak ada riwayat"
  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
              "https://i.ibb.co/9H9Pfd4/images-3-1-removebg-preview.png",
              width: 80, height: 80,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.history_toggle_off, size: 80, color: Colors.grey)
          ),
          const SizedBox(height: 10),
          const Text("Tidak ada transaksi ditemukan."),
        ],
      ),
    );
  }

  // Widget untuk loading indicator
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Widget untuk pesan error
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              onPressed: _fetchHistory, // Panggil fetch ulang
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan status bar height untuk padding
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: Column( // Column utama
        children: [
          // --- Header dengan Search Bar (Sticky) ---
          Container(
            color: primaryColor, // Background header
            padding: EdgeInsets.only(
                top: statusBarHeight + 10, // Padding atas
                left: 15, right: 15, bottom: 15
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari transaksi...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // Hapus border
                ),
                isDense: true,
              ),
            ),
          ),

          // --- Konten (List atau Placeholder) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0), // Padding untuk list
              child: _isLoading
                  ? _buildLoading()
                  : _errorMessage != null
                  ? _buildError(_errorMessage!)
                  : _filteredTransactions.isEmpty
                  ? _buildNoData()
                  : ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(context, _filteredTransactions[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}