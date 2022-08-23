import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/helpers/debouncer.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = 'afbba86e608ce474cd9283481806a32a';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  int _popularPage = 0;

  Map<int, List<Cast>> moviesCast = {};

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500),);

  final StreamController<List<Movie>> _suggestionsStremController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionsStremController.stream;

  //constructor

  MoviesProvider() {
    getOnDisplayMovies();
    getOnPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  Future getOnDisplayMovies() async {
    final response = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(response);
    onDisplayMovies = nowPlayingResponse.results;
    //para redibujar widgets:
    notifyListeners();
  }

  Future getOnPopularMovies() async {
    _popularPage++;
    final response = await _getJsonData('3/movie/now_playing', _popularPage);
    final popularMoviesResponse = PopularMoviesResponse.fromJson(response);
    popularMovies = [...popularMovies, ...popularMoviesResponse.results];
    //para redibujar widgets:
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    //revisar el mapa

    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final response = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(response);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm){
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionsStremController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) { 
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301)).then((value) => timer.cancel());
  }
}




  /*getOnDisplayMovies() async {
    // final url = Uri.https(_baseUrl, '3/movie/now_playing',
    // {'api_key': _apiKey, 'language': _language, 'page': '1'});
    final url = Uri.https(_baseUrl, '3/movie/now_playing', {
      'api_key': _apiKey,
      'language': _language,
      'page': '1',
    });

    final response = await http.get(url);
    //convertir en mapa:
    //final Map<String, dynamic> decodedData = json.decode(response.body);
    //if (response.statusCode != 200) return print('error');
    //los modelos son clases que sirven para mapear otras cosas!!!!!
    //print(decodedData);

    final nowPlayingResponse = NowPlayingResponse.fromJson(response.body);

    onDisplayMovies = nowPlayingResponse.results;
    //para redibujar widgets:

    notifyListeners();
  }*/

