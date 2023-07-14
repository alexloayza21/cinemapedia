
import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?>{
  SearchMovieDelegate({
    required this.searchMovies, 
    required this.initialMovies
  }):super(
    searchFieldLabel: 'Buscar películas', // este super sirve para no tener que hacer el override
    // textInputAction: TextInputAction.done
  );

  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;


  //*-------------------------------------------------------------------------------
  //* broadcast es para multiples listeners para diferentes widgets, en el caso de tener solo un widget escuchando no es necesario
  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast(); 
  StreamController<bool> isLoadingStream = StreamController.broadcast(); 
  Timer? _debounceTimer;
  //* El punto del debouncer, es tener nuestra funcion que tiene un timer que se limpia cada que se escribe, osea,
  //* se cancela cada vez que se escribe algo y cuando deja de escribir por, en este caso, 500 milseconds ejecuta el callback */
  void _onQueryChange(String query){
    
    isLoadingStream.add(true);
    if(_debounceTimer?.isActive ?? false ) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if(query.isEmpty){
      //   debouncedMovies.add([]);
      //   return;
      // }

      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);
      isLoadingStream.add(false);

    });

  }

  void clearStreams(){
    debouncedMovies.close();
  }

  Widget buildResultsAndSuggestions(){

    //*----------------- STREAM ----------------- 
    return StreamBuilder(
      stream: debouncedMovies.stream,
      initialData: initialMovies,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index], 
            onMovieSelected: (context, movie){
              clearStreams();
              close(context, movie);
            },
          )
        );
    },);
  }

  //*-------------------------------------------------------------------------------



  // @override
  // String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        stream: isLoadingStream.stream,
        initialData: false,
        builder: (context, snapshot) {
          if(snapshot.data ?? false){
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child:IconButton(
                onPressed: () => query = '', 
                icon: const Icon(Icons.refresh)
              )
            );
          }
          return FadeIn(
            animate:query.isNotEmpty, // valor booleano que sirve para hacer la animacion de entrada y salida
            duration: const Duration(milliseconds: 200),
            child:IconButton(
              onPressed: () => query = '', 
              icon: const Icon(Icons.clear)
            )
          );
      },)      
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){

        clearStreams();
        close(context, null);

      }, 
      icon: const Icon(Icons.arrow_back_ios_new_outlined)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChange(query);
    return buildResultsAndSuggestions();
  }
  
}



class _MovieItem extends StatelessWidget {
  const _MovieItem({
    required this.movie, required this.onMovieSelected,
  });

  final Movie movie;
  final Function onMovieSelected;

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
      
            //* Imagen
            SizedBox(
              width: size.width *0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox(width: 10,),
      
            //* Descripcion
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
    
                  Text(movie.title, style: textStyles.titleMedium,),
    
                  movie.overview.length > 100
                   ? Text('${movie.overview.substring(0,100)}...')
                   : Text(movie.overview),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800,),
                      const SizedBox(width: 5,),
                      Text(HumanFormats.number(movie.voteAverage, 1), style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),)
                    ],
                  )
    
                ],
              ),
            )
      
          ],
        ),
      ),
    );
  }
}

