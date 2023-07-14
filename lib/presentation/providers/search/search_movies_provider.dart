import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider((ref) => '');

final searchedMoviesProvider = StateNotifierProvider<SearchedMoviesNotifier,List<Movie>>((ref) {

  final movieRepository = ref.read(movieRepositoryProvider);

  return SearchedMoviesNotifier(
    ref: ref, 
    searchMovies: movieRepository.searchMovies
  );

}); 

typedef SearchMoviesCallBack = Future<List<Movie>> Function(String query);

class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {
  SearchedMoviesNotifier({required this.ref, required this.searchMovies}):super([]);
  final SearchMoviesCallBack searchMovies;
  final Ref ref;

  Future<List<Movie>> searchMoviesByQuery (String query) async{

    final List<Movie> movies = await searchMovies(query);
    ref.read(searchQueryProvider.notifier).update((state) => query);

    state = movies; 
    //* no uso el spread ([...movies]) xq esto es un nuevo objeto, 
    //* y no queremos mantener las peliculas anteriores, simplemente mantenemos el ultimo resultado de busqueda*/

    return movies;
    
  }
  
}