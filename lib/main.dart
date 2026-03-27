import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:boudjema_dyhia_movie_explorer/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); //Flutter prend du temps à lire les fichiers, donc on utilise await pour s'assurer que les variables sont chargées avant de lancer l'app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoriteProvider(),
      child: MaterialApp(
        title: 'Movie Explorer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: "Movie Explorer"),
        // routes: {
        //   "/": (context) => const MyHomePage(title: "Movie Explorer"),
        //   "/favorites": (context) => const FavoriteMoviesScreen(),
        // },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> movies = [];
  final String apiKey = dotenv.get('API_KEY');
  bool isloading = false;
  String? errormsg;
  int currentIndex = 0;

  void _onItemtapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchmovies();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteCount = context.watch<FavoriteProvider>().favorites.length;
    return Scaffold(
      backgroundColor: Color.fromARGB(31, 219, 213, 213),
      appBar: AppBar(
        title: Center(
          child: Text(widget.title, style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: currentIndex == 0
            ? _buildHomeBody()
            : const FavoriteMoviesScreen(),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: _fetchmovies,
              child: Icon(Icons.refresh),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: currentIndex,
        onTap: _onItemtapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.favorite),
                if (favoriteCount > 0 && currentIndex != 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$favoriteCount',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Favorites",
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    if (isloading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errormsg != null) {
      return Center(
        child: Text(
          errormsg!,
          style: const TextStyle(color: Colors.red, fontSize: 24),
        ),
      );
    }

    return Center(
      child: SizedBox(
        height: 440,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MovieCard(movie: movies[index]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchmovies() async {
    setState(() {
      isloading = true;
      errormsg = null;
    });
    final url = Uri.parse(
      "https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1",
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'Mozilla/5.0 ', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List results = data['results'] as List;
      if (results.isEmpty) {
        setState(() {
          isloading = false;
          errormsg = "No movies found";
        });
        return;
      }
      setState(() {
        movies = results.map((json) => Movie.fromJson(json)).toList();
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
        errormsg = "Failed to fetch movies";
      });
    }
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favoritesProvider.isFavorite(movie);
    return Container(
      width: 220,
      margin: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 196, 164, 164),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  favoritesProvider.toggleFavorite(movie);
                },
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              height: 140,
              width: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              movie.originalTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 6),
            Text(
              "Original Language: ${movie.originalLanguage}",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            Text(
              movie.overview,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteProvider extends ChangeNotifier {
  List<Movie> favoritesList = [];

  List<Movie> get favorites => favoritesList;

  bool isFavorite(Movie movie) {
    return favoritesList.any((item) => item.id == movie.id);
  }

  void toggleFavorite(Movie movie) {
    if (isFavorite(movie)) {
      favoritesList.removeWhere((item) => item.id == movie.id);
    } else {
      favoritesList.add(movie);
    }
    notifyListeners();
  }

  void removeFavorite(Movie movie) {
    favoritesList.removeWhere((item) => item.id == movie.id);
    notifyListeners();
  }
}

class FavoriteMoviesScreen extends StatelessWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteProvider>(context);
    final favoriteMovies = favoritesProvider.favorites;

    return favoriteMovies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No favorite movies yet",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushReplacementNamed(context, "/");
                //   },
                //   child: Text("Go Back"),
                // ),
              ],
            ),
          )
        : ListView.separated(
            itemCount: favoriteMovies.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 196, 164, 164),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 100,
                      width: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.originalTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Original Language: ${movie.originalLanguage}",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          SizedBox(height: 6),
                          Text(
                            movie.overview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        favoritesProvider.removeFavorite(movie);
                      },
                      icon: Icon(Icons.delete, color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
