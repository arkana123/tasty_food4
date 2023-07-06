import 'package:flutter/material.dart';
import 'dart:math';
class Constants{

  static String appName = "Tasty Food";

  //Colors for theme
//  Color(0xfffcfcff);
  static Color lightPrimary = Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.red;
  static Color darkAccent = Colors.red[400]!;
  static Color lightBG = Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color ratingBG = Colors.yellow[600]!;

  final _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final _emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
  final _phoneRegex = RegExp(r'^\+?[\d-]+[\d]+$');
  final _passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');


  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  static String generateRandomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }




}