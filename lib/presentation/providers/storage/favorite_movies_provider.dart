import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/local_storage_repository.dart';
import 'package:cinemapedia/presentation/providers/storage/local_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteMoviesProvider = StateNotifierProvider<StorageMoviesNotifier, Map<int,Movie>>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return StorageMoviesNotifier(localStorageRepository: localStorageRepository);
});

/*
  {
    1234: Movie,
    1235: Movie,
    1236: Movie,
  }
*/

class StorageMoviesNotifier extends StateNotifier<Map<int, Movie>> {
  StorageMoviesNotifier({required this.localStorageRepository}):super({});

  int page = 0;
  final LocalStorageRepository localStorageRepository;

  Future<void> loadNextPage()async{

    final movies = await localStorageRepository.loadMovies(offset: page *10); //todo: limit 20
    page++;

    final tempMoviesMap = <int, Movie>{};
    for (final movie in movies) {
      tempMoviesMap[movie.id] = movie;
    }

    //* el state es un mapa
    state = {...state, ...tempMoviesMap};

    // return movies;

  }

  
}