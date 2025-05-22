import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart';
import 'movie_page.dart';
import 'recipe_page.dart';
import 'favoritepage.dart';
import 'stock_page.dart';
import 'kalkulator.dart';
import 'kutipan_page.dart';
import 'login_page.dart';
import 'berita/home_page.dart';
import 'pages/prediction_page.dart';
// import 'diabet_predict.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  Future<String?> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');
    String? storedPassword = prefs.getString('password');
    return storedEmail != null && storedPassword != null;
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  Future<void> _showLoginAlert(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Agar pengguna harus menutup dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Perhatian"),
          content: const Text(
              "Anda harus login terlebih dahulu untuk mengakses AI Konsultasi Mental."),
          actions: <Widget>[
            TextButton(
              child: const Text("Login"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus data login
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Menghapus email
    await prefs.remove('password'); // Menghapus password

    // Setelah logout, lakukan pembaruan pada state aplikasi tanpa mengganti halaman
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Info Harian')),
      body: FutureBuilder<String?>(
        future: _getUserEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userEmail = snapshot.data;
          final isLoggedIn = userEmail != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text('Logged in as: $userEmail'),
                ),
              ListTile(
                leading: const Icon(Icons.movie),
                title: const Text('Film Menarik'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoviePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Resep Makanan'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecipePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Resep Favorit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Pergerakan Saham'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StockPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Kalkulator'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KalkulatorPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.request_quote),
                title: const Text('Kata Kata Hari ini'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuotePage()),
                  );
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.request_quote),
              //   title: const Text('Prediksi Diabetes'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const PredictionPage()),
              //     );
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.movie),
                title: const Text('Berita Hari Ini'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.movie),
                title: const Text('Prediksi Diabetes'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PredictionPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat AI Konsultasi Mental'),
                onTap: () async {
                  if (isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  } else {
                    // Tampilkan dialog peringatan login
                    _showLoginAlert(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              if (isLoggedIn) // Menampilkan tombol logout jika sudah login
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => _logout(context), // Menambahkan fungsi logout
                ),
            ],
          );
        },
      ),
    );
  }
}
