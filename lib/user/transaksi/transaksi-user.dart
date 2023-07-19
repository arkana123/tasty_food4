import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tasty_food/user/dashboardUser.dart';

class MenuUserPage extends StatefulWidget {
  MenuUserPage({Key? key}) : super(key: key);

  @override
  State<MenuUserPage> createState() => _MenuUserPageState();
}

class _MenuUserPageState extends State<MenuUserPage> {
  late List<DocumentSnapshot> _menuItems;
  late List<DocumentSnapshot> _filteredMenuItems;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  void _fetchMenuItems() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('menu').get();

    setState(() {
      _menuItems = snapshot.docs;
      _filteredMenuItems = _menuItems;
      _isLoading = false;
    });
  }

  void _filterMenuItems(String searchTerm) {
    List<DocumentSnapshot> filteredItems = [];
    filteredItems.addAll(_menuItems);

    if (searchTerm.isNotEmpty) {
      filteredItems.retainWhere((item) {
        String menuItemName = item['nmmenu'].toLowerCase();
        String searchTermLower = searchTerm.toLowerCase();
        return menuItemName.contains(searchTermLower);
      });
    }

    setState(() {
      _filteredMenuItems = filteredItems;
    });
  }

  void _showProductDetails(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(document['nmmenu']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(document['imageUrl']),
              SizedBox(height: 10),
              Text('Deskripsi: ${document['deskripsi']}'),
              SizedBox(height: 10),
              Text('Kategori: ${document['kategori']}'),
              SizedBox(height: 10),
              Text('Harga: ${document['harga']}'),
              SizedBox(height: 10),
              Text('Restoran: ${document['nmresto']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Pesan'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransaksiUserPage(
                      initialData: {
                        'nmproduk': document['nmmenu'],
                        'hrgproduk': document['harga'],
                        'nmresto': document['nmresto'],
                      },
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: Text('Menu'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari menu',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      _filterMenuItems(value);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredMenuItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = _filteredMenuItems[index];
                      return ListTile(
                        onTap: () {
                          _showProductDetails(document);
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(document['imageUrl']),
                        ),
                        title: Text(document['nmmenu']),
                        subtitle: Text('Harga: ${document['harga']}'),
                        trailing: Text('Restoran: ${document['nmresto']}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class TransaksiUserPage extends StatefulWidget {
  TransaksiUserPage({Key? key, required this.initialData}) : super(key: key);

  final Map<String, dynamic> initialData;

  @override
  State<TransaksiUserPage> createState() => _TransaksiUserPageState();
}

class _TransaksiUserPageState extends State<TransaksiUserPage> {
  final TextEditingController _notransController = TextEditingController();
  final TextEditingController _nmpembeliController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _noWAController = TextEditingController();
  final TextEditingController _kurirController = TextEditingController(text: "-");
  final TextEditingController _restoController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  final CollectionReference _transaksi =
      FirebaseFirestore.instance.collection('transaksi');

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generateTransactionNumber();
    _setRestoControllerValue();
  }

  void _generateTransactionNumber() async {
    final QuerySnapshot snapshot = await _transaksi.get();
    final int count = snapshot.docs.length;
    final String notrans = 'INV-TRANS${count + 1}'.padLeft(10, '0');
    _notransController.text = notrans;
  }

  void _setRestoControllerValue() {
    _restoController.text = widget.initialData['nmresto'];
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _getLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      final Position? position = await _getCurrentLocation();
      if (position != null) {
        setState(() {
          _lokasiController.text =
              '${position.latitude}, ${position.longitude}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan lokasi.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan lokasi.'),
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _updateTotalHarga() {
    int harga = int.tryParse(widget.initialData['hrgproduk']) ?? 0;
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    int total = harga * jumlah;
    _totalController.text = total.toString();
  }


  Future<void> _createTransaksi() async {
    final String notrans = _notransController.text;
    final String nmpembeli = _nmpembeliController.text;
    final String nmproduk = widget.initialData['nmproduk'];
    final String hrgproduk = widget.initialData['hrgproduk'];
    final String alamat = _alamatController.text;
    final String lokasi = _lokasiController.text;
    final String WA = _noWAController.text;
    final String kurir = _kurirController.text;
    final String resto = _restoController.text;

    if (notrans.isEmpty ||
        nmpembeli.isEmpty ||
        alamat.isEmpty ||
        lokasi.isEmpty ||
        WA.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field.'),
        ),
      );
      return;
    }

    try {
      await _transaksi.add({
        "notrans": notrans,
        "nmpembeli": nmpembeli,
        "nmproduk": nmproduk,
        "hrgproduk": hrgproduk,
        "jumlah": int.tryParse(_jumlahController.text) ?? 0,
        "total": int.tryParse(_totalController.text) ?? 0,
        "alamat": alamat,
        "lokasi": lokasi,
        "WA": WA,
        "kurir": kurir,
        "nmresto": resto,
      });

      _notransController.text = '';
      _nmpembeliController.text = '';
      _alamatController.text = '';
      _lokasiController.text = '';
      _noWAController.text = '';
      _kurirController.text = '';
      _restoController.text = '';
      _jumlahController.text = '';
      _totalController.text = '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil ditambahkan'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardUser()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan transaksi. Silakan coba lagi.'),
        ),
      );
    }
  }

  // ...
  // Metode lainnya

  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _notransController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'No. Transaksi',
              ),
            ),
            TextField(
              controller: _nmpembeliController,
              decoration: const InputDecoration(
                labelText: 'Nama Pembeli',
              ),
            ),
            TextField(
              controller: TextEditingController(text: widget.initialData['nmproduk']),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Produk',
              ),
            ),
            TextField(
              controller: TextEditingController(text: widget.initialData['hrgproduk'].toString()),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Harga',
              ),
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
              ),
              onChanged: (_) {
                _updateTotalHarga();
              },
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _totalController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Total Harga',
              ),
            ),
            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lokasiController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : _getLocation,
                  icon: _loading ? CircularProgressIndicator() : const Icon(Icons.location_on),
                ),
              ],
            ),
            TextField(
              controller: _noWAController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
              ),
            ),
            TextField(
              controller: _kurirController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Kurir',
              ),
            ),
            TextField(
              controller: _restoController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Resto',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _createTransaksi();
              },
              child: const Text('Pesan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
