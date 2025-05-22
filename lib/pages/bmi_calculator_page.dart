// bmi_calculator_page.dart
import 'package:flutter/material.dart';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  _BmiCalculatorPageState createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _bmiResult;

  String get _bmiCategory {
    if (_bmiResult == null) return '';
    if (_bmiResult! < 18.5)
      return 'Kurang Berat Badan';
    else if (_bmiResult! < 24.9)
      return 'Normal';
    else if (_bmiResult! < 29.9)
      return 'Berlebih';
    else
      return 'Obesitas';
  }

  void calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double heightMeters = (double.tryParse(_heightController.text) ?? 0) / 100;

    if (weight > 0 && heightMeters > 0) {
      setState(() {
        _bmiResult = weight / (heightMeters * heightMeters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hitung BMI"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Berat Badan (kg)"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Tinggi Badan (cm)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text("Hitung BMI"),
            ),
            SizedBox(height: 30),
            if (_bmiResult != null)
              Column(
                children: [
                  Text(
                    "BMI Anda: ${_bmiResult!.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Kategori: $_bmiCategory",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Gunakan Nilai Ini"),
              onPressed: _bmiResult == null
                  ? null
                  : () {
                      Navigator.pop(context, _bmiResult!.toStringAsFixed(2));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }
}