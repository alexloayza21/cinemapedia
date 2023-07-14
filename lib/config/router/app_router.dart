import 'package:go_router/go_router.dart';

import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'movie/:id', // se escribe dentro para las webs, para poder volver al inicio 
          name: MovieScreen.name,
          builder: (context, state) {
            final moviId = state.pathParameters['id'] ?? 'no-id';
            return MovieScreen(movieId: moviId);
          },
        ),
      ]
    ),

    
  ],
);
