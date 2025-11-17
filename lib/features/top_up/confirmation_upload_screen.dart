import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);

class ConfirmationUploadScreen extends StatefulWidget {
  // Kita menerima nominal dan info bank dari halaman instruksi
  final String amount;
  final String bankName; // Bank tujuan (milik owner)
  final String accountNumber; // No Rek tujuan (milik owner)

  const ConfirmationUploadScreen({
    super.key,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
  });

  @override
  State<ConfirmationUploadScreen> createState() =>
      _ConfirmationUploadScreenState();
}

class _ConfirmationUploadScreenState extends State<ConfirmationUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senderNameController = TextEditingController();
  // --- DIHAPUS: Controller Bank Asal tidak dipakai lagi ---
  // final TextEditingController _senderBankController = TextEditingController();
  final TextEditingController _transferDateController = TextEditingController();

  // --- TAMBAHAN: Variabel & List untuk Dropdown Bank ---
  String? _selectedSenderBank; // Untuk menyimpan bank yang dipilih
  final List<String> _bankOptions = [
    'BCA', 'BNI', 'BRI', 'Mandiri', 'CIMB Niaga', 'Danamon', 'Permata', 'Lainnya...'
  ];
  // --- BATAS TAMBAHAN ---

  // Placeholder untuk file gambar bukti transfer
  String? _imagePathPlaceholder;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _transferDateController.text = formattedDate;
      });
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    // _senderBankController.dispose(); // Dihapus
    _transferDateController.dispose();
    super.dispose();
  }

  void _pickImage() {
    setState(() {
      _imagePathPlaceholder = "bukti_transfer_example.jpg";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Simulasi: Gambar bukti transfer dipilih.")),
    );
  }

  void _submitConfirmation() {
    if (_formKey.currentState!.validate()) {
      // --- MODIFIKASI: Validasi dropdown bank ---
      if (_selectedSenderBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Harap pilih bank asal transfer."),
              backgroundColor: Colors.red),
        );
        return;
      }
      // --- BATAS MODIFIKASI ---

      if (_imagePathPlaceholder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Harap unggah bukti transfer."),
              backgroundColor: Colors.red),
        );
        return;
      }

      print("--- Konfirmasi Dikirim ---");
      print("Jumlah: ${widget.amount}");
      print("Bank Tujuan: ${widget.bankName}");
      print("No Rek Tujuan: ${widget.accountNumber}");
      print("Nama Pengirim: ${_senderNameController.text}");
      // --- MODIFIKASI: Gunakan variabel dropdown ---
      print("Bank Pengirim: $_selectedSenderBank");
      // --- BATAS MODIFIKASI ---
      print("Tanggal Transfer: ${_transferDateController.text}");
      print("Bukti Transfer: $_imagePathPlaceholder");
      print("-------------------------");

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Konfirmasi Terkirim"),
            content: const Text(
                "Konfirmasi Anda telah dikirim. Admin akan segera memverifikasi pembayaran Anda."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
              ),
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Transfer Anda",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senderNameController,
                            decoration: const InputDecoration(
                              labelText: "Nama Pengirim (sesuai rekening)",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama pengirim tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // --- MODIFIKASI: Ganti TextFormField dengan DropdownButtonFormField ---
                          DropdownButtonFormField<String>(
                            value: _selectedSenderBank,
                            hint: const Text("Pilih Bank Asal Transfer"),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _bankOptions.map((String bank) {
                              return DropdownMenuItem<String>(
                                value: bank,
                                child: Text(bank),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSenderBank = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Bank asal tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          // --- BATAS MODIFIKASI ---

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _transferDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Tanggal Transfer",
                              border: OutlineInputBorder(),
                              hintText: "Pilih Tanggal",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () {
                              _selectDate(context);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal transfer tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Unggah Bukti Transfer",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: Text(_imagePathPlaceholder ?? "Pilih Gambar"),
                            onPressed: _pickImage,
                          ),
                          if (_imagePathPlaceholder != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("File terpilih: $_imagePathPlaceholder"),
                            ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitConfirmation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Kirim Konfirmasi",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
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