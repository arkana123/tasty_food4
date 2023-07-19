import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class LaporanTransaksiPage extends StatefulWidget {
  @override
  _LaporanTransaksiPageState createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _transaksiStream;
  int _totalHargaTransaksi = 0;

  @override
  void initState() {
    super.initState();
    _transaksiStream = FirebaseFirestore.instance.collection('transaksi').snapshots();
    _calculateTotalHargaTransaksi(); // Menghitung total harga transaksi saat inisialisasi widget
  }

  void _searchTransaksi(String searchText) {
    setState(() {
      _transaksiStream = FirebaseFirestore.instance
          .collection('transaksi')
          .where('nmpembeli', isEqualTo: searchText)
          .snapshots();
    });
  }

  Future<void> _calculateTotalHargaTransaksi() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transaksi').get();
    final List<QueryDocumentSnapshot> transaksiDocs = snapshot.docs;

    int totalHarga = 0;

    for (var doc in transaksiDocs) {
      final transaksiData = doc.data() as Map<String, dynamic>;
      final String hrgproduk = transaksiData['hrgproduk'];

      int parsedHrgProduk = 0;
      try {
        parsedHrgProduk = int.parse(hrgproduk);
      } catch (e) {
        // Penanganan kesalahan saat parsing, bisa diabaikan atau berikan nilai default
        parsedHrgProduk = 0;
      }

      totalHarga += parsedHrgProduk; // Mengakumulasi harga transaksi dengan mengubah tipe data menjadi int
    }

    setState(() {
      _totalHargaTransaksi = totalHarga;
    });
  }

  Future<void> _generatePDF() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final pdf = pdfWidgets.Document();

      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transaksi').get();
      final List<QueryDocumentSnapshot> transaksiDocs = snapshot.docs;

      pdf.addPage(
        pdfWidgets.Page(
          build: (pdfWidgets.Context context) {
            return pdfWidgets.Column(
              children: transaksiDocs.map((doc) {
                final transaksiData = doc.data() as Map<String, dynamic>;
                final String notrans = transaksiData['notrans'];
                final String nmpembeli = transaksiData['nmpembeli'];
                final String nmproduk = transaksiData['nmproduk'];
                final String hrgproduk = transaksiData['hrgproduk'];
                final String alamat = transaksiData['alamat'];
                final String lokasi = transaksiData['lokasi'];
                final String WA = transaksiData['WA'];

                return pdfWidgets.Container(
                  margin: pdfWidgets.EdgeInsets.symmetric(vertical: 8.0),
                  child: pdfWidgets.Column(
                    crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                    children: [
                      pdfWidgets.Text('No. Transaksi: $notrans'),
                      pdfWidgets.Text('Nama Pembeli: $nmpembeli'),
                      pdfWidgets.Text('Nama Produk: $nmproduk'),
                      pdfWidgets.Text('Harga Produk: $hrgproduk'),
                      pdfWidgets.Text('Alamat: $alamat'),
                      pdfWidgets.Text('Lokasi: $lokasi'),
                      pdfWidgets.Text('WhatsApp: $WA'),
                      pdfWidgets.Divider(),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/laporan_transaksi.pdf');
      await file.writeAsBytes(await pdf.save());

      // Buka file PDF setelah selesai
      OpenFile.open(file.path);
    }
  }

  Future<void> _showTransaksiDialog(String notrans, String nmpembeli, String nmproduk, String hrgproduk, String alamat, String lokasi, String wa) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Transaksi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('No. Transaksi: $notrans'),
                Text('Nama Pembeli: $nmpembeli'),
                Text('Nama Produk: $nmproduk'),
                Text('Harga Produk: $hrgproduk'),
                Text('Alamat: $alamat'),
                Text('Lokasi: $lokasi'),
                Text('WhatsApp: $wa'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Nama Pembeli',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchTransaksi,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _transaksiStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final transaksiDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: transaksiDocs.length,
                    itemBuilder: (context, index) {
                      final transaksiData = transaksiDocs[index].data() as Map<String, dynamic>;
                      final String notrans = transaksiData['notrans'];
                      final String nmpembeli = transaksiData['nmpembeli'];
                      final String nmproduk = transaksiData['nmproduk'];
                      final String hrgproduk = transaksiData['hrgproduk'];
                      final String alamat = transaksiData['alamat'];
                      final String lokasi = transaksiData['lokasi'];
                      final String wa = transaksiData['WA'];

                      // ignore: unused_local_variable
                      int parsedHrgProduk = 0;
                      try {
                        parsedHrgProduk = int.parse(hrgproduk);
                      } catch (e) {
                        // Penanganan kesalahan saat parsing, bisa diabaikan atau berikan nilai default
                        parsedHrgProduk = 0;
                      }

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(nmpembeli),
                          subtitle: Text(notrans),
                          trailing: Text('Rp ${hrgproduk.toString()}'),
                          onTap: () {
                            _showTransaksiDialog(notrans, nmpembeli, nmproduk, hrgproduk, alamat, lokasi, wa);
                          },
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePDF,
        child: const Icon(Icons.print),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Total: Rp $_totalHargaTransaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
