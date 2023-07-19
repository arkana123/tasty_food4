import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransaksiPage extends StatefulWidget {
  TransaksiPage({Key? key}) : super(key: key);

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final TextEditingController _notransController = TextEditingController();
  final TextEditingController _nmpembeliController = TextEditingController();
  final TextEditingController _nmprodukController = TextEditingController();
  final TextEditingController _hrgprodukController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _noWAController = TextEditingController();
  final TextEditingController _restoController = TextEditingController();
  final TextEditingController _totalHargaController = TextEditingController();
  final TextEditingController _kurirController = TextEditingController();

  final CollectionReference _transaksi =
      FirebaseFirestore.instance.collection('transaksi');
  // ignore: unused_field
  final CollectionReference _kurir =
      FirebaseFirestore.instance.collection('kurir');

  int jumlahProduk = 1;
  int hargaProduk = 0;
  int totalHarga = 0;

  void _tambahProduk() {
    setState(() {
      jumlahProduk++;
      _jumlahController.text = jumlahProduk.toString();
      hitungHargaProduk();
    });
  }

  void _kurangiProduk() {
    if (jumlahProduk > 1) {
      setState(() {
        jumlahProduk--;
        _jumlahController.text = jumlahProduk.toString();
        hitungHargaProduk();
      });
    }
  }

  void hitungHargaProduk() {
    int hargaPerProduk = int.tryParse(_hrgprodukController.text) ?? 0;
    hargaProduk = jumlahProduk * hargaPerProduk;
    _totalHargaController.text = hargaProduk.toString();
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _notransController.text = documentSnapshot['notrans'];
      _nmpembeliController.text = documentSnapshot['nmpembeli'];
      _nmprodukController.text = documentSnapshot['nmproduk'];
      _hrgprodukController.text = documentSnapshot['hrgproduk'].toString();
      _jumlahController.text = documentSnapshot['jumlah'].toString();
      _alamatController.text = documentSnapshot['alamat'];
      _lokasiController.text = documentSnapshot['lokasi'];
      _noWAController.text = documentSnapshot['WA'];
      _restoController.text = documentSnapshot['nmresto'];
      _totalHargaController.text = documentSnapshot['total'].toString();
      _kurirController.text = documentSnapshot['kurir'];
      jumlahProduk = documentSnapshot['jumlah'];
      hitungHargaProduk();
    } else {
      // Generate the transaction number
      final QuerySnapshot snapshot =
          await _transaksi.get(); // Get all transactions
      final int count = snapshot.docs.length;
      final String notrans = 'INV-TRANS${count + 1}'.padLeft(10, '0');
      _notransController.text = notrans;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            // prevent the soft keyboard from covering text fields
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _notransController,
                readOnly: true, // Set text field as read-only
                decoration: const InputDecoration(
                  labelText: 'No Transaksi',
                ),
              ),
              TextField(
                controller: _nmpembeliController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pembeli',
                ),
              ),
              TextField(
                controller: _nmprodukController,
                decoration: const InputDecoration(
                  labelText: 'Produk',
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: _kurangiProduk,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _jumlahController,
                      onChanged: (value) {
                        setState(() {
                          jumlahProduk = int.tryParse(value) ?? 0;
                          hitungHargaProduk();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _tambahProduk,
                  ),
                ],
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: _hrgprodukController,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                readOnly: true,
                controller: _totalHargaController,
                decoration: const InputDecoration(labelText: 'Total Harga'),
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi atau Link Google Map',
                ),
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: _noWAController,
                decoration: const InputDecoration(labelText: 'WA (Wajib)'),
              ),
              TextField(
                controller: _restoController,
                decoration: const InputDecoration(labelText: 'Restoran'),
              ),
              TextField(
                controller: _kurirController,
                decoration: const InputDecoration(labelText: 'Kurir'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Tambah' : 'Ubah'),
                onPressed: () async {
                  final String? nmpembeli = _nmpembeliController.text;
                  final String? nmproduk = _nmprodukController.text;
                  final String? hrgproduk = _hrgprodukController.text;
                  final String? alamat = _alamatController.text;
                  final String? lokasi = _lokasiController.text;
                  final String? WA = _noWAController.text;
                  final String? resto = _restoController.text;
                  // ignore: unused_local_variable
                  final String? total = _totalHargaController.text;
                  final String? kurir = _kurirController.text;

                  if (nmpembeli != null &&
                      nmproduk != null &&
                      resto != null &&
                      hrgproduk != null) {
                    int totalHarga = int.tryParse(hrgproduk) ?? 0 * jumlahProduk;
                    _totalHargaController.text = totalHarga.toString();

                    if (action == 'create') {
                      await _transaksi.add({
                        "notrans": _notransController.text,
                        "nmpembeli": nmpembeli,
                        "nmproduk": nmproduk,
                        "hrgproduk": hrgproduk,
                        "jumlah": jumlahProduk,
                        "alamat": alamat,
                        "lokasi": lokasi,
                        "WA": WA,
                        "nmresto": resto,
                        "total": totalHarga.toString(),
                        "kurir": kurir,
                      });
                    }

                    if (action == 'update') {
                      await _transaksi.doc(documentSnapshot!.id).update({
                        "nmpembeli": nmpembeli,
                        "nmproduk": nmproduk,
                        "hrgproduk": hrgproduk,
                        "jumlah": jumlahProduk,
                        "alamat": alamat,
                        "lokasi": lokasi,
                        "WA": WA,
                        "nmresto": resto,
                        "total": totalHarga.toString(),
                        "kurir": kurir,
                      });
                    }

                    _notransController.text = '';
                    _nmpembeliController.text = '';
                    _nmprodukController.text = '';
                    _hrgprodukController.text = '';
                    _jumlahController.text = '';
                    _alamatController.text = '';
                    _lokasiController.text = '';
                    _noWAController.text = '';
                    _restoController.text = '';
                    _totalHargaController.text = '';
                    _kurirController.text = '';
                    jumlahProduk = 1;
                    hargaProduk = 0;
                    totalHarga = 0;

                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTransaksi(String transaksiId) async {
    await _transaksi.doc(transaksiId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Berhasil Menghapus Data Transaksi')));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Data Transaksi'),
      ),
      body: StreamBuilder(
        stream: _transaksi.where('nmresto', isEqualTo: user!.displayName).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['notrans']),
                    subtitle: Text(documentSnapshot['total'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            onPressed: () =>
                                _createOrUpdate(documentSnapshot),
                          ),
                        ],
                      ),
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
