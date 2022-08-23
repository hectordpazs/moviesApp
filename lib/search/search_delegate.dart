import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class MovieSeachDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => 'Buscar Pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    
    moviesProvider.getSuggestionsByQuery(query);

    //para tener mas control sobre las acciones es mejor usar un streamBuilder
    //antes estaba un future builder...
    
    return StreamBuilder(
      stream: moviesProvider.suggestionStream,
      builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {

        if (!snapshot.hasData) return _emptyContainer();

        final List<Movie> encounteredMovies = snapshot.data!;

        return ItemsRendered(encounteredMovies: encounteredMovies);
      },
    );
  }
}

class ItemsRendered extends StatelessWidget {
  const ItemsRendered({
    Key? key,
    required this.encounteredMovies,
  }) : super(key: key);

  final List<Movie> encounteredMovies;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: encounteredMovies.length,
        itemBuilder: (BuildContext context, int i) {
          final heroId = encounteredMovies[i].heroId = 'search-${encounteredMovies[i].id}';
          return ListTile(
            leading: Hero(
              tag: heroId,
              child: FadeInImage(
                width: 50,
                fit: BoxFit.contain,
                image: NetworkImage(encounteredMovies[i].fullPosterImg),
                placeholder: const AssetImage('assets/no-image.jpg'),
              ),
            ),
            title: Text(encounteredMovies[i].title),
            subtitle: Text(encounteredMovies[i].originalTitle),
            onTap: () {
              Navigator.pushNamed(context, 'details',
                  arguments: encounteredMovies[i]);
            },
          );
        },
      ),
    );
  }
}

Widget _emptyContainer() {
  return Container(
      child: Center(
          child: Icon(
    Icons.movie_creation_outlined,
    color: Colors.black38,
    size: 130,
  )));
}
