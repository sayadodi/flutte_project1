import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan/pages/bmi_calculator_page.dart';
import '../chat_page.dart'; // ⬅️ Import ChatPage
import '../constants.dart'; // Sesuaikan path jika diperlukan

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final TextEditingController _bmiController = TextEditingController();
  int _selectedAgeCode = 0;
  int _selectedGenHlthCode = 0;

  String? _result;
  bool _isLoading = false;
  String _prediction = '';
  double _probability = 0.0;

  final String apiUrl = "https://9f33-34-132-197-37.ngrok-free.app/predict";

  Future<void> sendPrediction() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    double bmi = double.tryParse(_bmiController.text) ?? 0.0;
    if (bmi <= 0) {
      setState(() {
        _result = "Masukkan nilai BMI yang valid";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bmi': bmi,
          'age_code': _selectedAgeCode,
          'genhlth_code': _selectedGenHlthCode,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _prediction = result['prediction'];
          _probability = result['probability'];
          _result =
              "$_prediction (Probabilitas: ${_probability.toStringAsFixed(4)})";
        });
      } else {
        setState(() {
          _result = "Gagal memproses prediksi. Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Koneksi gagal: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediksi Diabetes'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masukkan Data Pasien",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bmiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "BMI",
                  hintText: "Contoh: 25.5",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BmiCalculatorPage(),
                    ),
                  );

                  if (result != null && result is String) {
                    setState(() {
                      _bmiController.text = result;
                    });
                  }
                },
                icon: Icon(Icons.calculate),
                label: Text("Hitung BMI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              Text("Pilih Kelompok Usia", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonFormField<int>(
                    value: _selectedAgeCode,
                    items: ageOrder.asMap().entries.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAgeCode = value;
                        });
                      }
                    },
                    decoration: InputDecoration.collapsed(hintText: ""),
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text("Status Kesehatan Umum", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonFormField<int>(
                    value: _selectedGenHlthCode,
                    items: genHlthOrder.asMap().entries.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGenHlthCode = value;
                        });
                      }
                    },
                    decoration: InputDecoration.collapsed(hintText: ""),
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: _isLoading ? null : sendPrediction,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety),
                          SizedBox(width: 10),
                          Text("Mulai Prediksi"),
                        ],
                      ),
              ),
              if (_result != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _prediction == "Diabetic"
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _prediction == "Diabetic"
                          ? Colors.redAccent
                          : Colors.greenAccent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hasil Prediksi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Divider(),
                      Text("Kondisi: $_prediction",
                          style: TextStyle(fontSize: 16)),
                      Text(
                        "Probabilitas: ${_probability.toStringAsFixed(4)}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    final bmi = double.tryParse(_bmiController.text) ?? 0.0;
                    final ageDesc = ageOrder[_selectedAgeCode];
                    final genHlthDesc = genHlthOrder[_selectedGenHlthCode];

                    final prompt =
                        "Anda dinyatakan sebagai '$_prediction' dengan probabilitas ${_probability.toStringAsFixed(4)}. "
                        "BMI Anda adalah $bmi, usia $ageDesc, dan kesehatan umum $genHlthDesc. "
                        "Berikan saran untuk mengelola kondisi ini.";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(initialMessage: prompt),
                      ),
                    );
                  },
                  icon: Icon(Icons.chat_bubble_outline),
                  label: Text("Konsultasi dengan AI"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
