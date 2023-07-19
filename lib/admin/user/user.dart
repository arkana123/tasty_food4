import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_food/admin/user/addUser.dart';

class UserManagement extends StatefulWidget {
  UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('users');

  Future<void> _deleteUser(String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus user ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await _user.doc(userId).delete();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User berhasil dihapus!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String email = '';
        String rool = '';
        _user.doc(userId).get().then((snapshot) {
          if (snapshot.exists) {
            email = snapshot.get('email');
            rool = snapshot.get('role').toString();
          }
        }).whenComplete(() {
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Edit User'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: email,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                        TextFormField(
                          initialValue: rool,
                          decoration: InputDecoration(
                            labelText: 'Role',
                          ),
                          onChanged: (value) {
                            // Update rool value
                            _user.doc(userId).update({'role': value});
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Simpan', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserManagement()),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          });
        });

        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data User'),
      ),
      body: StreamBuilder(
        stream: _user.snapshots(),
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
                    title: Text(documentSnapshot['email']),
                    subtitle: Text(documentSnapshot['role'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            onPressed: () => _editUser(documentSnapshot.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () =>
                                _deleteUser(documentSnapshot.id),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahUser()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
