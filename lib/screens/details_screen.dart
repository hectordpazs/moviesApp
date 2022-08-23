import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/widgets/widgets.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //cambiar luego por una instancia de movie
    final Movie movie = ModalRoute.of(context)?.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        //parecido al SingleChildScrollView pero con slivers
        physics: const BouncingScrollPhysics(),
        slivers: [
          //son widgets que tienen comportamiento programado cuando se hace scroll
          _CustomAppBar(
            title: movie.title,
            image: movie.fullBackdropImg
          ),

          SliverList(
              //para poder meter widgets que no son especiales
              delegate: SliverChildListDelegate([
            //aqui van los widgets no especiales
            _PosterAndTitle(
              image: movie.fullPosterImg,
              title: movie.title,
              originalTitle: movie.originalTitle,
              voteAverage: movie.voteAverage,
              id: movie.heroId!
            ),

            Overview(overview: movie.overview),

            CastingCards(movieId: movie.id),
          ]))
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String title;
  final String image;

  const _CustomAppBar({Key? key, required this.title, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.indigo, //va a poder desaparecer el appbar
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        //es otro widget para que se acomode al tamaño al scroll
        centerTitle: true,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 10),
          width: double.infinity,
          color: Colors.black12,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        background: FadeInImage(
          placeholder: const AssetImage('assets/loading.gif'),
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PosterAndTitle extends StatelessWidget {
  final String title, image, originalTitle;
  final double voteAverage;
  final String id;

  const _PosterAndTitle(
      {Key? key,
      required this.title,
      required this.image,
      required this.originalTitle,
      required this.voteAverage, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Hero(
          tag: id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/no-image.jpg'),
              image: NetworkImage(image),
              height: 150,
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width-190 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headline5,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                originalTitle,
                style: textTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_outline,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '$voteAverage',
                    style: textTheme.caption,
                  )
                ],
              )
            ],
          ),
        )
      ]),
    );
  }
}

class Overview extends StatelessWidget {
  final String overview;
  const Overview({Key? key, required this.overview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
          overview,
          textAlign: TextAlign.justify,
          style: Theme.of(context).textTheme.subtitle1
      ),
    );
  }
}
