
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';

class ActorMapper {

  static Actor castToEntity(Cast cast) => Actor( // el Cast sale del credits_respnse.dart
    id: cast.id, 
    name: cast.name, 
    profilePath: cast.profilePath != null 
      ? 'https://image.tmdb.org/t/p/w500${cast.profilePath}'
      : 'https://painrehabproducts.com/wp-content/uploads/2014/10/facebook-default-no-profile-pic.jpg',
    character: cast.character
  );
  
}