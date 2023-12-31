import 'package:flutter/material.dart';

const Color colorWhite = Colors.white;
const Color colorPrimary = Colors.blue;
const Color colorGrey = Colors.black;
const String backendUrl = 'https://musicservice-31ly.onrender.com';

showScaffold (BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}


