import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Variabel warna global
const Color primaryColor = Color(0xFF42A5F5);

// --- MODEL DATA UNTUK SALDO ---
class SaldoHistory {
  final String tipeJumlah;
  final String jumlahDana;
  final String tipeMutasi;
  final String tanggal;
  final String saldoTerakhir;
  final String linkTransaksi;
  final String nomorPembayaran;

  SaldoHistory({
    required this.tipeJumlah,
    required this.jumlahDana,
    required this.tipeMutasi,
    required this.tanggal,
    required this.saldoTerakhir,
    required this.linkTransaksi,
    required this.nomorPembayaran,
  });

  factory SaldoHistory.fromJson(Map<String, dynamic> json) {
    return SaldoHistory(
      tipeJumlah: json['tipe_jumlah'] ?? 'N/A',
      jumlahDana: json['jumlah_dana'] ?? '0',
      tipeMutasi: json['tipe_mutasi'] ?? 'N/A',
      tanggal: json['tanggal'] ?? 'N/A',
      saldoTerakhir: json['saldo_terakhir'] ?? '0',
      linkTransaksi: json['link_transaksi'] ?? '#',
      nomorPembayaran: json['nomor_pembayaran'] ?? 'N/A',
    );
  }
}

// --- MODEL DATA UNTUK POIN ---
class PoinHistory {
  final String kategoriPoin;
  final String tipeJumlah;
  final String jumlahPoin;
  final String tanggalPoin;
  final String totalPoinTerakhir;
  final String linkTransaksi;

  PoinHistory({
    required this.kategoriPoin,
    required this.tipeJumlah,
    required this.jumlahPoin,
    required this.tanggalPoin,
    required this.totalPoinTerakhir,
    required this.linkTransaksi,
  });

  factory PoinHistory.fromJson(Map<String, dynamic> json) {
    return PoinHistory(
      kategoriPoin: json['kategori_poin'] ?? 'N/A',
      tipeJumlah: json['tipe_jumlah'] ?? 'N/A',
      jumlahPoin: json['jumlah_poin'] ?? '0',
      tanggalPoin: json['tanggal_poin'] ?? 'N/A',
      totalPoinTerakhir: json['total_poin_terakhir'] ?? '0',
      linkTransaksi: json['link_transaksi'] ?? '#',
    );
  }
}

class CatatanScreen extends StatefulWidget {
  // Anda perlu meneruskan data ini dari halaman sebelumnya
  final String fotoProfil;
  final String namaUser;
  final double saldoUser;
  final String idUser;
  final String tokenUser;

  const CatatanScreen({
    super.key,
    // Ganti dengan data placeholder atau data asli
    this.fotoProfil = "https://via.placeholder.com/150",
    this.namaUser = "User Luminae",
    this.saldoUser = 1250000,
    this.idUser = "ID_USER_ANDA", // PENTING: Ganti ini
    this.tokenUser = "TOKEN_USER_ANDA", // PENTING: Ganti ini
  });

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  // Variabel API (dari script Anda)
  final String _apiToken =
      "eyJhcHAiOiIxMjE3NjgiLCJhdXRoIjoiMjAyMjEyMTMiLCJzaWduIjoieUQ2UE13cTdTcGppZk1cL3ZzREJsNlE9PSJ9";

