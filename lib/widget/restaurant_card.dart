import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final String imageUrl;

  RestaurantCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const Icon(Icons.photo_outlined) as ImageProvider,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Icon(Icons.add_a_photo)
          ),
        ],
      ),
    );
  }
}