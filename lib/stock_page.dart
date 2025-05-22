import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  bool isLoading = false;
  Map<String, dynamic> stockData = {};
  String stockSymbol = 'AAPL'; // Default symbol (Apple Inc.)
  final String apiKey = 'YOUR_API_KEY'; // Ganti dengan API key Alpha Vantage

  // Fungsi untuk mengambil data saham
  Future<void> fetchStockData() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$stockSymbol&interval=5min&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        stockData = data['Time Series (5min)'] ?? {};
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data saham')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pergerakan Saham'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchStockData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown untuk memilih simbol saham
            TextField(
              decoration: const InputDecoration(
                labelText: 'Masukkan Simbol Saham (misal: AAPL)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  stockSymbol = value.toUpperCase();
                });
                fetchStockData();
              },
            ),
            const SizedBox(height: 20),

            // Menampilkan informasi saham jika data ada
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : stockData.isEmpty
                    ? const Center(child: Text('Tidak ada data saham'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: stockData.length,
                          itemBuilder: (context, index) {
                            String time = stockData.keys.elementAt(index);
                            var details = stockData[time];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Waktu: $time'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Harga Terakhir: ${details['4. close']}'),
                                    Text('Volume: ${details['5. volume']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
