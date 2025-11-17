import 'package:flutter/material.dart';
import '/features/home/home_screen.dart'; // Impor HomeScreen dari main.dart
import '/features/history/history_screen.dart'; // Impor placeholder HistoryScreen
import '/features/account/account_screen.dart'; // Impor placeholder AccountScreen

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // Indeks tab yang aktif (0: Home, 1: History, 2: Account)

  // Daftar layar yang akan ditampilkan sesuai tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Layar Home Anda yang sudah ada
    HistoryScreen(), // Layar Riwayat (placeholder)
    AccountScreen(), // Layar Akun (placeholder)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan layar sesuai _selectedIndex
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Ikon saat aktif
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Warna ikon aktif
        unselectedItemColor: Colors.grey, // Warna ikon tidak aktif
        onTap: _onItemTapped, // Fungsi yang dipanggil saat tab diklik
        type: BottomNavigationBarType.fixed, // Agar label selalu terlihat
      ),
    );
  }
}