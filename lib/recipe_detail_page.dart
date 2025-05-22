import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['strMeal'] ?? 'Detail Resep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(recipe['strMealThumb']),
            ),
            const SizedBox(height: 16),

            // Kategori & Area
            Text(
              '${recipe['strCategory']} • ${recipe['strArea']}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Bahan-bahan
            const Text(
              'Bahan-bahan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildIngredients(),

            const SizedBox(height: 16),

            // Instruksi
            const Text(
              'Cara Memasak:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe['strInstructions'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredients() {
    List<Widget> list = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = recipe['strIngredient$i'];
      final measure = recipe['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().isNotEmpty &&
          ingredient.toString() != '') {
        list.add(Text('- $ingredient: $measure'));
      }
    }
    return list;
  }
}