  // State management
  String _activeTab = 'saldo'; // 'saldo' or 'poin'
  bool _isLoading = true;
  List<SaldoHistory> _saldoHistoryList = [];
  List<PoinHistory> _poinHistoryList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory('saldo'); // Muat riwayat saldo saat halaman dibuka
  }

  // Fungsi untuk format mata uang
  String _formatRupiah(dynamic amount) {
    final number = double.tryParse(amount.toString()) ?? 0.0;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  // Fungsi untuk format angka biasa (poin)
  String _formatNumber(dynamic amount) {
    final number = double.tryParse(amount.toString()) ?? 0.0;
    final format = NumberFormat.decimalPattern('id_ID');
    return format.format(number);
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _fetchHistory(String type) async {
    // Jika data sudah ada, tidak perlu fetch ulang, cukup ganti tab
    if (type == 'saldo' && _saldoHistoryList.isNotEmpty) {
      setState(() => _activeTab = 'saldo');
      return;
    }
    if (type == 'poin' && _poinHistoryList.isNotEmpty) {
      setState(() => _activeTab = 'poin');
      return;
    }

    setState(() {
      _isLoading = true;
      _activeTab = type;
    });

    final String apiTipe = (type == 'saldo') ? 'saldo' : 'poin';
    final url = Uri.parse(
        'https://openapi.bukaolshop.net/v1/user/catatan?token=$_apiToken&token_user=${widget.tokenUser}&id_user=${widget.idUser}&tipe=$apiTipe');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;

        setState(() {
          if (type == 'saldo') {
            _saldoHistoryList = data.map((item) => SaldoHistory.fromJson(item)).toList();
          } else {
            _poinHistoryList = data.map((item) => PoinHistory.fromJson(item)).toList();
          }
          _isLoading = false;
        });
      } else {
        // Handle error API
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle error koneksi
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildBody(),
        ],
      ),
    );
  }

  // Widget untuk Header (Panel Info & Tabs)
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Latar belakang biru
        Container(
          height: 100, // Tinggi header
          width: double.infinity,
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        // Konten di atas latar belakang
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 40, 12, 0), // Atur padding atas untuk status bar
          child: Column(
            children: [
              // Panel Info User
              Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.fotoProfil),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Username: ${widget.namaUser}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text("Saldo Anda: ${_formatRupiah(widget.saldoUser)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Tombol Pilihan (Tabs)
              Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      _buildTabButton("saldo", "Saldo"),
                      const SizedBox(width: 10),
                      _buildTabButton("poin", "Poin"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk satu tombol tab
  Widget _buildTabButton(String id, String label) {
    bool isActive = _activeTab == id;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _fetchHistory(id),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? primaryColor : Colors.white,
          foregroundColor: isActive ? Colors.white : const Color(0xFF595959),
          elevation: isActive ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Widget untuk Body (List Transaksi)
  Widget _buildBody() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? _buildLoading()
            : _activeTab == 'saldo'
            ? _buildSaldoList()
            : _buildPoinList(),
      ),
    );
  }

  // Widget untuk list riwayat SALDO
  Widget _buildSaldoList() {
    if (_saldoHistoryList.isEmpty) {
      return _buildEmptyHistory();
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _saldoHistoryList.length,
      itemBuilder: (context, index) {
        final item = _saldoHistoryList[index];
        return _buildHistoryEntry(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Tipe Jumlah:", item.tipeJumlah),
              _buildDetailRow("Jumlah Dana:", _formatRupiah(item.jumlahDana)),
              _buildDetailRow("Tipe Mutasi:", item.tipeMutasi),
              _buildDetailRow("Tanggal:", item.tanggal),
              _buildDetailRow("Saldo Terakhir:", _formatRupiah(item.saldoTerakhir)),
              _buildDetailRow("No. Pembayaran:", item.nomorPembayaran),
              _buildDetailRow("Link Transaksi:", item.linkTransaksi, isLink: true),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk list riwayat POIN
  Widget _buildPoinList() {
    if (_poinHistoryList.isEmpty) {
      return _buildEmptyHistory();
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _poinHistoryList.length,
      itemBuilder: (context, index) {
        final item = _poinHistoryList[index];
        return _buildHistoryEntry(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Kategori Poin:", item.kategoriPoin),
              _buildDetailRow("Tipe Jumlah:", item.tipeJumlah),
              _buildDetailRow("Jumlah Poin:", _formatNumber(item.jumlahPoin)),
              _buildDetailRow("Tanggal Poin:", item.tanggalPoin),
              _buildDetailRow("Total Poin Terakhir:", _formatNumber(item.totalPoinTerakhir)),
              _buildDetailRow("Link Transaksi:", item.linkTransaksi, isLink: true),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk satu item riwayat (CSS .history-entry)
  Widget _buildHistoryEntry({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: child,
    );
  }

  // Widget untuk baris detail (Judul: Nilai)
  Widget _buildDetailRow(String title, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: isLink
                ? InkWell(
              onTap: () {
                // Di aplikasi nyata, gunakan url_launcher untuk membuka link
              },
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            )
                : Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk placeholder "Tidak ada riwayat"
  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://codingasikhome.files.wordpress.com/2023/10/20231004_104828.png",
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 10),
          const Text("Tidak ada riwayat", style: TextStyle(fontSize: 13, color: Color(0xFF6f6f6f))),
        ],
      ),
    );
  }

  // Widget untuk animasi loading
  Widget _buildLoading() {
    return Center(
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => _LoadingBar(index: index)),
        ),
      ),
    );
  }
}

// Widget kustom untuk animasi loading bar (replikasi CSS)
class _LoadingBar extends StatefulWidget {
  final int index;
  const _LoadingBar({required this.index});

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> colors = [
    const Color(0xff4c86f9),
    const Color(0xff49a84c),
    const Color(0xfff6bb02),
    const Color(0xfff6bb02),
    const Color(0xff2196f3),
  ];

  final List<double> delays = [0.0, -0.8, -0.7, -0.6, -0.5];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.05), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.05), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (900 + (delays[widget.index] * 1000)) / 900,
        1.0,
        curve: Curves.easeOut,
      ),
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          color: colors[widget.index],
          transform: Matrix4.identity()..scale(1.0, _animation.value),
          transformAlignment: Alignment.center,
        );
      },
    );
  }
}