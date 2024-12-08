import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Your API key for the ExchangeRate-API
  final String _apiKey =
      '8a174201e4cac02325a340dd'; // Replace with your actual API key

  // Function to fetch exchange rates from the API and save to Firestore
  Future<void> fetchAndSaveExchangeRates() async {
    final url =
        Uri.parse('https://v6.exchangerate-api.com/v6/$_apiKey/latest/USD');

    // Make a GET request to fetch the data
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the response is successful, parse the JSON data
      final data = json.decode(response.body);

      if (data['result'] == 'success') {
        final rates = data['conversion_rates'];

        // Iterate through each currency and check if the rate already exists in Firestore
        for (var currency in rates.keys) {
          // Check if the document already exists
          final docRef = _firestore.collection('exchange_rates').doc(currency);
          final docSnapshot = await docRef.get();

          if (!docSnapshot.exists) {
            // If the document does not exist, save the rate
            await docRef.set({
              'code': currency,
              'rate_to_usd': rates[currency],
            });
            print("Added exchange rate for $currency.");
          } else {
            print("Exchange rate for $currency already exists. Skipping.");
          }
        }
      } else {
        print("Error: ${data['result']}");
      }
    } else {
      print("Failed to fetch exchange rates: ${response.statusCode}");
    }
  }
}
