// // lib/model_loader.dart
// import 'package:tflite_flutter/tflite_flutter.dart';

// class DiabetesModel {
//   late Interpreter interpreter;

//   Future<void> loadModel() async {
//     interpreter = await Interpreter.fromAsset('assets/diabetes_model.tflite');
//   }

//   // Fungsi preprocessing input
//   List<double> preprocess({
//     required double bmi,
//     required int ageCode,
//     required int genHlthCode,
//   }) {
//     const double meanBMI = 28.37;
//     const double stdBMI = 6.59;
//     double normalizedBMI = (bmi - meanBMI) / stdBMI;

//     return [normalizedBMI, ageCode.toDouble(), genHlthCode.toDouble()];
//   }

//   // Fungsi prediksi
//   double predict(List<double> input) {
//     var inputTensor = [input]; // shape: [1, 3]
//     var outputTensor = [
//       [0.0]
//     ]; // shape: [1, 1]

//     interpreter.run(inputTensor, outputTensor);

//     return outputTensor[0][0];
//   }
// }
