import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_testing/screens/main_screen.dart';

import '../../models/order_model.dart';
import '../../util/const.dart';

class RestaurantInputScreen extends StatefulWidget {
  @override
  _RestaurantInputScreenState createState() => _RestaurantInputScreenState();
}

class _RestaurantInputScreenState extends State<RestaurantInputScreen> {
  // Declare variables to store input values
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();

  TimeOfDay _selectedOpenTime = TimeOfDay(hour: 9, minute: 00);
  TimeOfDay _selectedCloseTime = TimeOfDay(hour: 10, minute: 00);

  late String imageUrl;

  late Restaurant newRestaurant;

  bool _uploading = false;

  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Restaurant'),
      ),
      body: FutureBuilder(
        future: _uploading ? uploadImageToStorage() : null,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error uploading restaurant: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
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
                              ? Center(
                                child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                                _pickedImage!,
                            ),
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
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Restaurant',
                            ),
                          ),
                          SizedBox(height: 16.0),

                          Text(
                            'Detail Restaurant',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 10,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi Restaurant',
                            ),
                          ),
                          // Add more TextFormFields for other fields

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _selectTime(context, true);
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Jam Buka',
                                      hintText: 'Pilih Jam Buka',
                                    ),
                                    child: Text(
                                      _selectedOpenTime != null
                                          ? _selectedOpenTime.format(context)
                                          : 'Pilih Jam Buka',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _selectTime(context, false);
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Jam Tutup',
                                      hintText: 'Pilih Jam Tutup',
                                    ),
                                    child: Text(
                                      _selectedCloseTime != null
                                          ? _selectedCloseTime.format(context)
                                          : 'Pilih Jam Tutup',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _addressController,
                            minLines: 3,
                            maxLines: 6,
                            decoration: InputDecoration(
                              labelText: 'Alamat',
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _tagsController,
                            decoration: InputDecoration(
                              labelText: 'Tags',
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _longitudeController,
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _latitudeController,
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      // Create a new Restaurant object with the entered values
                      Restaurant newRestaurant = Restaurant(
                        restaurantId: '',
                        restaurantName: _nameController.text,
                        restaurantDescription: _descriptionController.text,
                        openTime: _selectedOpenTime.format(context),
                        closeTime: _selectedCloseTime.format(context),
                        tags: _tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                        address: _addressController.text,
                        longitude: double.parse(_longitudeController.text),
                        latitude: double.parse(_latitudeController.text),
                        dateCreated: DateTime.now(),
                        dateModified: DateTime.now(),
                        restaurantPhotos: [],
                        restaurantMenus: [],
                        rating: 0.0,
                        reviews: [],
                      );

                      // TODO: Handle the newRestaurant object as desired
                      setState(() {
                        this.newRestaurant = newRestaurant;
                        _uploading = true;
                      });
                      uploadImageToStorage();
                    },
                    child: Text('Simpan Restaurant'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _tagsController.dispose();
    _addressController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    super.dispose();
  }

  Future<void> uploadDataToFirestore(String imageUrl) async {
    try {

      List<String> restaurantsPhoto = [imageUrl];

      newRestaurant.restaurantPhotos = restaurantsPhoto;
      String id = Constants.generateRandomString(10);
      newRestaurant.restaurantId = id;

      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('restaurants');

      await collectionRef.doc(id).set(newRestaurant.toJson());
      print('Restaurant uploaded successfully with ID: ${id}');
      Constants.showSnackBar(context, "Restaurant Berhasil Ditambahkan");
      setState(() {
        _uploading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } catch (error) {
      throw error;
    }
  }

  Future <void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isOpenTime) {
          _selectedOpenTime = pickedTime;
        } else {
          _selectedCloseTime = pickedTime;
        }
      });
    }
  }

  Future <void> uploadImageToStorage() async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(imageName);
    await ref.putFile(this._pickedImage!);
    await ref.getDownloadURL().then((value) {
      setState(() {
        this.imageUrl = value;
      });
      uploadDataToFirestore(value);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }
}
