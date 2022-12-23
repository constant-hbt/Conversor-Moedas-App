import 'package:flutter/material.dart';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'dart:async';

void main() async {
  runApp(
    MaterialApp(
      home: const Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          )),
    ),
  );
}

Future<Map<String, dynamic>> getData() async {
  var url = Uri.https(
      'api.hgbrasil.com', '/finance', {'format': 'json', 'key': '07a03b44'});
  var response = await http.get(url);
  return convert.jsonDecode(response.body) as Map<String, dynamic>;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  late double realCurrency;
  late double dollarCurrency;
  late double euroCurrency;

  void _realChanged(double real){
    dollarController.text = (real/dollarCurrency).toStringAsFixed(2);
    euroController.text = (real/euroCurrency).toStringAsFixed(2);
  }

  void _dollarChanged(double dollar){
    realController.text = (dollar * dollarCurrency).toStringAsFixed(2);
    euroController.text = (dollar * dollarCurrency / euroCurrency).toStringAsFixed(2);
  }

  void _euroChanged(double euro){
    realController.text = (euro * euroCurrency).toStringAsFixed(2);
    dollarController.text = (euro * euroCurrency / dollarCurrency).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = '';
    dollarController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('\$ Converter \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    'Loading data',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Loading Error',
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollarCurrency = snapshot.data?['results']['currencies']['USD']
                          ['buy'] ??
                      0.0;
                  euroCurrency = snapshot.data?['results']['currencies']['EUR']
                          ['buy'] ??
                      0.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextField('Reais', 'R\$', realController, _realChanged, _clearAll),
                        const Divider(),
                        buildTextField('Dólares', 'US\$', dollarController, _dollarChanged, _clearAll),
                        const Divider(),
                        buildTextField('Euros', '€', euroController, _euroChanged, _clearAll),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function(double) onChange, Function clearInputs) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: (text){
      if(text.isEmpty){
        clearInputs();
        return;
      }

      text = text.isEmpty ? '0' : text.replaceAll(',', '.');
      double money = double.parse(text);
      onChange(money);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: c,
  );
}
