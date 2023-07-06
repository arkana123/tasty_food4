import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:restaurant_testing/screens/admin/add_restaurant_screen.dart';

import '../models/order_model.dart';
import '../util/categories.dart';
import '../util/const.dart';
import '../util/foods.dart';
import '../widget/grid_product.dart';
import '../widget/home_category.dart';
import '../widget/slider_item.dart';
import 'dishes.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  late List<Widget> carouselItems;
  late List<Widget> carouselRestaurants;
  late List<Restaurant> restaurantList;

  bool isLoading = true;

  int _current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchRestaurantsFromFirestore();

    carouselItems = List<Widget>.generate(
      foods.length,
      (index) => SliderItem(
        img: foods[index]['img'],
        isFav: false,
        name: foods[index]['name'],
        rating: 4.0,
        raters: 23,
      ),
    );


  }


  Future<List<Restaurant>> fetchRestaurantsFromFirestore() async {
    List<Restaurant> restaurantList = [];

    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('restaurants').get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Restaurant restaurant = Restaurant.fromJson(data);
        restaurantList.add(restaurant);
      }
    } catch (error) {
      print('Error fetching restaurants: $error');
    }

    debugPrint("${restaurantList.length}");
    setState(() {
      this.restaurantList = restaurantList;
      this.isLoading = false;
      carouselRestaurants = List<Widget>.generate(restaurantList.length, (index) {
        Restaurant restaurant = restaurantList[index];

        return SliderItem(name: restaurant.restaurantName, img: restaurant.restaurantPhotos[0], isFav: false, rating: restaurant.rating, raters: restaurant.reviews.length);
      });
    });


    return restaurantList;

  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: FutureBuilder<List<Restaurant>>(
        future: fetchRestaurantsFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!(snapshot.connectionState == ConnectionState.waiting)) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading restaurant: ${snapshot.error}');
          } else {
            return Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: ListView(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return RestaurantInputScreen();
                        },
                      ));
                    },
                    child: Text("Tambah Restaurant"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Text(
                        "Daftar Restaurant",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          "Lihat",
                          style: TextStyle(
//                      fontSize: 22,
//                      fontWeight: FontWeight.w800,
                            color: Constants.lightAccent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return DishesScreen();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0),

                  //Slider Here

//             CarouselSlider(
//               height: MediaQuery.of(context).size.height/2.4,
//               items: map<Widget>(
//                 foods,
//                     (index, i){
//                       Map food = foods[index];
//                   return SliderItem(
//                     img: food['img'],
//                     isFav: false,
//                     name: food['name'],
//                     rating: 5.0,
//                     raters: 23,
//                   );
//                 },
//               ).toList(),
//               autoPlay: true,
// //                enlargeCenterPage: true,
//               viewportFraction: 1.0,
// //              aspectRatio: 2.0,
//               onPageChanged: (index) {
//                 setState(() {
//                   _current = index;
//                 });
//               },
//             ),
                  CarouselSlider(
                    items: carouselRestaurants,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 2.4,
                      viewportFraction: 1,
                      initialPage: 0,
                      aspectRatio: 2.0,
                      enableInfiniteScroll: true,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Text(
                        "Baru Ditambahkan",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          "Lihat",
                          style: TextStyle(
//                      fontSize: 22,
//                      fontWeight: FontWeight.w800,
                            color: Constants.lightAccent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return DishesScreen();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  CarouselSlider(
                    items: carouselRestaurants,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 2.4,
                      viewportFraction: 1,
                      initialPage: 0,
                      aspectRatio: 2.0,
                      enableInfiniteScroll: true,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  SizedBox(height: 20.0),

                  Text(
                    "Kategori Makanan",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10.0),

                  Container(
                    height: 65.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: categories == null ? 0 : categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map cat = categories[index];
                        return HomeCategory(
                          icon: cat['icon'],
                          title: cat['name'],
                          items: cat['items'].toString(),
                          isHome: true,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Menu Populer",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          "View More",
                          style: TextStyle(
//                      fontSize: 22,
//                      fontWeight: FontWeight.w800,
                            color: Constants.lightAccent,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.25),
                    ),
                    itemCount: foods == null ? 0 : foods.length,
                    itemBuilder: (BuildContext context, int index) {
//                Food food = Food.fromJson(foods[index]);
                      Map food = foods[index];
//                print(foods);
//                print(foods.length);
                      return GridProduct(
                        img: food['img'],
                        isFav: false,
                        name: food['name'],
                        rating: 5.0,
                        raters: 23,
                      );
                    },
                  ),

                  SizedBox(height: 30),
                ],
              ),
            );
          }
        },

      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
