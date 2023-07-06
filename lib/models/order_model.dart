class Restaurant {
  String restaurantId;
  String restaurantName;
  String restaurantDescription;
  String openTime;
  String closeTime;
  List<String> tags;
  String address;
  double longitude;
  double latitude;
  DateTime dateCreated;
  DateTime dateModified;
  List<String> restaurantPhotos;
  List<Menu> restaurantMenus;
  double rating;
  List<Review> reviews;

  Restaurant({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantDescription,
    required this.openTime,
    required this.closeTime,
    required this.tags,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.dateCreated,
    required this.dateModified,
    required this.restaurantPhotos,
    required this.restaurantMenus,
    required this.rating,
    required this.reviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      restaurantDescription: json['restaurantDescription'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      tags: List<String>.from(json['tags']),
      address: json['address'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateModified: DateTime.parse(json['dateModified']),
      restaurantPhotos: List<String>.from(json['restaurantPhotos']),
      restaurantMenus: List<Menu>.from(
        json['restaurantMenus'].map((menu) => Menu.fromJson(menu)),
      ),
      rating: json['rating'],
      reviews: List<Review>.from(
        json['reviews'].map((review) => Review.fromJson(review)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantDescription': restaurantDescription,
      'openTime': openTime,
      'closeTime': closeTime,
      'tags': tags,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'restaurantPhotos': restaurantPhotos,
      'restaurantMenus': restaurantMenus.map((menu) => menu.toJson()).toList(),
      'rating': rating,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}

class Menu {
  String itemId;
  String name;
  String description;
  double price;

  Menu({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      itemId: json['itemId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}

class Review {
  String reviewId;
  String userId;
  double rating;
  String comment;

  Review({
    required this.reviewId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}