import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _jambukaController = TextEditingController();
  final TextEditingController _jamtutupController = TextEditingController();

  final CollectionReference _produkCollection =
      FirebaseFirestore.instance.collection('restaurant');

  File? _selectedImage;

  Future<void> _selectImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _namaController.text = documentSnapshot['nmresto'];
      _alamatController.text = documentSnapshot['alamat'];
      _jambukaController.text = documentSnapshot['jam_buka'];
      _jamtutupController.text = documentSnapshot['Jam_tutup'];
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                              Expanded(
                  flex: 2,
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue)
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _selectedImage == null
                                 ? Center(child: Text('No Image Selected'))
                                 : Image.file(_selectedImage!, fit: BoxFit.fitWidth),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              _selectImage();
                            } ,
                            child: Text('Pilih Gambar'),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Resto'),
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: _jambukaController,
                decoration: const InputDecoration(labelText: 'Jam Buka'),
              ),
              TextField(
                controller: _jamtutupController,
                decoration: const InputDecoration(labelText: 'Jam Tutup'),
              ),

              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final String? nama = _namaController.text;
                  final String? alamat = _alamatController.text;
                  final String? jam_buka = _jambukaController.text;
                  final String? jam_tutup = _jamtutupController.text;

                  if (nama != null) {
                    String imageUrl = '';

                    // Upload image if an image is selected
                    if (_selectedImage != null) {
                      final storageRef =
                          firebase_storage.FirebaseStorage.instance.ref().child('resto').child('resto-${DateTime.now().millisecondsSinceEpoch}.jpg');

                      await storageRef.putFile(_selectedImage!);

                      imageUrl = await storageRef.getDownloadURL();
                    }

                    if (action == 'create') {
                      await _produkCollection.add({
                        'nmresto': nama,
                        'alamat': alamat,
                        'jam_buka': jam_buka,
                        'jam_tutup': jam_tutup,
                        'imageUrl': imageUrl,
                      });
                    }

                    if (action == 'update') {
                      await _produkCollection.doc(documentSnapshot!.id).update({
                        'nmresto': nama,
                        'alamat': alamat,
                        'jam_buka': jam_buka,
                        'jam_tutup': jam_tutup,
                        'imageUrl': imageUrl,
                      });
                    }

                    _namaController.text = '';
                    _alamatController.text = '';
                    _jambukaController.text = '';
                    _jamtutupController.text = '';
                    _selectedImage = null;

                    Navigator.of(context).pop();
                  }
                },
                child: Text(action == 'create' ? 'Tambah' : 'Ubah'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus resto ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Ya', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await _produkCollection.doc(productId).delete();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resto berhasil dihapus!'),
                  ),
                );
              },
            ),
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.red)),
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
        title: const Text('Data Restaurant'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _produkCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot document =
                    snapshot.data!.docs[index];

                return ListTile(
                  leading: document['imageUrl'] != null
                      ? Image.network(
                          document['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(document['nmresto']),
                  subtitle: Text(document['alamat'].toString()),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.green,
                          onPressed: () =>
                              _createOrUpdate(document),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () =>
                              _deleteProduct(document.id),
                        ),
                      ],
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
