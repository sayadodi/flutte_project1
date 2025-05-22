import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsApiService {
  static const String _apiKey = '0f8de34323ca47a68ebbbfbde174c7db';
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';

  Future<List<NewsArticle>> fetchIndonesianNews() async {
    final uri = Uri.parse(
        '$_baseUrl?country=us&apiKey=$_apiKey'); 
    final response = await http.get(uri);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'ok' && data['totalResults'] > 0) {
        final List<dynamic> articlesJson = data['articles'];
        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        return []; // Tidak ada berita
      }
    } else {
      throw Exception('Gagal memuat berita: ${response.statusCode}');
    }
  }
}
