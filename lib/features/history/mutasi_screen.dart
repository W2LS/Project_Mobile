import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Variabel warna global
const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF);

// Model Transaction (Tetap Sama)
class Transaction {
  final String tipeJumlah;
  final String jumlahDana;
  final String saldoTerakhir;
  final String tanggal;
  final String catatan;

  Transaction({
    required this.tipeJumlah,
    required this.jumlahDana,
    required this.saldoTerakhir,
    required this.tanggal,
    required this.catatan,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      tipeJumlah: json['tipe_jumlah'] ?? 'N/A',
      jumlahDana: json['jumlah_dana'] ?? '0',
      saldoTerakhir: json['saldo_terakhir'] ?? '0',
      tanggal: json['tanggal'] ?? 'N/A',
      catatan: json['informasi_catatan'] ?? 'Tidak ada catatan',
    );
  }
}


class MutasiSaldoScreen extends StatefulWidget {
  final String fotoProfil;
  final String namaUser;
  final double saldoUser;
  final String idUser;
  final String tokenUser;

  const MutasiSaldoScreen({
    super.key,
    this.fotoProfil = "https://via.placeholder.com/150",
    this.namaUser = "User Luminae",
    this.saldoUser = 1250000,
    required this.idUser,
    required this.tokenUser,
  });

  @override
  State<MutasiSaldoScreen> createState() => _MutasiSaldoScreenState();
}

