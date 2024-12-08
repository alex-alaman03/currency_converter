import 'package:flutter/material.dart';
import 'selection_page.dart';

class CryptoCurrencyConverterPage extends StatelessWidget {
  const CryptoCurrencyConverterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/crypto_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Crypto Currency Converter\nImplementation will come soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40, // Adjust this value for the vertical position of the back button
              left: 10, // Adjust this value for the horizontal position of the back button
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
