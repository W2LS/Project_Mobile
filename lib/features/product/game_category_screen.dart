import 'package:flutter/material.dart';

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5); // Biru utama
const Color screenBackgroundColor = Color(0xFFF0F8FF); // Background utama

// --- Model Data untuk Game ---
// (Lebih baik dibuat di file terpisah nanti jika model semakin kompleks)
class GameCategory {
  final String name;
  final String imageUrl;
  final String targetUrl; // Link tujuan saat game dipilih

  const GameCategory({
    required this.name,
    required this.imageUrl,
    required this.targetUrl,
  });
}

// --- Daftar Game (Hardcoded dari HTML Anda) ---
// Di aplikasi nyata, ini sebaiknya diambil dari API
const List<GameCategory> allGames = [
  GameCategory(name: 'Free Fire', imageUrl: 'https://downloadr2.apkmirror.com/wp-content/uploads/2022/11/43/637473239d8f6-384x384.png', targetUrl: 'https://luminae.bukaolshop.site/digital/256890'),
  GameCategory(name: 'Mobile Legends', imageUrl: 'https://static.gameguardian.net/monthly_2023_08/1844549710_unnamed(4).thumb.webp.28f5b1ed3ed930192572cd177c9738ef.webp', targetUrl: 'https://kobodev.my.id/digital/257024'), // URL Beda?
  GameCategory(name: 'Pubg Mobile', imageUrl: 'https://img.utdstc.com/icon/bf3/a06/bf3a064b6cb988f7c7f94a064ad122558ad3cd9510f0aa5becb4c9e1cf85f823:200', targetUrl: 'https://kobodev.my.id/digital/257025'),
  GameCategory(name: 'Undawn', imageUrl: 'https://topupgasskeun.com/assets/img/kategori/1691055817ed.webp', targetUrl: 'https://kobodev.my.id/digital/257026'),
  GameCategory(name: 'Metal Slug Awakening', imageUrl: 'https://play-lh.googleusercontent.com/y57PZuNcCZwB8miobsMS2q7W_bZUoodZgPv-PAfvq4whVgH4zXdAJlNlVwIjiZ3cQs4', targetUrl: 'https://kobodev.my.id/digital/257031'), // Placeholder image?
  GameCategory(name: 'Call Of Duty', imageUrl: 'https://i.pinimg.com/originals/39/9b/b4/399bb479272b8d34d957fb98d62ca30b.png', targetUrl: 'https://kobodev.my.id/digital/257030'),
  GameCategory(name: 'Laplace M', imageUrl: 'https://play-lh.googleusercontent.com/U-TPxdxa5IYGQM0cXdjRL161tRuhT0VZMDThyV0DnU54lCQqxWYBgEjb4SlhZuzCR1E', targetUrl: 'https://kobodev.my.id/digital/262594'), // Placeholder image?
  GameCategory(name: 'Supersus', imageUrl: 'https://play-lh.googleusercontent.com/_Y564Top27K7DCHIQGR4cRCjPb3hBl1IyP0czy-k6ab3_CQb6GTOi2aPifRllNF_jfM=w240-h480-rw', targetUrl: 'https://kobodev.my.id/digital/262592'), // Placeholder image?
  GameCategory(name: 'Genshin Impact', imageUrl: 'https://cdn2.steamgriddb.com/icon/b035d6563a2adac9f822940c145263ce.png', targetUrl: 'https://kobodev.my.id/digital/257027'),
  GameCategory(name: 'Sausageman', imageUrl: 'https://ayocash.id/assets/img/sub_category/tMzdTZoGY37x4VqIBDCn.jpg', targetUrl: 'https://kobodev.my.id/digital/262593'),
  GameCategory(name: 'Life After', imageUrl: 'https://assets-prd.ignimgs.com/2021/05/21/lifeafter-button-1621578837400.jpg', targetUrl: 'https://kobodev.my.id/digital/257029'),
  GameCategory(name: 'Pubg New State', imageUrl: 'https://play-lh.googleusercontent.com/1lWAkJbu-pgG1rjm6u1hw211aJgOOUnzSKaWk0Es0e517OwsR4A9NWRg6siYqp4lt5s', targetUrl: 'https://kobodev.my.id/digital/262578'), // Placeholder image?
  GameCategory(name: 'Dragon Raja', imageUrl: 'https://play-lh.googleusercontent.com/QWQMJwBEybP1BsCpAHqhddDI8awJsXZTyPwTZAxk-ppFpnqiWcPFUYVtN0Ii6zP9pOk', targetUrl: 'https://kobodev.my.id/digital/257033'), // Placeholder image?
  GameCategory(name: 'Speed Drifter', imageUrl: 'https://cdn6.aptoide.com/imgs/3/a/d/3adc2a8e694a4f4d239bedca8b7409be_icon.png', targetUrl: 'https://kobodev.my.id/digital/257038'),
  GameCategory(name: 'Marvel Super War', imageUrl: 'https://play-lh.googleusercontent.com/c4SxEDCnHLh78ihzLqM3XwdCvrwJKQdhd5opSCMerITWeom5cO0yP3AKolYpqxPzIlo', targetUrl: 'https://kobodev.my.id/digital/257035'), // Placeholder image?
  GameCategory(name: 'Arena Of Valor', imageUrl: 'https://play-lh.googleusercontent.com/caDiIvFl-VDvEPlzbHuypmXMTIwAiA8WesvsUIcFoQqokLaYRSYh-Y0LpR4RFhGgytEg', targetUrl: 'https://kobodev.my.id/digital/257036'), // Placeholder image?
  GameCategory(name: 'Higgs Domino', imageUrl: 'https://play-lh.googleusercontent.com/Fx0NDO3ZlqxtwW9QpsiSOTNGpFrX3tQXnmrDfIbwKPWPl0uUUJUDvlkZiQg-_AXl4d8_', targetUrl: 'https://kobodev.my.id/digital/262578'), // Placeholder image? // URL Sama dengan PUBG New State?
  GameCategory(name: 'Hago', imageUrl: 'https://play-lh.googleusercontent.com/R_F71_ySrwwGR3lluETN_VMwms80uzqMj6IsRjqxHXNy9ryHYe7KBaFeT6odZendQQ', targetUrl: 'https://kobodev.my.id/digital/263222'), // Placeholder image?
  GameCategory(name: 'Onmyoji Arena', imageUrl: 'https://gameclub.fp.guinfra.com/file/659f5f437b333cf0698ed3b6htFTIa9U03', targetUrl: 'https://kobodev.my.id/digital/262600'),
  GameCategory(name: 'Bearfish', imageUrl: 'https://media.karousell.com/media/photos/products/2023/10/18/agen_terima_bongkar_chip_bearf_1697601846_224c6030_progressive.jpg', targetUrl: 'https://kobodev.my.id/digital/262578'), // URL Sama dengan PUBG New State?
];
// --- BATAS DAFTAR GAME ---


