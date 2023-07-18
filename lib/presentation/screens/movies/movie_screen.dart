import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie_screen';

  const MovieScreen({super.key, required this.movieId});

  final String movieId;

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() { // cuando estamos dentro de initstate, metodos, callback de on tap, etc usamos el read
    super.initState();

    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);    
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);    

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if(movie == null){
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2,),));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [

          _CustomSliverAppBar(movie: movie),

          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))

        ],
      )
   );
  }
}

class _MovieDetails extends StatelessWidget {
  const _MovieDetails({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //*------------- Imagen + Título + Descripción -------------
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              //*---------- IMAGEN ----------
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),
              const SizedBox(width: 10,),

              //*---------- TITULO Y DESCRIPCIÓN ----------
              SizedBox(
                width: (size.width-40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(movie.title, style: textStyle.titleLarge),
                    Text(movie.overview),

                  ],
                ),
              )

            ],
          ),
        ),

        //*------------ GENEROS ------------
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: Chip(
                  label: Text(gender),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ))
            ],
          ),
        ),
        
        //*------------ ACTORES ------------        
        _ActorsByMovie(movieId: movie.id.toString(),),

        const SizedBox(height: 50)

      ],
    );

  }
}

class _ActorsByMovie extends ConsumerWidget {
  const _ActorsByMovie({
    required this.movieId,
  });

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final actorsByMovie = ref.watch(actorsByMovieProvider);

    if(actorsByMovie[movieId] == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 125,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //* Actor Photo

                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                //* Actor Name
                const SizedBox(height: 5),

                Text(actor.name, maxLines: 2,),
                Text(
                  actor.character ?? '', 
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}


//*-----------------------PROVIDER----------------------------
final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {

  final localStorageRespository = ref.watch(localStorageRepositoryProvider);
  return localStorageRespository.isMovieFavorite(movieId); //ç* si está en favoritos
});

class _CustomSliverAppBar extends ConsumerWidget {
  const _CustomSliverAppBar({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final size = MediaQuery.of(context).size;
    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async{
            // ref.read(localStorageRepositoryProvider).toggleFavorite(movie);
            await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(movie);
            
            ref.invalidate(isFavoriteProvider(movie.id)); //*antes no cambiaba a la primera y habia que darle varias veces, la solucion era el async y await
            //* esto invalida el estado del provider y lo regresa al valor inicial, osea que al darle y cambie el estado automaticamente se redibujará
          }, 
          icon: isFavoriteFuture.when(
            loading: () => const CircularProgressIndicator(strokeWidth: 2),
            data: (isFavorite) => isFavorite 
              ? const Icon( Icons.favorite_rounded, color: Colors.red )
              : const Icon( Icons.favorite_border ), 
            error: (error, stackTrace) => throw UnimplementedError(), 
          )
            
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [

            //* IMAGEN APPBAR
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            const _CustomGradiant(
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, 
              stops: [0.8 , 1.0], //* el gradiente toma desde el 80% de la pantalla hasta el final
              colors: [
                Colors.transparent, 
                Colors.black87,
              ] //* en este caso el 80% de la pantalla es transparente y el resto es negro
            ),

            const _CustomGradiant(
              begin: Alignment.topLeft, 
              end: Alignment.center, 
              stops: [0 , 0.3], 
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),

            const _CustomGradiant(
              begin: Alignment.topRight, 
              end: Alignment.center, 
              stops: [0 , 0.3], 
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),

          ],
        ),
      ),
    );
  }
}

class _CustomGradiant extends StatelessWidget {
  const _CustomGradiant({
    required this.begin, required this.end, required this.stops, required this.colors,
  });

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops, // el gradiente empieza desde el 70% hasta llegar abajo 
            colors: colors
          )
        )
      ),
    );
  }
}

