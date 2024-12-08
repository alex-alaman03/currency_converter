import 'package:flutter/material.dart';
import 'currency_conversion_page.dart';
import 'crypto_currency_conversion_page.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Option'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencyConverterPage(),
                  ),
                );
              },
              child: const Text('Currency Converter'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CryptoCurrencyConverterPage(), // Updated to use the new page
                  ),
                );
              },
              child: const Text('Crypto Currency Converter'),
            ),
          ],
        ),
      ),
    );
  }
}
