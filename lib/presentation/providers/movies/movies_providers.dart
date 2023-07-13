
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) { // es un proveedor de informacion que notifica cuando cambia el estado

  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getNowPlaying;
  return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) { // es un proveedor de informacion que notifica cuando cambia el estado

  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getPopular;
  return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) { // es un proveedor de informacion que notifica cuando cambia el estado

  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getUpcoming;
  return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) { // es un proveedor de informacion que notifica cuando cambia el estado

  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getTopRated;
  return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
});




typedef MovieCallBack = Future<List<Movie>> Function({int page}); // objetivo: definir el caso de uso

class MoviesNotifier extends StateNotifier<List<Movie>>{
  
  int currentPage = 0;
  bool isLoading = false; // paara evitar que se llame a la peticion varias veces a la vez
  MovieCallBack fetchMoreMovies;
  
  MoviesNotifier({required this.fetchMoreMovies}):super([]);

  Future<void> loadNextPage()async{
    if(isLoading) return;

    isLoading = true;
    
    currentPage++;
    final List<Movie> movies = await fetchMoreMovies(page: currentPage);
    state = [...state, ...movies];
    
    Future.delayed(const Duration(milliseconds: 300));
    isLoading = false; 
  }
  
}