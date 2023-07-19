import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_food/user/transaksi/transaksi-user.dart';

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