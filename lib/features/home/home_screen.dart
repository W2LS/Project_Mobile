import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:marquee/marquee.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';


// --- Impor layar lain (sesuaikan path jika perlu) ---
// ../../ artinya naik 2 level folder (dari home -> features -> lib)
import '/features/history/mutasi_screen.dart';
import '/features/history/catatan_screen.dart';
import '/features/top_up/isi_saldo_screen.dart';
import '/features/product/pulsa_screen.dart'; // Path ke folder product
import '/features/product/game_category_screen.dart';
import '/features/product/internet_category_screen.dart';
import '/features/product/tagihan_screen.dart';
import '/features/product/ewallet_screen.dart';

// Definisikan ulang konstanta warna atau impor dari file terpisah
const Color mainColor = Color(0xFFF0F8FF); // aliceblue
const Color subMainColor = Color(0xFF42A5F5);

// --- Class HomeScreen dan _HomeScreenState DIMULAI DI SINI ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE MANAGEMENT ---
  String _greeting = "";

  // Data user ini akan dikirim ke halaman lain
  final double _saldoUser = 1250000;
  final String _namaMembership = "Non Premium";
  final String _idUser = "ID_USER_ANDA"; // PENTING: Ganti dengan ID user asli
  final String _tokenUser = "TOKEN_USER_ANDA"; // PENTING: Ganti dengan Token user asli
  final String _namaUser = "User Luminae";
  final String _fotoProfil = "https://via.placeholder.com/150";

  bool _isOnline = true;

  // Untuk teks yang berubah-ubah
  final List<String> _words1 = ["Instan", "Otomatis", "Aman"];
  final List<String> _words2 = ["Saldo", "Mudah", "Aman"];
  int _currentIndex1 = 0;
  int _currentIndex2 = 0;
  Timer? _timer;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _setGreeting();
    _startTextAnimation();
    _checkInitialConnection();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          _isOnline = (result != ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _checkInitialConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        _isOnline = (connectivityResult != ConnectivityResult.none);
      });
    }
  }

  void _setGreeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 7)).hour;
    if (hour >= 4 && hour < 10) _greeting = "Selamat pagi,";
    else if (hour >= 10 && hour < 15) _greeting = "Selamat siang,";
    else if (hour >= 15 && hour < 18) _greeting = "Selamat sore,";
    else _greeting = "Selamat malam,";
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex1 = (_currentIndex1 + 1) % _words1.length;
          _currentIndex2 = (_currentIndex2 + 1) % _words2.length;
        });
      }
    });
  }

  String _formatRupiah(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  // --- WIDGET BUILDERS (UNTUK HomeScreen) ---
  @override
  Widget build(BuildContext context) {
    // Return Stack (konten) tanpa Scaffold
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            color: subMainColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 10),
                _buildSaldoCard(),
                const SizedBox(height: 10),
                _buildInfoMarquee(),
                const SizedBox(height: 10),
                _buildPageMenu(),
                const SizedBox(height: 20),
                const Text("Informasi Terkini", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildInfoNewsItem("Reward", "Ajak teman Dapatkan Reward", "Keuntungan makin melejit dengan mengajak teman", "https://cdn-icons-png.flaticon.com/128/9028/9028089.png"),
                const SizedBox(height: 10),
                _buildInfoNewsItem("Tutorial", "Cara pengisian saldo akun", "Tahapan mudah untuk melakukan pengisian saldo dengan cepat", "https://cdn-icons-png.flaticon.com/128/6770/6770687.png"),
                const SizedBox(height: 70), // Jarak bawah
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget helper lainnya ---
  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(_namaUser, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CatatanScreen( // Pastikan CatatanScreen diimpor
              idUser: _idUser,
              tokenUser: _tokenUser,
              namaUser: _namaUser,
              saldoUser: _saldoUser,
              fotoProfil: _fotoProfil,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Saldo Saya", style: TextStyle(color: subMainColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _formatRupiah(_saldoUser),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline ? Colors.greenAccent : Colors.red,
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildActionChip("Isi Saldo", "https://cdn-icons-png.flaticon.com/128/12866/12866032.png", _words1[_currentIndex1]),
                  const SizedBox(width: 15),
                  _buildActionChip("Transfer", "https://cdn-icons-png.flaticon.com/128/9716/9716941.png", _words2[_currentIndex2]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(String title, String iconUrl, String dynamicText) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (title == "Transfer") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MutasiSaldoScreen( // Pastikan MutasiSaldoScreen diimpor
                  idUser: _idUser,
                  tokenUser: _tokenUser,
                  namaUser: _namaUser,
                  saldoUser: _saldoUser,
                  fotoProfil: _fotoProfil,
                ),
              ),
            );
          } else if (title == "Isi Saldo") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IsiSaldoScreen( // Pastikan IsiSaldoScreen diimpor
                  saldoUser: _saldoUser,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
          ),
          child: Row(
            children: [
              Image.network(iconUrl, width: 35),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(child: child, opacity: animation);
                    },
                    child: Text(
                      dynamicText,
                      key: ValueKey<String>(dynamicText),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoMarquee() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          children: [
            Image.network("https://cdn-icons-png.flaticon.com/128/9195/9195785.png", width: 18),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 15,
                child: Marquee(
                  text: 'Transaksi Terpantau lancar - Admin siap siaga memantau kelancaran transaksimu',
                  style: const TextStyle(fontSize: 12),
                  velocity: 50.0,
                  blankSpace: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageMenu() {
    final List<Map<String, String>> menuItems = [
      {'icon': 'https://cdn-icons-png.flaticon.com/128/14561/14561990.png', 'label': 'Pulsa'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/9179/9179559.png', 'label': 'Paket Data'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/9702/9702524.png', 'label': 'Token PLN'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/9302/9302427.png', 'label': 'E-Wallet'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/8294/8294531.png', 'label': 'Game'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/2891/2891516.png', 'label': 'Tagihan'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/10421/10421325.png', 'label': 'Voucher'},
      {'icon': 'https://cdn-icons-png.flaticon.com/128/10348/10348852.png', 'label': 'More'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 100.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16/9,
                viewportFraction: 0.9,
              ),
              items: [
                "https://assets-us-01.kc-usercontent.com/a7507759-f4f5-0038-8fff-c1db251108c1/9d77dbc4-d4de-40a2-8a3a-82b0e7952d2b/web-banner.webp",
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(i, fit: BoxFit.cover),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (index == 0) { // Pulsa
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PulsaScreen()), // Pastikan PulsaScreen diimpor
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InternetCategoryScreen()),
                      );
                    } else if (index == 3) {
                      Get.to(() => const EwalletScreen());
                    } else if (index == 4) { // Game
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameCategoryScreen()),
                      );
                    } else if (index == 5) {
                      Get.to(() => const TagihanScreen());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Halaman ${menuItems[index]['label']} belum tersedia.')),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(menuItems[index]['icon']!, width: 30, height: 30),
                      const SizedBox(height: 4),
                      Text(
                        menuItems[index]['label']!,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoNewsItem(String label, String title, String subtitle, String iconUrl) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
            child: Row(
              children: [
                Image.network(iconUrl, width: 35),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: subMainColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
          Positioned(
            top: 8,
            right: 10,
            child: Image.network("https://cdn-icons-png.flaticon.com/128/14611/14611473.png", width: 20),
          )
        ],
      ),
    );
  }
} // <-- Akhir dari class _HomeScreenState