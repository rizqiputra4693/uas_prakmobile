import 'package:flutter/material.dart';
import 'favorite_manager.dart'; // Mengelola daftar favorit
import 'newsdetailpage.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteManager.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('No favorite items yet'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final news = favorites[index];
                return ListTile(
                  title: Text(news.title),
                  subtitle: Text("By ${news.author}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () {
                      setState(() {
                        FavoriteManager.removeFromFavorites(news);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${news.title} removed from favorites")),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(news: news),
                      ),
                    ).then((_) {
                      // Perbarui tampilan jika item dihapus dari favorit
                      setState(() {});
                    });
                  },
                );
              },
            ),
    );
  }
}
