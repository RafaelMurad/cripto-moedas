import 'package:flutter/material.dart';
import 'package:untitled/models/moedas.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class MoedasDetalhesPage extends StatefulWidget {
  Moeda moeda;
  MoedasDetalhesPage({Key? key, required this.moeda}) : super(key: key);

  @override
  _MoedasDetalhesPageState createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  final _form = GlobalKey<FormState>();
  final _valor = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.moeda.nome),
        ),
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Image.asset(widget.moeda.icone),
                      width: 60,
                    ),
                    Container(
                      width: 10,
                    ),  
                    Text(
                      real.format(widget.moeda.preco),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                          color: Colors.grey[800]),
                    )
                  ],
                ),
              ),
              Form(
                key: _form,
                child: TextFormField(
                  controller: _valor,
                ),
              )
            ],
          ),
        ));
  }
}
