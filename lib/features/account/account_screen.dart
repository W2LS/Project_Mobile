import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF);

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});


  Widget _buildAccountListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {
        print("$title diklik!");
        // TODO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman $title belum dibuat.')),
        );
      },
      visualDensity: VisualDensity.compact,
    );
  }




  Widget _buildStatsColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan tinggi header
    const double headerHeight = 280;
    // Tentukan seberapa banyak card statistik akan overlap
    const double cardOverlap = 40;
    // Tentukan tinggi card statistik (estimasi)
    const double cardHeight = 110;
    // Jarak antara card statistik dan card menu di bawahnya
    const double spaceBelowCard = 16.0;

    // Hitung posisi atas card statistik
    final double cardTopPosition = headerHeight - cardOverlap;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: Stack(
        children: [
          // --- LAPISAN BAWAH: Konten Scrollable ---
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: cardTopPosition + cardHeight + spaceBelowCard, // Padding atas
              bottom: 30, // Padding bawah
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card( // Card dimulai langsung
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // --- MODIFIKASI: Kirim context saat memanggil ---
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.person_outline,
                        title: "Informasi Akun",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.location_on_outlined,
                        title: "Alamat Saya",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.favorite_border,
                        title: "Favorit Saya",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.chat_bubble_outline,
                        title: "Diskusi Barang",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.list_alt_outlined,
                        title: "Daftar Antrian Transaksi",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                          context: context, // <-- Kirim context
                          icon: Icons.account_balance_wallet_outlined,
                          title: "Riwayat Saldo & TopUp",
                          onTap: () {
                            // Navigasi tidak perlu context dari parameter karena sudah ada di scope build
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: Text("Riwayat Saldo")), body: Center(child: Text("Halaman Riwayat Saldo")))));
                          }
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.rate_review_outlined,
                        title: "Testimoni Luminae",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.info_outline,
                        title: "About",
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                        context: context, // <-- Kirim context
                        icon: Icons.settings_outlined,
                        title: "Pengaturan",
                        onTap: () {
                          print("Pengaturan diklik!");
                          ScaffoldMessenger.of(context).showSnackBar( // <-- context sekarang dikenal
                            SnackBar(content: Text('Halaman Pengaturan belum dibuat.')),
                          );
                        },
                      ),
                      // --- BATAS MODIFIKASI ---
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.red),
                    label: Text("Logout", style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      // TODO: Implement Logout Logic
                    },
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LAPISAN TENGAH: Header Biru (Tetap Sama) ---
          Container(
            width: double.infinity,
            height: headerHeight,
            padding: const EdgeInsets.only(top: 50, bottom: 40),
            decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Text(
                    "D",
                    style: TextStyle(fontSize: 35, color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "CS Dicky",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),

          // --- LAPISAN ATAS: Card Statistik (Tetap Sama) ---
          Positioned(
            top: cardTopPosition,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatsColumn("Invoice", "0"),
                    _buildStatsColumn("Dikirim", "2"),
                    _buildStatsColumn("Sukses", "136"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}