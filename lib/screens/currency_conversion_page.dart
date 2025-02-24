import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  Map<String, double> exchangeRates = {};
  String? fromCurrency = 'USD';
  String? toCurrency = 'EUR';
  double amount = 1.0;
  List convertedAmount = [];

  final List<String> mostUsedCurrencies = ['EUR', 'USD', 'GBP', 'AUD', 'CAD'];

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('exchange_rates').get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        exchangeRates = {
          for (var doc in snapshot.docs)
            if (doc.data().containsKey('rate_to_usd'))
              doc['code']: (doc['rate_to_usd'] as num).toDouble()
            else
              doc['code']: 0.0,
        };
      });
      _calculateConversion();
    }
  }

  void _calculateConversion() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/get_data/get_vehicles'),
    );
    var decode = jsonDecode(response.body);
    if (fromCurrency != null &&
        toCurrency != null &&
        exchangeRates.isNotEmpty) {
      final fromRate = exchangeRates[fromCurrency!]!;
      final toRate = exchangeRates[toCurrency!]!;
      setState(() {
        convertedAmount = decode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          image: DecorationImage(
              image: AssetImage(
                  'lib/assets/currency.png'), // Ensure the file path is correct
              fit: BoxFit.fitWidth,
              alignment: AlignmentDirectional.bottomStart),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    amount = double.tryParse(value) ?? 1.0;
                  });
                  _calculateConversion();
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: fromCurrency,
                onChanged: (newValue) {
                  setState(() {
                    fromCurrency = newValue;
                  });
                  _calculateConversion();
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('--- Most Used Currencies ---'),
                  ),
                  ...mostUsedCurrencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('--- Other Currencies ---'),
                  ),
                  ...exchangeRates.keys.where((currency) {
                    return !mostUsedCurrencies.contains(currency);
                  }).map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }),
                ],
                hint: const Text('Select From Currency'),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: toCurrency,
                onChanged: (newValue) {
                  setState(() {
                    toCurrency = newValue;
                  });
                  _calculateConversion();
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('--- Most Used Currencies ---'),
                  ),
                  ...mostUsedCurrencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('--- Other Currencies ---'),
                  ),
                  ...exchangeRates.keys.where((currency) {
                    return !mostUsedCurrencies.contains(currency);
                  }).map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }),
                ],
                hint: const Text('Select To Currency'),
              ),
              const SizedBox(height: 16),
              if (convertedAmount != 0.0)
                Text(
                  'Converted Amount: $convertedAmount',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
            ],
          ),
        ),
      ),
    );
  }
}
