// // lib/pages/prediction_page.dart
// import 'package:flutter/material.dart';
// import 'model_loader.dart';
// import 'constants.dart';

// class PredictionPage extends StatefulWidget {
//   const PredictionPage({Key? key}) : super(key: key);

//   @override
//   State<PredictionPage> createState() => _PredictionPageState();
// }

// class _PredictionPageState extends State<PredictionPage> {
//   final DiabetesModel _model = DiabetesModel();

//   final TextEditingController _bmiController = TextEditingController();
//   int _selectedAgeCode = 0;
//   int _selectedGenHlthCode = 0;

//   String _result = '';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _model.loadModel(); // Muat model saat halaman dibuka
//   }

//   void _runPrediction() async {
//     setState(() {
//       _isLoading = true;
//       _result = '';
//     });

//     double bmi = double.tryParse(_bmiController.text) ?? 25.0;

//     List<double> input = _model.preprocess(
//       bmi: bmi,
//       ageCode: _selectedAgeCode,
//       genHlthCode: _selectedGenHlthCode,
//     );

//     double probability = _model.predict(input);
//     String prediction = (probability > 0.5) ? 'Diabetic' : 'Non-Diabetic';

//     setState(() {
//       _result =
//           "Prediksi: $prediction\nProbabilitas: ${probability.toStringAsFixed(4)}";
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Prediksi Diabetes")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _bmiController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: "BMI"),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<int>(
//               value: _selectedAgeCode,
//               items: ageOrder.asMap().entries.map((e) {
//                 return DropdownMenuItem<int>(
//                   value: e.key,
//                   child: Text(e.value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedAgeCode = value;
//                   });
//                 }
//               },
//               decoration: InputDecoration(labelText: "Usia"),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<int>(
//               value: _selectedGenHlthCode,
//               items: genHlthOrder.asMap().entries.map((e) {
//                 return DropdownMenuItem<int>(
//                   value: e.key,
//                   child: Text(e.value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedGenHlthCode = value;
//                   });
//                 }
//               },
//               decoration: InputDecoration(labelText: "Status Kesehatan Umum"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _runPrediction,
//               child: _isLoading
//                   ? SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(color: Colors.white),
//                     )
//                   : Text("Prediksi"),
//             ),
//             SizedBox(height: 20),
//             if (_result.isNotEmpty)
//               Text(
//                 _result,
//                 style: TextStyle(fontSize: 18),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
