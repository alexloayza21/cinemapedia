import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_respository_impl.dart';

// este repositorio es inmutable
final movieRepositoryProvider = Provider((ref) {
  // final movie = MoviedbDatasource();
  // return MovieRepositoryImple( movie);

  return MovieRepositoryImple(MoviedbDatasource());
});


