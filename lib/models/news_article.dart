class NewsArticle {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final DateTime publishedAt;
  final String? sourceName;
  final String? author; 

  NewsArticle({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    required this.publishedAt,
    this.sourceName,
    this.author, 
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Tidak Ada Judul',
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      sourceName: json['source']?['name'],
      author: json['author'], // 
    );
  }
}
