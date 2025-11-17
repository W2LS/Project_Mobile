import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment jika ingin pakai url_launcher

// Warna primer (bisa diambil dari theme nanti)
const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF);

// --- Model Data untuk Provider Internet ---
class InternetProvider {
  final String name;
  final String imageUrl;
  final String targetUrl; // Link tujuan saat provider dipilih

  const InternetProvider({
    required this.name,
    required this.imageUrl,
    required this.targetUrl,
  });
}

// --- Daftar Provider (Hardcoded dari HTML Anda) ---
const List<InternetProvider> allProviders = [
  InternetProvider(name: 'Telkomsel', imageUrl: 'https://play-lh.googleusercontent.com/DBzJQ2z8p3n_YPQkmbc6luCfO3OhafRkOZimMoXFXBMoUokLu6RPDRgVM86U_QkRVNE', targetUrl: 'https://luminae.olshopku.com/digital/344385'), // Placeholder image?
  InternetProvider(name: 'Axis', imageUrl: 'https://iconlogovector.com/uploads/images/2023/02/lg-ab245e14c10da5c9ffb63f047c1b7fdc74.jpg', targetUrl: 'https://luminae.olshopku.com/digital/344386'),
  InternetProvider(name: 'By.U', imageUrl: 'https://www.byu.id/sites/default/files/byu-apps.svg', targetUrl: 'https://luminae.olshopku.com/digital/344387'),
  InternetProvider(name: 'XL-Axiata', imageUrl: 'https://iconlogovector.com/uploads/images/2023/02/lg-122b298c5bb85f969703664b046b958d66.jpg', targetUrl: 'https://luminae.olshopku.com/digital/344388'),
  InternetProvider(name: 'Tri (3)', imageUrl: 'https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full//catalog-image/MTA-76195323/tri_masa_aktif_tri_4_bulan_full01_6fa36b7d.jpg', targetUrl: 'https://luminae.olshopku.com/digital/344389'),
  InternetProvider(name: 'Indosat', imageUrl: 'https://im3-img.indosatooredoo.com/indosatassets/images/icons/icon-512x512.png', targetUrl: 'https://luminae.olshopku.com/digital/344390'),
  InternetProvider(name: 'Smartfren', imageUrl: 'https://seeklogo.com/images/S/smartfren-logo-A978AD9193-seeklogo.com.png', targetUrl: 'https://luminae.olshopku.com/digital/344391'),
];
// --- BATAS DAFTAR PROVIDER ---

class InternetCategoryScreen extends StatelessWidget {
  const InternetCategoryScreen({super.key});

  // Fungsi helper untuk membuat item list provider
  Widget _buildProviderItem(BuildContext context, InternetProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          print("Membuka: ${provider.targetUrl}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka ${provider.name}... (URL: ${provider.targetUrl})')),
          );
          // final Uri url = Uri.parse(provider.targetUrl);
          // launchUrl(url, mode: LaunchMode.externalApplication);
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    ClipRRect( // Agar gambar sesuai border radius
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        provider.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain, // Use contain for logos
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.signal_cellular_alt_outlined, color: Colors.grey[400]), // Placeholder icon
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        provider.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              // Span "Lihat Paket"
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Lihat Paket",
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: PreferredSize( // Gunakan PreferredSize untuk AppBar custom
        preferredSize: Size.fromHeight(kToolbarHeight + statusBarHeight), // Tinggi AppBar standar + status bar
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 2,
          shape: const RoundedRectangleBorder( // Lengkungan bawah
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Pilih Provider",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        // Padding agar list tidak tertutup AppBar dan ada jarak bawah
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Padding atas ditambah
        itemCount: allProviders.length,
        itemBuilder: (context, index) {
          return _buildProviderItem(context, allProviders[index]);
        },
      ),
    );
  }
}