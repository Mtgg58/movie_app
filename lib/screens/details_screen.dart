import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map? movieDetails;
  List cast = [];
  bool _isLoading = true;
  bool _isInit = true;

  final String apiKey = 'd2d26e93b35154babd880e075747e2e7'; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final dynamic arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map) {
        final movieId = arguments['id'];
        if (movieId != null) {
          fetchFullData(movieId);
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
      _isInit = false;
    }
  }

  Future<void> fetchFullData(dynamic movieId) async {
    final movieUrl = Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=es-ES');
    final creditsUrl = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey&language=es-ES');

    try {
      final movieResponse = await http.get(movieUrl);
      final creditsResponse = await http.get(creditsUrl);

      if (movieResponse.statusCode == 200 && creditsResponse.statusCode == 200) {
        setState(() {
          movieDetails = json.decode(movieResponse.body);
          cast = json.decode(creditsResponse.body)['cast'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchTrailer(String movieTitle) async {
    final String query = Uri.encodeComponent('trailer espanol $movieTitle');
    final Uri url = Uri.parse('https://www.youtube.com/results?search_query=$query');
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error intentando lanzar URL: $e');
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2EFEEA))),
      );
    }

    if (movieDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudieron obtener los detalles.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final String? backdropPath = movieDetails!['backdrop_path'] ?? movieDetails!['poster_path'];
    final String imageUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w500$backdropPath'
        : 'https://via.placeholder.com/500x300?text=No+Image';
    final String title = movieDetails!['title'] ?? 'Película sin título';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2EFEEA)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(imageUrl, width: double.infinity, height: 350, fit: BoxFit.cover),
                Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF121212), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2EFEEA).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFF2EFEEA), size: 18),
                            const SizedBox(width: 5),
                            Text(
                              '${getSafeRating(movieDetails!['vote_average'])} Puntos',
                              style: const TextStyle(color: Color(0xFF2EFEEA), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        movieDetails!['release_date'] ?? 'Sin fecha',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2EFEEA),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.play_circle_fill, color: Colors.black, size: 28),
                      label: const Text('VER TRÁILER EN YOUTUBE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () => _launchTrailer(title),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  const Text('Sinopsis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    movieDetails!['overview'] == null || movieDetails!['overview'] == '' 
                        ? 'Sin sinopsis disponible.' 
                        : movieDetails!['overview'],
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                  
                  const SizedBox(height: 30),
                  const Text('Casting Principal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 15),
                  
                  SizedBox(
                    height: 150,
                    child: cast.isEmpty
                        ? const Text('Información de elenco no disponible.', style: TextStyle(color: Colors.grey))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cast.length > 10 ? 10 : cast.length,
                            itemBuilder: (context, index) {
                              final actor = cast[index];
                              final String? profilePath = actor['profile_path'];
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 15),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: const Color(0xFF1C1C1C),
                                      backgroundImage: profilePath != null 
                                          ? NetworkImage('https://image.tmdb.org/t/p/w200$profilePath') 
                                          : null,
                                      child: profilePath == null ? const Icon(Icons.person, color: Colors.grey) : null,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      actor['name'] ?? 'Actor',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}