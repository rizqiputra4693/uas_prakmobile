import 'package:flutter_uas/model.dart';

class FavoriteManager {
  static final List<News> favorites = [];

  static void addToFavorites(News news) {
    if (!favorites.contains(news)) {
      favorites.add(news);
    }
  }

  static void removeFromFavorites(News news) {
    favorites.remove(news);
  }

  static bool isFavorite(News news) {
    return favorites.contains(news);
  }
}