import 'package:flutter/material.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key}); // <-- pastikan ada const

  @override
  _KalkulatorPageState createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  String input = '';
  String result = '0';

  void _onPressed(String text) {
    setState(() {
      if (text == 'AC') {
        input = '';
        result = '0';
      } else if (text == '=') {
        try {
          result = _calculate(input).toString();
        } catch (e) {
          result = 'Error';
        }
      } else {
        input += text;
      }
    });
  }

  double _calculate(String expression) {
    return double.tryParse(expression) ?? 0;
  }

  Widget _buildButton(
    String text, {
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            foregroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _onPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Kalkulator Sederhana',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      input,
                      style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                    ),
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tombol kalkulator
            Column(
              children: [
                Row(children: [
                  _buildButton('AC', color: Colors.redAccent),
                  _buildButton('⌫'),
                  _buildButton('%'),
                  _buildButton('/')
                ]),
                Row(children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('*')
                ]),
                Row(children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('-')
                ]),
                Row(children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('+')
                ]),
                Row(children: [
                  _buildButton('00'),
                  _buildButton('0'),
                  _buildButton('.'),
                  _buildButton('=')
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
