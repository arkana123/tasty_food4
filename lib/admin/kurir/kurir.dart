import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class KurirPage extends StatefulWidget {
  KurirPage({Key? key}) : super(key: key);

  @override
  State<KurirPage> createState() => _KurirPageState();
}

class _KurirPageState extends State<KurirPage> {
    //text field Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _ekspedisiController = TextEditingController();
  final TextEditingController _notelpController = TextEditingController();

  final CollectionReference _kurir= FirebaseFirestore.instance.collection('kurir');

  // Fungsi ini dipicu saat tombol mengambang atau salah satu tombol edit ditekan
  // Menambahkan produk jika tidak ada documentSnapshot yang diteruskan
  // Jika documentSnapshot != null lalu perbarui produk yang sudah ada

    Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _namaController.text = documentSnapshot['nmkurir'];
      _ekspedisiController.text = documentSnapshot['ekspedisi'];
      _notelpController.text = documentSnapshot['WA'].toString();
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
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                  TextField(
                  controller: _ekspedisiController,
                  decoration: const InputDecoration(labelText: 'Ekspedisi'),
                ),
                  TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(),
                  controller: _notelpController,
                  decoration: const InputDecoration(labelText: 'WA'),
                ),

                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Tambah' : 'Ubah'),
                  onPressed: () async {
                    final String? nama = _namaController.text;
                    final String? ekspedisi = _ekspedisiController.text;
                    final String? notelp = _notelpController.text;
                    if (nama != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _kurir.add({
                          "nmkurir": nama, 
                          "ekspedisi" : ekspedisi,
                          "WA": notelp
                          });
                      }

                      if (action == 'update') {
                        // Update the product
                        await _kurir
                            .doc(documentSnapshot!.id)
                            .update({
                              "nmkurir": nama, 
                              "ekspedisi" : ekspedisi,
                              "WA": notelp
                          });
                      }

                      // Clear the text fields
                      _namaController.text = '';
                      _ekspedisiController.text = '';
                      _notelpController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

    // Deleteing a product by id
  Future<void> _deleteKurir(String kurirId) async {
    await _kurir.doc(kurirId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Berhasil Menghapus Data Kurir')));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kurir'),
      ),
      
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _kurir.snapshots(),
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
                    title: Text(documentSnapshot['nmkurir']),
                    subtitle: Text(documentSnapshot['WA'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.green,
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () =>
                                  _deleteKurir(documentSnapshot.id)),
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
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}