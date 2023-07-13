import 'package:flutter/material.dart';

class MovieScreen extends StatelessWidget {

  static const name = 'movie_screen';

  const MovieScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MovieID: $movieId'),
      ),
      body: Center(
        child: Text('MovieScreen'),
     ),
   );
  }
}