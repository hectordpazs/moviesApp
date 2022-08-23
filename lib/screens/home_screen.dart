import 'package:flutter/material.dart';
import 'package:peliculas_app/providers/providers.dart';
import 'package:peliculas_app/search/search_delegate.dart';
import 'package:peliculas_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, /*listen: true o false*/);
    //el listen se pone en false dentro de un metodo, como por el ejemplo el onPressed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas en cines'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context, 
                delegate: MovieSeachDelegate(),
              );
            },
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // cardSwiper Tarjetas principales,
            CardSwiper( movies: moviesProvider.onDisplayMovies ),
            //listado horizontal de peliculas slider
            MovieSlider(popularMovies: moviesProvider.popularMovies, 
              titleSlider: 'Populares', onNextPage: moviesProvider.getOnPopularMovies,
            ),
          ],
        ),
      ),
    );
  }
}
