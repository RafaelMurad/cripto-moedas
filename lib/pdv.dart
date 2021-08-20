import 'package:flutter/material.dart';
import 'package:untitled/pages/home_page.dart';
// ignore: unused_import
import 'package:untitled/pages/pdvPage.dart';

class PdvScreen extends StatelessWidget {
  const PdvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cripto Moedas",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
