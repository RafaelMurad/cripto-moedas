import 'package:flutter/material.dart';
import 'package:untitled/pages/pdvPage.dart';

class PdvScreen extends StatelessWidget {
  const PdvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "produtos",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
        child: PdvPage(),
      ),
    );
  }
}
