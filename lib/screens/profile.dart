import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_testing/screens/splash.dart';
import 'package:restaurant_testing/util/const.dart';

import '../models/user_model.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  late UserModel userModel;

  bool _isLoading = false;

  Future<List<UserModel>> _getUserData() async {
    List<UserModel> users = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('users').get();

    snapshot.docs.forEach((doc) {
      String email = doc.get('email') ?? '';
      String nama = doc.get('nama') ?? '';
      String nohp = doc.get('nohp') ?? '';
      String role = doc.get('role') ?? '';
      String alamat = doc.get('alamat') ?? '';
      String imageURL = doc.get('imageURL') ?? '';

      UserModel user = UserModel(
        email: email,
        nama: nama,
        nohp: nohp,
        role: role,
        alamat: alamat,
        imageURL: imageURL,
      );

      users.add(user);
    });

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserModel>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error when loading data'),
            );
          } else {
            List<UserModel>? users = snapshot.data;


            if(users == null || users.isEmpty) {
              return Center(
                child: Text('No user data available'),
              );
            }

            UserModel user = users.first;

            return Padding(
              padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),

              child: ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Image.network(
                          user.imageURL,
                          fit: BoxFit.cover,
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),

                      SizedBox(width: 10.0,),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  user.nama,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5.0),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  onTap: (){
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context){
                                          return SplashScreen();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text("Logout",
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400,
                                      color: Constants.lightAccent,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                        flex: 3,
                      ),
                    ],
                  ),

                  Divider(),
                  Container(height: 15.0),

                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Informasi Akun".toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListTile(
                    title: Text(
                      "Nama",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    subtitle: Text(
                      user.nama,
                    ),

                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20.0,
                      ),
                      onPressed: (){
                      },
                      tooltip: "Edit",
                    ),
                  ),

                  ListTile(
                    title: Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    subtitle: Text(
                      user.email,
                    ),
                  ),

                  ListTile(
                    title: Text(
                      "No HP",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    subtitle: Text(
                      user.nohp,
                    ),
                  ),

                  ListTile(
                    title: Text(
                      "Alamat",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    subtitle: Text(
                      user.alamat,
                    ),
                  ),

                  ListTile(
                    title: Text(
                      "Role",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    subtitle: Text(
                      user.role,
                    ),
                  ),

                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox()
                      : ListTile(
                    title: Text(
                      "LIGHT THEME",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // trailing: Switch(
                    //   value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
                    //       ? false
                    //       : true,
                    //   onChanged: (v) async{
                    //     if (v) {
                    //       Provider.of<AppProvider>(context, listen: false)
                    //           .setTheme(Constants.darkTheme, "dark");
                    //     } else {
                    //       Provider.of<AppProvider>(context, listen: false)
                    //           .setTheme(Constants.lightTheme, "light");
                    //     }
                    //   },
                    //   activeColor: Theme.of(context).accentColor,
                    // ),
                  ),
                ],
              ),
            );

          }
        },
      ),
    );
  }
}