class GameCategoryScreen extends StatefulWidget {
  const GameCategoryScreen({super.key});

  @override
  State<GameCategoryScreen> createState() => _GameCategoryScreenState();
}

class _GameCategoryScreenState extends State<GameCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GameCategory> _filteredGames = allGames; // List game yang ditampilkan

  @override
  void initState() {
    super.initState();
    // Listener untuk filter saat pengguna mengetik
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi filter pencarian (mirip myFunction di JS)
  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGames = allGames.where((game) {
        return game.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Fungsi helper untuk membuat item list game
  Widget _buildGameItem(BuildContext context, GameCategory game) {
    return Padding(
      // Padding pengganti margin-top di CSS .operator
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell( // Menggantikan <a> tag
        onTap: () {
          // TODO: Navigasi ke WebView atau halaman detail game
          print("Membuka: ${game.targetUrl}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka ${game.name}... (URL: ${game.targetUrl})')),
          );
          // Di aplikasi nyata, gunakan url_launcher atau webview_flutter
          // launchUrl(Uri.parse(game.targetUrl), mode: LaunchMode.externalApplication);
        },
        child: Card( // Menggantikan div.operator
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: EdgeInsets.zero, // Hapus margin default Card
          clipBehavior: Clip.antiAlias, // Agar border radius di span terlihat
          child: Stack( // Gunakan Stack untuk menempatkan span di pojok
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    ClipRRect( // Agar gambar bulat
                      borderRadius: BorderRadius.circular(20), // Setengah dari width/height
                      child: Image.network(
                        game.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Placeholder jika gambar gagal dimuat
                          return Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded( // Agar teks nama bisa memanjang
                      child: Text(
                        game.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              // Span "Pilih Game" di pojok kanan bawah
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(18), // Sesuai border Card
                    ),
                  ),
                  child: const Text(
                    "Pilih Game",
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
    // Dapatkan status bar height untuk padding manual
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double searchBarHeight = 80; // Perkiraan tinggi search bar + padding

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: null, // Hapus AppBar standar
      body: Stack(
        children: [
          // --- LAPISAN BAWAH: List Game Scrollable ---
          ListView.builder(
            // Padding atas = Tinggi header (70) + Tinggi search bar (sekitar 80)
            padding: EdgeInsets.only(
              top: 70 + searchBarHeight + 10, // Beri padding atas yang besar
              bottom: 20, // Padding bawah
              left: 16,
              right: 16,
            ),
            itemCount: _filteredGames.length,
            itemBuilder: (context, index) {
              return _buildGameItem(context, _filteredGames[index]);
            },
          ),

          // --- LAPISAN TENGAH: Header Biru Melengkung ---
          Container(
            height: 70, // Tinggi header sesuai CSS
            decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [ // Shadow tipis
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ]
            ),
            // Tombol back manual
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: statusBarHeight - 10, left: 4.0), // Padding atas & kiri
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // --- LAPISAN ATAS: Search Bar (Sticky) ---
          Positioned(
            top: 70, // Mulai tepat di bawah header
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 5), // Padding dari CSS .serching
              color: screenBackgroundColor, // Background agar tidak transparan
              child: Card( // Menggantikan div .bg-serching
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Padding dalam card
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari nama game...",
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder( // Border saat tidak aktif
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder( // Border saat aktif
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      isDense: true, // Membuat input lebih ringkas
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Padding dalam input
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}