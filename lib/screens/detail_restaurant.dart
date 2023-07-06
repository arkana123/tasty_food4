import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailScreen({required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRestaurantFromFirestore();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Detail'),
      ),
      body: FutureBuilder<Restaurant>(
        future: fetchRestaurantFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot<Restaurant> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Restaurant restaurant = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.restaurantName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(restaurant.restaurantDescription),
                  SizedBox(height: 16),
                  Text('Open Time: ${restaurant.openTime}'),
                  Text('Close Time: ${restaurant.closeTime}'),
                  SizedBox(height: 16),
                  // Add more details as needed
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Restaurant> fetchRestaurantFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
        Restaurant restaurant = Restaurant.fromJson(data);
        return restaurant;
      }
    } catch (error) {
      print('Error fetching restaurant: $error');
    }

    throw Exception('Restaurant not found');
  }
}