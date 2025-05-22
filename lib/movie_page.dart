import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  List movies = [];
  final String apiKey = '2e7a38acf87175c21f90bfad4a3559cd';
  String category = 'popular';

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final url =
        'https://api.themoviedb.org/3/movie/$category?api_key=$apiKey&language=en-US&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movies = data['results'];
      });
    } else {
      print('Gagal mengambil data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Menarik Hari Ini'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      category = 'popular';
                    });
                    fetchMovies();
                  },
                  child: const Text('Populer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      category = 'upcoming';
                    });
                    fetchMovies();
                  },
                  child: const Text('Akan Datang'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      category = 'top_rated';
                    });
                    fetchMovies();
                  },
                  child: const Text('Rating Tertinggi'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: movies.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final imageUrl =
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}';
                  final rating = movie['vote_average'] ?? 0.0;

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                movie['title'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  if (index < (rating / 2).round()) {
                                    return const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 18,
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.star_border,
                                      color: Colors.grey,
                                      size: 18,
                                    );
                                  }
                                }),
                              ),
                              const SizedBox(height: 5),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                        movieId: movie['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Detail',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Map<String, dynamic> movieDetail = {};
  bool isLoading = true;
  final String apiKey = '2e7a38acf87175c21f90bfad4a3559cd';

  @override
  void initState() {
    super.initState();
    fetchMovieDetail();
  }

  Future<void> fetchMovieDetail() async {
    final url =
        'https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movieDetail = data;
        isLoading = false;
      });
    } else {
      print('Gagal mengambil detail film');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Film'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500${movieDetail['poster_path']}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movieDetail['title'] ?? 'No title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movieDetail['overview'] ?? 'No overview available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow),
                      Text(
                        movieDetail['vote_average'].toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      Text(
                        'Release Date: ${movieDetail['release_date']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      Text(
                        'Duration: ${movieDetail['runtime']} minutes',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.grey),
                      Text(
                        'Language: ${movieDetail['original_language'].toUpperCase()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
