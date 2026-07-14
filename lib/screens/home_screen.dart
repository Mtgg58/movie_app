import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List popularMovies = [];
  List recommendedMovies = [];
  List searchResults = [];
  
  bool isLoading = true;
  bool isSearching = false;
  int _currentIndex = 0;

  // llave de TMDB
  final String apiKey = 'd2d26e93b35154babd880e075747e2e7'; 
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.70); 
    fetchInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    try {
      final popularRes = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=es-ES'));
      final recommendedRes = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey&language=es-ES'));

      if (popularRes.statusCode == 200 && recommendedRes.statusCode == 200) {
        setState(() {
          popularMovies = json.decode(popularRes.body)['results'];
          recommendedMovies = json.decode(recommendedRes.body)['results'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() => isSearching = false);
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&language=es-ES&query=$query'));
      if (response.statusCode == 200) {
        setState(() {
          searchResults = json.decode(response.body)['results'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String getSafeRating(dynamic vote) {
    if (vote == null) return '0.0';
    if (vote is int) return vote.toDouble().toStringAsFixed(1);
    if (vote is double) return vote.toStringAsFixed(1);
    return '0.0';
  }

  @override
  Widget build(BuildContext context) {
    // extraemos la imagen de fondo de la pelicula seleccionada actualmente
    String bgUrl = '';
    if (popularMovies.isNotEmpty && _currentIndex < popularMovies.length) {
      final bgPath = popularMovies[_currentIndex]['poster_path'];
      if (bgPath != null) {
        bgUrl = 'https://image.tmdb.org/t/p/w500$bgPath';
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (bgUrl.isNotEmpty && !isSearching)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.network(
                  bgUrl,
                  key: ValueKey<String>(bgUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.95),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Explorar catálogo...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF2EFEEA)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) setState(() => isSearching = false);
                          },
                          onSubmitted: (value) => searchMovies(value),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Botón de Perfil circular
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, 'info'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF2EFEEA)),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2EFEEA)))
                      : isSearching
                          ? _buildSearchResults()
                          : _buildCinematicLayout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(child: Text('No se encontraron películas.', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
        final String? poster = movie['poster_path'];
        final String imgUrl = poster != null 
            ? 'https://image.tmdb.org/t/p/w200$poster' 
            : 'https://via.placeholder.com/200x300?text=No+Image';

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C).withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imgUrl, width: 70, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie['title'] ?? '', 
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFF2EFEEA), size: 14),
                          const SizedBox(width: 4),
                          Text(getSafeRating(movie['vote_average']), style: const TextStyle(color: Color(0xFF2EFEEA), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_outline, color: Color(0xFF2EFEEA), size: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCinematicLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Text('En Tendencia', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: popularMovies.length,
              itemBuilder: (context, index) {
                final movie = popularMovies[index];
                final String? poster = movie['poster_path'];
                final String imgUrl = poster != null 
                    ? 'https://image.tmdb.org/t/p/w500$poster' 
                    : 'https://via.placeholder.com/500x300?text=No+Image';

                final bool isActive = _currentIndex == index;

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutQuint,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: isActive ? 0 : 35, 
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isActive 
                          ? [BoxShadow(color: const Color(0xFF2EFEEA).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))] 
                          : [],
                      image: DecorationImage(
                        image: NetworkImage(imgUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Degradado interno para el texto
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(20),
                      child: isActive ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['title'] ?? 'Sin título', 
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFF2EFEEA), size: 16),
                              const SizedBox(width: 5),
                              Text(getSafeRating(movie['vote_average']), style: const TextStyle(color: Color(0xFF2EFEEA), fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          )
                        ],
                      ) : null, 
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 35),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Selección Especial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 15),

          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recommendedMovies.length > 5 ? 5 : recommendedMovies.length, // mostramos solo un top 5 para no hacerla tan larga
            itemBuilder: (context, index) {
              final movie = recommendedMovies[index];
              final String? backdrop = movie['backdrop_path'];
              final String imgUrl = backdrop != null 
                  ? 'https://image.tmdb.org/t/p/w500$backdrop' 
                  : 'https://via.placeholder.com/500x300?text=No+Image';

              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            movie['title'] ?? '', 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Color(0xFF2EFEEA), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}