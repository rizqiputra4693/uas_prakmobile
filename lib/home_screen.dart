import 'package:flutter/material.dart';
import 'package:flutter_uas/about.dart';
import 'package:flutter_uas/newsdetailpage.dart';
import 'koneksi.dart';
import 'model.dart';
import 'category_button.dart';
import 'news_item.dart';
import 'favorite_screen.dart'; // Impor FavoriteScreen
import 'profile_screen.dart'; // Impor ProfileScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Menyimpan index tab yang dipilih

  // Daftar halaman untuk ditampilkan
  final List<Widget> _pages = [
    HomeContent(), // Halaman Home
    const FavoriteScreen(), // Halaman Favorite
    const ProfileScreen(), // Halaman Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Perbarui index yang dipilih
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _selectedIndex == 0 // Tampilkan menu hanya di halaman Home
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            : null, // Jika bukan halaman Home, tidak ada icon menu
      ),
      drawer: _selectedIndex == 0 // Hanya tampilkan Drawer di halaman Home
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 243, 33, 65),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/stylesnap.png', // Path file logo Anda
                            height: 180, // Sesuaikan tinggi logo
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'StyleSnap',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                      // Tambahkan logika ke halaman About
                    },
                  ),
                ],
              ),
            )
          : null, // Jika bukan halaman Home, tidak ada Drawer
      body: _pages[_selectedIndex], // Tampilkan halaman yang sesuai
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Tampilkan index yang dipilih
        onTap: _onItemTapped, // Panggil fungsi saat tombol ditekan
      ),
    );
  }
}

// Konten Halaman Home
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<News>?> _newsFuture;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _newsFuture =
        ApiService().getNews(); // Panggil API untuk mendapatkan berita
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildLatestNewsSection(),
        _buildCategoryButtons(),
        _buildNewsList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          setState(() {
            _newsFuture = ApiService().getNews().then((newsList) {
              return newsList
                  ?.where((news) =>
                      news.title.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          });
        },
      ),
    );
  }

  Widget _buildLatestNewsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Latest News',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<News>?>(
          // Gunakan FutureBuilder untuk memuat berita terbaru
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                  child: Text("No news available. ${snapshot.error}"));
            } else {
              final latestNews = snapshot.data!.first; // Ambil berita pertama
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(news: latestNews),
                    ),
                  );
                },
                child: _buildLatestNewsCard(latestNews),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLatestNewsCard(News news) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: AssetImage(news.imageUrl), // Gunakan URL dari API
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'by ${news.author}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          CategoryButton(
            label: 'All',
            isActive: selectedCategory == null,
            onPressed: () {
              setState(() {
                selectedCategory = null;
              });
            },
          ),
          CategoryButton(
            label: 'Baju',
            isActive: selectedCategory == 'baju',
            onPressed: () {
              setState(() {
                selectedCategory = 'baju';
              });
            },
          ),
          CategoryButton(
            label: 'Celana',
            isActive: selectedCategory == 'celana',
            onPressed: () {
              setState(() {
                selectedCategory = 'celana';
              });
            },
          ),
          CategoryButton(
            label: 'Topi',
            isActive: selectedCategory == 'topi',
            onPressed: () {
              setState(() {
                selectedCategory = 'topi';
              });
            },
          ),
          CategoryButton(
            label: 'Sepatu',
            isActive: selectedCategory == 'sepatu',
            onPressed: () {
              setState(() {
                selectedCategory = 'sepatu';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return Expanded(
      child: FutureBuilder<List<News>?>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No news available."));
          } else {
            // Filter berita berdasarkan kategori yang dipilih
            final filteredNews = selectedCategory == null
                ? snapshot.data!
                : snapshot.data!
                    .where((news) => news.kategori == selectedCategory)
                    .toList();

            if (filteredNews.isEmpty) {
              return const Center(
                  child: Text("No news available for this category."));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredNews.length,
              itemBuilder: (context, index) {
                final news = filteredNews[index];
                return NewsItem(
                  title: news.title,
                  author: news.author,
                  date: news.publishedDate,
                  imageUrl: news.imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(news: news),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
