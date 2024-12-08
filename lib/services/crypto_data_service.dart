import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoDataHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey =
      '9bcb05c18316bcc126402d4482ff1543bbeff54170bc737448048e213a024cf7';

  Future<void> fetchAndStoreCryptoRates() async {
    String listUrl =
        "https://min-api.cryptocompare.com/data/blockchain/list?api_key=$_apiKey";

    final listResponse = await http.get(Uri.parse(listUrl));
    if (listResponse.statusCode == 200) {
      final listData = json.decode(listResponse.body);

      if (listData['Response'] == 'Success') {
        final cryptoList = listData['Data'];
        final symbols = cryptoList.keys.toList();

        const int chunkSize = 100;
        for (var i = 0; i < symbols.length; i += chunkSize) {
          final chunk = symbols.sublist(i,
              i + chunkSize > symbols.length ? symbols.length : i + chunkSize);

          final ratesUrl =
              "https://min-api.cryptocompare.com/data/pricemulti?fsyms=${chunk.join(',')}&tsyms=USD&api_key=$_apiKey";

          final ratesResponse = await http.get(Uri.parse(ratesUrl));
          if (ratesResponse.statusCode == 200) {
            final ratesData = json.decode(ratesResponse.body);

            final batch = _firestore.batch();
            for (var symbol in chunk) {
              if (ratesData.containsKey(symbol) &&
                  ratesData[symbol]['USD'] != null) {
                final rateToUsd = ratesData[symbol]['USD'];

                final docRef =
                    _firestore.collection('crypto_rates').doc(symbol);
                final docSnapshot = await docRef.get();

                if (!docSnapshot.exists) {
                  batch.set(
                      docRef, {'symbol': symbol, 'rate_to_usd': rateToUsd});
                }
              }
            }
            await batch.commit();
          } else {
            print("Failed to fetch rates for chunk: ${ratesResponse.body}");
          }
        }
      } else {
        print("Failed to fetch cryptocurrency list: ${listData['Message']}");
      }
    } else {
      print("Failed to fetch cryptocurrency list: ${listResponse.body}");
    }
  }
}
