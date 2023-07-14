import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';

class ActorRepositoryImpl extends ActorsRepository {

  final ActorsDataSource actorsDataSource;

  ActorRepositoryImpl(this.actorsDataSource);

  @override
  Future<List<Actor>> getActorByMovie(String movieId) {
    return actorsDataSource.getActorByMovie(movieId);
  }
  
}