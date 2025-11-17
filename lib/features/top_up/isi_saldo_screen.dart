import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'virtual_account_screen.dart'; // Import halaman VA
import 'ewallet_screen.dart'; // Import halaman E-Wallet
// Import halaman QRIS tidak diperlukan lagi

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF); // Background utama
// Warna baru untuk background input
const Color inputBackgroundColor = Colors.white; // Atau Colors.grey[100]

class IsiSaldoScreen extends StatefulWidget {
  // Kita perlu menerima info saldo saat ini dari halaman Home
  final double saldoUser;

  const IsiSaldoScreen({super.key, required this.saldoUser});

  @override
  State<IsiSaldoScreen> createState() => _IsiSaldoScreenState();
}

class _IsiSaldoScreenState extends State<IsiSaldoScreen> {
  final TextEditingController _amountController = TextEditingController();
  // Untuk menyimpan nominal cepat yang dipilih
  String _selectedNominal = '';

  // Untuk format mata uang
  final currencyFormatter =
  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Fungsi helper untuk membuat chip nominal cepat
  Widget _buildNominalChip(String amount) {
    final bool isSelected = _selectedNominal == amount;
    return ChoiceChip(
      label: Text("Rp $amount",
          style: TextStyle(
              color: isSelected ? Colors.white : primaryColor,
              fontWeight: FontWeight.bold)),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: primaryColor),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedNominal = amount;
          // Update text field juga
          _amountController.text = amount.replaceAll('.', '');
        });
      },
    );
  }

  // Fungsi helper sekarang menerima 'onTap' kustom
  Widget _buildPaymentMethodTile({
    required String logoUrl,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.network(logoUrl, width: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Fungsi untuk validasi dan navigasi
  void _navigateTo(Widget screen) {
    // Validasi dulu apakah nominal sudah diisi
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap masukkan nominal top up dulu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Navigasi ke halaman yang dituju
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor, // Background utama
      appBar: null,
      body: Stack(
        children: [
          // Latar belakang biru melengkung
          Container(
            height: 130, // Tinggi header
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),

          // Konten halaman
          SafeArea(
            child: Column(
              children: [
                // AppBar Manual (Tombol Back & Judul)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Isi Saldo",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten Asli (dibuat bisa scroll)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Kartu Saldo Saat Ini
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Saldo Anda Saat Ini:",
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                  currencyFormatter.format(widget.saldoUser),
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2. Masukkan Nominal
                        const Text(
                          "1. Masukkan Nominal Top Up",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // --- MODIFIKASI DIMULAI DI SINI ---
                        // Bungkus TextField dengan Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Padding di dalam container
                          decoration: BoxDecoration(
                              color: inputBackgroundColor, // Warna background input
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300) // Border tipis
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              // Label dihilangkan, gunakan hintText
                              // labelText: "Jumlah Nominal",
                              hintText: "Jumlah Nominal (Contoh: 50000)",
                              prefixText: "Rp ",
                              // Hapus border bawaan TextField
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 16), // Sesuaikan ukuran font input
                            onChanged: (value) {
                              setState(() {
                                _selectedNominal = '';
                              });
                            },
                          ),
                        ),
                        // --- BATAS MODIFIKASI ---


                        const SizedBox(height: 16),
                        const Text(
                          "Atau pilih nominal cepat:",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: [
                            _buildNominalChip('20.000'),
                            _buildNominalChip('50.000'),
                            _buildNominalChip('100.000'),
                            _buildNominalChip('200.000'),
                            _buildNominalChip('500.000'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3. Pilih Metode Pembayaran
                        const Text(
                          "2. Pilih Metode Pembayaran",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildPaymentMethodTile(
                          logoUrl: "https://cdn-icons-png.flaticon.com/128/196/196578.png",
                          title: "Transfer Bank (Virtual Account)",
                          subtitle: "BCA, BNI, Mandiri, BRI, & Lainnya",
                          onTap: () {
                            _navigateTo(VirtualAccountScreen(
                              amount: _amountController.text,
                            ));
                          },
                        ),

                        _buildPaymentMethodTile(
                          logoUrl: "https://cdn-icons-png.flaticon.com/128/888/888870.png",
                          title: "E-Wallet",
                          subtitle: "GoPay, OVO, DANA, ShopeePay",
                          onTap: () {
                            _navigateTo(EwalletScreen(
                              amount: _amountController.text,
                            ));
                          },
                        ),

                        const SizedBox(height: 16), // Beri sedikit jarak di bawah

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}