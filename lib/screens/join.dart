import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_testing/screens/register.dart';

import '../util/const.dart';
import 'login.dart';


class JoinApp extends StatefulWidget {
  @override
  _JoinAppState createState() => _JoinAppState();
}



class _JoinAppState extends State<JoinApp> with SingleTickerProviderStateMixin{

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: ()=>Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Constants.lightAccent,
          labelColor: Constants.lightAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          tabs: <Widget>[
            Tab(
              text: "Login",
            ),
            Tab(
              text: "Register",
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          LoginScreen(),
          RegisterScreen(),
        ],
      ),


    );
  }
}
