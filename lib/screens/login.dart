import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restaurant_testing/screens/admin/main_screen_admin.dart';

import '../util/const.dart';
import 'main_screen.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _usernameControl = new TextEditingController();
  final TextEditingController _passwordControl = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final _emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');

  String? _emailUtama;
  String? _passwordUtama;

  String? _emailError;
  String? _passwordError;

  String? _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_emailRegex.hasMatch(value)) {
        _emailError = 'Invalid email';
      } else {
        _emailError = null;
      }
    });

    if (value.isEmpty) {
      return 'Email is required';
    } else if (!_emailRegex.hasMatch(value)) {
      return 'Invalid email';
    } else {
      return null;
    }
  }

  String? _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 8) {
        _passwordError = 'Password must be at least 8 characters long';
      } else {
        _passwordError = null;
      }
    });

    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _usernameControl.dispose();
    _passwordControl.dispose();
    super.dispose();
  }

  void _login() {
    if(_formKey.currentState!.validate()) {
      String email = _usernameControl.text;
      String password = _passwordControl.text;

      setState(() {
        _emailUtama = email;
        _passwordUtama = password;
      });

      _usernameControl.clear();
      _passwordControl.clear();

      setState(() {
        _loading = true;
      });

      _loginWithUserInput();
    }
  }

  void _loginWithUserInput() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailUtama!, // Replace with the entered email
        password: _passwordUtama!, // Replace with the entered password
      );
      // Registration successful, navigate to the home screen
      // You can replace the line below with your navigation logic
      checkRole();
    } catch (e) {
      // Registration failed, handle the error
      print(e.toString());
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Username atau password salah!')),
      );
      return;
    }
  }

  void checkRole() async {
    DocumentSnapshot<Map<String, dynamic>>? userDocument =
        await FirebaseFirestore.instance.collection('users').doc(_emailUtama).get();

    if (userDocument != null && userDocument.exists) {
      final role = userDocument.data()?['role'];
      if (role == 'Admin') {
        // User is an admin
        print('User is an admin');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context){
              return MainScreenAdmin();
            },
          ),
        );
      } else {
        // User is not an admin
        print('User is not an admin');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context){
              return MainScreen();
            },
          ),
        );


      }
    } else {
      // User document does not exist
      print('User document does not exist');
    }

    setState(() {
      _loading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Berhasil Login!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.0,0,20,0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[

                SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: 25.0,
                  ),
                  child: Text(
                    "Login ke Akun Anda!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: Constants.lightAccent,
                    ),
                  ),
                ),

                SizedBox(height: 30.0),

                Card(
                  elevation: 3.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: TextFormField(
                      validator: (value) => _validateEmail(value!),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.white,),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Email",
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                        prefixIcon: Icon(
                          Icons.perm_identity,
                          color: Colors.black,
                        ),
                      ),
                      maxLines: 1,
                      controller: _usernameControl,
                    ),
                  ),
                ),

                SizedBox(height: 10.0),

                Card(
                  elevation: 3.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: TextFormField(
                      validator: (value) => _validatePassword(value!),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.white,),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Password",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.black,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                      obscureText: true,
                      maxLines: 1,
                      controller: _passwordControl,
                    ),
                  ),
                ),

                SizedBox(height: 10.0),

                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Constants.lightAccent,
                      ),
                    ),
                    onPressed: (){},
                  ),
                ),

                SizedBox(height: 30.0),

                Container(
                  height: 50.0,
                  child: ElevatedButton(
                    child: Text(
                      "LOGIN".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Constants.lightAccent),
                    ),
                    onPressed: (){


                      _login();
                    },
                  ),
                ),

                SizedBox(height: 10.0),
                Divider(color: Constants.lightAccent,),
                SizedBox(height: 10.0),


                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: Row(
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: (){},
                          fillColor: Colors.blue[800],
                          shape: CircleBorder(),
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Icon(
                              FontAwesomeIcons.facebookF,
                              color: Colors.white,
//              size: 24.0,
                            ),
                          ),
                        ),

                        RawMaterialButton(
                          onPressed: (){},
                          fillColor: Colors.white,
                          shape: CircleBorder(),
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Icon(
                              FontAwesomeIcons.google,
                              color: Colors.blue[800],
//              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

              ],
            ),
          ),
        ),
        if(_loading)
          Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
