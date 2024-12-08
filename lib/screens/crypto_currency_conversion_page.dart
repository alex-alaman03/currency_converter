import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CryptoCurrencyConverterPage extends StatefulWidget {
  const CryptoCurrencyConverterPage({super.key});

  @override
  State<CryptoCurrencyConverterPage> createState() =>
      _CryptoCurrencyConverterPageState();
}

class _CryptoCurrencyConverterPageState
    extends State<CryptoCurrencyConverterPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _allCurrencies = [];
  final List<String> _filteredCurrencies = [];
  String? _selectedCurrency;
  double? _rateToUsd;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCryptoCurrencies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoCurrencies() async {
    final querySnapshot = await _firestore.collection('crypto_rates').get();

    setState(() {
      _allCurrencies.addAll(
        querySnapshot.docs.map((doc) => doc['symbol'] as String),
      );
      _filteredCurrencies.addAll(_allCurrencies);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies.clear();
      if (query.isEmpty) {
        _filteredCurrencies.addAll(_allCurrencies);
      } else {
        _filteredCurrencies.addAll(
          _allCurrencies.where(
            (currency) => currency.toLowerCase().contains(query),
          ),
        );
      }
    });
  }

  Future<void> _fetchRateToUsd(String currency) async {
    final docSnapshot =
        await _firestore.collection('crypto_rates').doc(currency).get();

    if (docSnapshot.exists) {
      setState(() {
        _rateToUsd = docSnapshot['rate_to_usd'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/crypto_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _showCustomDropdown(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCurrency ?? 'Select a cryptocurrency',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedCurrency != null && _rateToUsd != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '1 $_selectedCurrency = $_rateToUsd USD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search cryptocurrency...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        return ListTile(
                          title: Text(currency),
                          onTap: () {
                            setState(() {
                              _selectedCurrency = currency;
                              _rateToUsd = null;
                            });
                            _fetchRateToUsd(currency);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
