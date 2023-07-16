import 'package:cinemapedia/presentation/views/views.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.pageIndex});

  static const name = 'home-screen'; // nombre de ruta

  final int pageIndex;

  final viewRoutes = const <Widget>[HomeView(), CategoriesView(), FavoritesView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: viewRoutes,
      ), 
      bottomNavigationBar: CustomBottomNavigation(currentIndex: pageIndex,)
    );
  }
}