class _MutasiSaldoScreenState extends State<MutasiSaldoScreen> {
  final String _apiToken = "eyJhcHAiOiIxMDI5NTkiLCJhdXRoIjoiMjAyMjA1MTUiLCJzaWduIjoiWjhUUWgzRktGY2FIYzJcL3BlVkIrY3c9PSJ9";
  int _currentPage = 1;
  bool _isLoading = true;
  String _activeTab = 'masuk';
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMutasi(_currentPage);
  }

  String _formatRupiah(dynamic amount) {
    final number = double.tryParse(amount.toString()) ?? 0.0;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  Future<void> _fetchMutasi(int page) async {
    if (!mounted) return;
    if (page < 1) {
      _currentPage = 1;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anda sudah di halaman pertama."), backgroundColor: Colors.orange,),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse(
        'https://openapi.bukaolshop.net/v1/user/catatan?token=$_apiToken&token_user=${widget.tokenUser}&id_user=${widget.idUser}&tipe=saldo&page=$page');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List && (data['data'] as List).isNotEmpty) {
          List<Transaction> fetchedTransactions = (data['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();

          setState(() {
            _allTransactions = fetchedTransactions;
            _filterTransactions();
            _isLoading = false;
            _currentPage = page;
          });
        } else {
          setState(() {
            if (_currentPage > 1) {
              _currentPage--;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tidak ada data lagi."), backgroundColor: Colors.orange,),
                );
              }
            } else {
              _allTransactions = [];
              _filteredTransactions = [];
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data (Error: ${response.statusCode})";
          _allTransactions = [];
          _filteredTransactions = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Terjadi kesalahan jaringan.";
        _allTransactions = [];
        _filteredTransactions = [];
      });
    }
  }

  void _filterTransactions() {
    _filteredTransactions = _allTransactions
        .where((tx) => tx.tipeJumlah == _activeTab)
        .toList();
  }

  void _setActiveTab(String tab) {
    setState(() {
      _activeTab = tab;
      _filterTransactions();
    });
  }

  void _showTransactionDetails(Transaction tx) {
    String catatan = tx.catatan;
    if (catatan.contains("Anda melakukan perubahan saldo melalui API (tambah)") ||
        catatan.contains("Anda melakukan perubahan saldo melalui API (kurang)")) {
      catatan = "Perubahan saldo oleh API";
    } else if (catatan.contains("Anda menambahkan saldo secara manual")) {
      catatan = "Penambahan saldo manual oleh Admin";
    } else if (catatan.contains("Anda mengkonfirmasi topup yang dilakukan member")) {
      catatan = "Top-Up saldo dikonfirmasi oleh Admin";
    } else if (catatan.contains("Anda telah menerima dana dari seseorang")) {
      catatan = "Penerimaan dana dari pengguna lain";
    } else if (catatan.contains("Admin Qita mengurangi dana anda")) {
      catatan = "Pengurangan saldo oleh Admin Qita";
    }
    else if (catatan.contains("Anda menerima dana dari admin Qita")) {
      catatan = "Penerimaan dana dari Admin Qita";
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
              ),
              const Center(
                child: Text(
                  "Detail Perubahan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Jumlah", _formatRupiah(tx.jumlahDana)),
              _buildDetailRow("Saldo Terakhir", _formatRupiah(tx.saldoTerakhir)),
              _buildDetailRow("Tanggal", tx.tanggal),
              const SizedBox(height: 10),
              const Text("Catatan:", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(catatan, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 130;
    const double cardOverlap = 60;
    const double cardHeight = 105;
    const double spaceBelowCard = 16.0;
    final double cardTopPosition = headerHeight - cardOverlap;

    // --- TAMBAHAN: Dapatkan padding atas status bar ---
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // --- BATAS TAMBAHAN ---

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: cardTopPosition + cardHeight + spaceBelowCard,
            ),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : (_errorMessage != null)
                      ? _buildError(_errorMessage!)
                      : (_filteredTransactions.isEmpty)
                      ? _buildEmptyHistory()
                      : _buildTransactionList(),
                ),
                if (!_isLoading && _errorMessage == null && _allTransactions.isNotEmpty)
                  _buildPagination(),
              ],
            ),
          ),

          // --- LAPISAN TENGAH: Header Biru Melengkung ---
          Container(
            height: headerHeight,
            decoration: BoxDecoration( // Hapus const di sini
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
            ),
            // --- MODIFIKASI: Hapus SafeArea, Gunakan Padding ---
            child: Align(
              alignment: Alignment.topLeft,
              // Tambahkan padding atas manual sebesar tinggi status bar + sedikit jarak
              child: Padding(
                padding: EdgeInsets.only(top: statusBarHeight + 4.0, left: 4.0), // Padding atas & kiri
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // --- BATAS MODIFIKASI ---
          ),

          Positioned(
            top: cardTopPosition,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(widget.fotoProfil),
                          onBackgroundImageError: (_, __) {},
                          child: widget.fotoProfil.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.namaUser, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text(_formatRupiah(widget.saldoUser), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildTabButton("masuk", "Masuk"),
                        const SizedBox(width: 10),
                        _buildTabButton("keluar", "Keluar"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTabButton, _buildTransactionList, _buildEmptyHistory, _buildLoading, _buildError, _buildPagination (TETAP SAMA)
  // ... (Salin sisa widget helper dari kode sebelumnya) ...
  // Widget untuk satu tombol tab (mirip HTML)
  Widget _buildTabButton(String id, String label) {
    bool isActive = _activeTab == id;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _setActiveTab(id),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? primaryColor : Colors.white,
          foregroundColor: isActive ? Colors.white : const Color(0xFF595959),
          elevation: isActive ? 2 : 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isActive ? BorderSide.none : BorderSide(color: Colors.grey.shade300) // Border jika tidak aktif
          ),
          padding: const EdgeInsets.symmetric(vertical: 10), // Atur padding tombol
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }


  // Widget untuk list transaksi
  Widget _buildTransactionList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Padding list
      itemCount: _filteredTransactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5), // Pemisah antar item
      itemBuilder: (context, index) {
        final tx = _filteredTransactions[index];
        bool isMasuk = tx.tipeJumlah == 'masuk';

        String catatan = tx.catatan;
        if (catatan.contains("Anda melakukan perubahan saldo melalui API (tambah)") ||
            catatan.contains("Anda melakukan perubahan saldo melalui API (kurang)")) {
          catatan = "Perubahan saldo oleh API";
        } else if (catatan.contains("Anda menambahkan saldo secara manual")) {
          catatan = "Penambahan saldo manual oleh Admin";
        } else if (catatan.contains("Anda mengkonfirmasi topup yang dilakukan member")) {
          catatan = "Top-Up saldo dikonfirmasi oleh Admin";
        } else if (catatan.contains("Anda telah menerima dana dari seseorang")) {
          catatan = "Penerimaan dana dari pengguna lain";
        } else if (catatan.contains("Admin Qita mengurangi dana anda")) {
          catatan = "Pengurangan saldo oleh Admin Qita";
        }
        else if (catatan.contains("Anda menerima dana dari admin Qita")) {
          catatan = "Penerimaan dana dari Admin Qita";
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8), // Padding item list
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isMasuk ? const Color(0xFF01A6AC) : const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.network(
              "https://i.ibb.co/rvZKyFK/card.png", // Icon default
              width: 21,
              height: 21,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.credit_card, color: Colors.white, size: 21), // Fallback icon
            ),
          ),
          title: Text(
            catatan,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(tx.tanggal, style: const TextStyle(fontSize: 11, color: Color(0xFF424242))),
          trailing: Text(
            _formatRupiah(tx.jumlahDana),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isMasuk ? Colors.green : Colors.red,
            ),
          ),
          onTap: () => _showTransactionDetails(tx),
        );
      },
    );
  }

  // Widget untuk placeholder "Tidak ada riwayat"
  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network("https://codingasikhome.files.wordpress.com/2023/10/20231004_104828.png", width: 50, height: 50,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.receipt_long, size: 50, color: Colors.grey)), // Fallback icon
          const SizedBox(height: 10),
          const Text("Tidak ada riwayat saldo", style: TextStyle(fontSize: 13, color: Color(0xFF6f6f6f))),
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
              onPressed: () => _fetchMutasi(_currentPage), // Coba fetch ulang halaman saat ini
            )
          ],
        ),
      ),
    );
  }

  // Widget untuk pagination
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: Offset(0,-1))
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentPage > 1 ? () => _fetchMutasi(_currentPage - 1) : null,
            child: Text("Sebelumnya", style: TextStyle(color: _currentPage > 1 ? primaryColor : Colors.grey)),
          ),
          Text("Hal. $_currentPage", style: const TextStyle(color: Color(0xFF4d4d4d), fontWeight: FontWeight.w500)),
          TextButton(
            onPressed: () => _fetchMutasi(_currentPage + 1),
            child: const Text("Selanjutnya", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}

// Widget kustom untuk animasi loading bar (Sama)
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
    const Color(0xff4c86f9), const Color(0xff49a84c), const Color(0xfff6bb02),
    const Color(0xfff6bb02), const Color(0xff2196f3),
  ];
  final List<double> delays = [0.0, -0.8, -0.7, -0.6, -0.5];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.05), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.05), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 1.0)));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (0.0 - delays[widget.index]).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Container(
          width: 4, height: 50, margin: const EdgeInsets.symmetric(horizontal: 3),
          color: colors[widget.index],
          transform: Matrix4.identity()..scale(1.0, delayedAnimation.value), // Gunakan delayedAnimation
          transformAlignment: Alignment.center,
        );
      },
    );
  }
}