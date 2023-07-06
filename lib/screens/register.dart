import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_testing/utils/utils.dart';

import '../util/const.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameControl = new TextEditingController();
  final TextEditingController _phoneNumberControl = new TextEditingController();
  final TextEditingController _emailControl = new TextEditingController();
  final TextEditingController _passwordControl = new TextEditingController();
  final TextEditingController _confirmPasswordControl =
      new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final _emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
  final _phoneRegex = RegExp(r'^\+?[\d-]+[\d]+$');
  final _passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');

  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? emailUtama;
  String? namaUtama;
  String? phoneUtama;

  File? _pickedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  String? _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name is required';
      } else if (!_nameRegex.hasMatch(value)) {
        _nameError = 'Invalid name';
      } else {
        _nameError = null;
      }
    });

    if (value.isEmpty) {
      return 'Name is required';
    } else if (!_nameRegex.hasMatch(value)) {
      return 'Invalid name';
    } else {
      return null;
    }
  }

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

  String? _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (!_phoneRegex.hasMatch(value)) {
        _phoneError = 'Invalid phone number';
      } else {
        _phoneError = null;
      }
    });

    if (value.isEmpty) {
      return 'Phone number is required';
    } else if (!_phoneRegex.hasMatch(value)) {
      return 'Invalid phone number';
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

  String? _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Confirm password is required';
      } else if (value != _passwordControl.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });

    if (value.isEmpty) {
      return 'Confirm password is required';
    } else if (value != _passwordControl.text) {
      return 'Passwords do not match';
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _usernameControl.dispose();
    _phoneNumberControl.dispose();
    _emailControl.dispose();
    _passwordControl.dispose();
    _confirmPasswordControl.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Input validation passed, proceed with registration logic
      String name = _usernameControl.text;
      String email = _emailControl.text;
      String password = _passwordControl.text;
      String confirmPassword = _confirmPasswordControl.text;
      String phoneNumber = _phoneNumberControl.text;

      setState(() {
        emailUtama = _emailControl.text;
        namaUtama = _usernameControl.text;
        phoneUtama = _phoneNumberControl.text;
      });

      // Add your registration logic here

      // Clear the form fields after successful registration
      _usernameControl.clear();
      _emailControl.clear();
      _phoneNumberControl.clear();
      _passwordControl.clear();
      _confirmPasswordControl.clear();

      // Display a success message or navigate to the next screen
      _registerUserInput(name, email, password, phoneNumber);
      setState(() {
        _loading = true;
      });
    }
  }

  Future<String> _uploadImageToStorage(File image) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(imageName);
    await ref.putFile(image);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  void  _saveImageURLToFirestore(String imageURL) {
    FirebaseFirestore.instance.collection('users').doc(emailUtama).set({
      'email': emailUtama,
      'nama': namaUtama,
      'nohp': phoneUtama,
      'role': 'User',
      'alamat': '-',
      'imageURL': imageURL,
    }).then(
      (value) {
        setState(() {
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Akun anda berhasil dibuat!')));
      },
    ).catchError((error) => print('Failed to save image URL: $error'));
  }

  Future<void> _uploadAndSave() async {
    if (_pickedImage != null) {
      String imageURL = await _uploadImageToStorage(_pickedImage!);
      debugPrint(imageURL);
      _saveImageURLToFirestore(imageURL);
    }
  }

  void _registerUserInput(
      String name, String email, String password, String phoneNumber) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, // Replace with the entered email
        password: password, // Replace with the entered password
      );
      // Registration successful, navigate to the home screen
    } catch (e) {
      // Registration failed, handle the error
      print(e.toString());

      setState(() {
        _loading = false;
      });
      return;
    } finally {
      _uploadAndSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0, 20, 0),
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
                    "Daftar Akun Baru",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: Constants.lightAccent,
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Stack(
                        children: [
                          _pickedImage != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    _pickedImage!,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FloatingActionButton(
                              onPressed: () {
                                // Add your logic for the add photo action here

                                _pickImage(ImageSource.gallery);
                              },
                              child: Icon(Icons.add_a_photo),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
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
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        errorText: _nameError,
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Nama",
                        prefixIcon: Icon(
                          Icons.perm_identity,
                          color: Colors.black,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                      validator: (value) => _validateName(value!),
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
                      validator: (value) => _validateEmail(value!),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Email",
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: Colors.black,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                      maxLines: 1,
                      controller: _emailControl,
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
                      validator: (value) => _validatePhone(value!),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "No HP",
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                      maxLines: 1,
                      controller: _phoneNumberControl,
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
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
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
                      validator: (value) => _validateConfirmPassword(value!),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Konfirmasi Password",
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
                      controller: _confirmPasswordControl,
                    ),
                  ),
                ),
                SizedBox(height: 40.0),
                Container(
                  height: 50.0,
                  child: ElevatedButton(
                    child: Text(
                      "Register".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Constants.lightAccent),
                    ),
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (BuildContext context) {
                      //       return MainScreen();
                      //     },
                      //   ),
                      // );

                      if (_pickedImage != null) {
                        _register();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Mohon pilih foto profil anda!')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                Divider(
                  color: Constants.lightAccent,
                ),
                SizedBox(height: 10.0),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {},
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
                          onPressed: () {},
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
        if (_loading)
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
