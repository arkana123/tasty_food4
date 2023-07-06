import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_testing/widget/menu_card.dart';

import '../../util/const.dart';
import '../../util/foods.dart';
import '../../widget/dashboard_card.dart';
import '../../widget/slider_item.dart';
import '../dishes.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  late List<Widget> carouselItems;

  int _current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Dashboard Admin",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
//                 TextButton(
//                   child: Text(
//                     "Lihat",
//                     style: TextStyle(
// //                      fontSize: 22,
// //                      fontWeight: FontWeight.w800,
//                       color: Constants.lightAccent,
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (BuildContext context) {
//                           return DishesScreen();
//                         },
//                       ),
//                     );
//                   },
//                 ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Jumlah Restaurant',
                    description: 'Jumlah Restaurant di Aplikasi Tasty Food',
                    dashboardValue: '90',
                    iconData: Icons.fastfood_outlined,
                  ),
                ),
                SizedBox(height: 10.0),

                Expanded(
                  child: DashboardCard(
                    title: 'Jumlah Menu',
                    description: 'Jumlah Menu di Aplikasi Tasty Food',
                    dashboardValue: '192',
                    iconData: Icons.food_bank,
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),



            DashboardCard(
              title: 'Jumlah Pengguna',
              description: 'Jumlah Pengguna di Aplikasi Tasty Food',
              dashboardValue: '28',
              iconData: Icons.supervised_user_circle_rounded,
            ),
            SizedBox(height: 10.0),
            
            Row(
              children: [
              Expanded(
                child: DashboardCard(
                  title: 'Order Hari ini',
                  description: 'Jumlah Order yang Masuk Hari ini',
                  dashboardValue: '10',
                  iconData: Icons.shopping_cart,
                ),
              ),
              SizedBox(height: 10.0),
  
              Expanded(
                child: DashboardCard(
                  title: 'Total Pendapatan',
                  description: 'Total Laba Bersih dari Aplikasi Tasty Food',
                  dashboardValue: 'Rp,9.000.000,00',
                  iconData: Icons.money,
                ),
              ),
              SizedBox(height: 10.0),
                
              ],
            ),

            MenuCard(title: "Tambah Restaurant Baru", iconData: Icons.add_business),
            SizedBox(height: 10,),
            MenuCard(title: "Tambah Menu Baru", iconData: Icons.add_shopping_cart),
            SizedBox(height: 10,),


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

            // CarouselSlider(
            //   items: carouselItems,
            //   options: CarouselOptions(
            //     height: MediaQuery.of(context).size.height/2.4,
            //     viewportFraction: 1,
            //     initialPage: 0,
            //     aspectRatio: 2.0,
            //     enableInfiniteScroll: true,
            //     scrollDirection: Axis.horizontal,
            //
            //   ),
            // ),


            SizedBox(height: 20.0),


          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
