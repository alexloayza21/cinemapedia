import 'package:go_router/go_router.dart';

import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [

    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name, //* esto da igual que esté
      builder: (context, state){
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        return HomeScreen(pageIndex: pageIndex);
      },
      routes: [
        GoRoute(// se escribe dentro para las webs, para poder volver al inicio 
          path: 'movie/:id', 
          name: MovieScreen.name,
          builder: (context, state) {
            final moviId = state.pathParameters['id'] ?? 'no-id';
            return MovieScreen(movieId: moviId);
          },
        ),
      ]
    ),

    GoRoute(
      path: '/',
      redirect: (_, __) => '/home/0',
    )

    
  ],
);
