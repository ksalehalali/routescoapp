
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../business_logic/cubit/characters_cubit.dart';
import '../constants/strings.dart';
import '../data/models/products.dart';
import '../data/repos/characters_repo.dart';
import '../data/web_services/characters_web_services.dart';
import 'screens/character_details.dart';
import 'screens/characters_screen.dart';

class AppRouter {
  late ProductRepo charactersRepo;
  late ProductsCubit charactersCubit;

  AppRouter() {
    charactersRepo = ProductRepo(ProductsWebServices());
    charactersCubit = ProductsCubit(charactersRepo);
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case charactersScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (BuildContext context) => charactersCubit,
            child: ProductsScreen(),
          ),
        );

      case characterDetailsScreen:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (BuildContext context) =>
                    ProductsCubit(charactersRepo),
                child: CaracterDetailsScreen(
                  product: product,
                )));
    }
  }
}
