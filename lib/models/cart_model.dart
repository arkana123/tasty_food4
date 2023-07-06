class Cart {
  String orderId;
  String userEmail;
  DateTime dateOrdered;
  String orderStatus;
  List<CartMenuItem> cartItems;

  Cart({
    required this.orderId,
    required this.userEmail,
    required this.dateOrdered,
    required this.orderStatus,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      orderId: json['orderId'],
      userEmail: json['userEmail'],
      dateOrdered: DateTime.parse(json['dateOrdered']),
      orderStatus: json['orderStatus'],
      cartItems: List<CartMenuItem>.from(json['cartItems']
          .map((item) => CartMenuItem.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userEmail': userEmail,
      'dateOrdered': dateOrdered.toIso8601String(),
      'orderStatus': orderStatus,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
    };
  }
}

class CartMenuItem {
  String itemId;
  String name;
  double price;
  int quantity;
  List<String> photos;

  CartMenuItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.photos,
  });

  factory CartMenuItem.fromJson(Map<String, dynamic> json) {
    return CartMenuItem(
      itemId: json['itemId'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      photos: List<String>.from(json['photos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'photos': photos,
    };
  }
}