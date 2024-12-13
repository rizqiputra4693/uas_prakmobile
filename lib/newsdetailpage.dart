import 'package:flutter/material.dart';
import 'model.dart';
import 'favorite_manager.dart';
import 'profile_screen.dart';

class NewsDetailPage extends StatefulWidget {
  final News news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool isFavorite = false;
  bool isLoggedIn = false; // Simulasi status login pengguna

  @override
  void initState() {
    super.initState();
    // Cek apakah berita sudah ada di daftar favorit
    isFavorite = FavoriteManager.isFavorite(widget.news);
  }

  void toggleFavorite() {
    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      if (isFavorite) {
        FavoriteManager.removeFromFavorites(widget.news);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.news.title} removed from favorites")),
        );
      } else {
        FavoriteManager.addToFavorites(widget.news);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.news.title} added to favorites")),
        );
      }
      isFavorite = !isFavorite;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("You need to login to add this news to favorites."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((value) {
                if (value == true) {
                  setState(() {
                    isLoggedIn = true; // Update status login
                  });
                }
              });
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.news.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              widget.news.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "By ${widget.news.author}, ${widget.news.publishedDate}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              widget.news.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Category: ${widget.news.kategori}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleFavorite,
        backgroundColor: isFavorite ? Colors.red : Colors.grey,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }
}