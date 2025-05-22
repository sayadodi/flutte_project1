import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_detail_page.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List recipes = [];
  bool isLoading = false;
  String selectedCategory = 'Seafood';
  final List<String> categories = ['Seafood', 'Dessert', 'Beef', 'Chicken'];

  @override
  void initState() {
    super.initState();
    fetchRecipesByCategory();
  }

  Future<void> fetchRecipesByCategory() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$selectedCategory';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        recipes = data['meals'].take(10).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data resep')),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchRecipeDetail(String id) async {
    final detailUrl =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id';
    final response = await http.get(Uri.parse(detailUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['meals'][0];
    }
    return null;
  }

  // Menyimpan resep ke favorit
  Future<void> saveToFavorites(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRecipes = prefs.getStringList('favoriteRecipes') ?? [];
    favoriteRecipes.add(jsonEncode(recipe));
    await prefs.setStringList('favoriteRecipes', favoriteRecipes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resep disimpan ke favorit!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Makanan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                  fetchRecipesByCategory();
                }
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          recipe['strMealThumb'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              recipe['strMeal'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            TextButton(
                              onPressed: () async {
                                final detail =
                                    await fetchRecipeDetail(recipe['idMeal']);
                                if (detail != null && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailPage(recipe: detail),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(height: 5),
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                                saveToFavorites(recipe);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
