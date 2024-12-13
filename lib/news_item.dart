import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String imageUrl;
  final VoidCallback onTap; // Tambahkan callback onTap

  const NewsItem({
    Key? key,
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Panggil callback saat diklik
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Image.network(imageUrl, height: 80, width: 80, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "By $author, $date",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
