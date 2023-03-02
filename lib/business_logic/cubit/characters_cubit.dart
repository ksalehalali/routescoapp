import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/char-quotes.dart';
import '../../data/models/products.dart';
import '../../data/repos/characters_repo.dart';

part 'characters_state.dart';

class ProductsCubit extends Cubit<CharactersState> {
  final ProductRepo productsRepo;
  late List<Product> myProducts = [];
  ProductsCubit(this.productsRepo) : super(CharactersInitial());

  List<Product> getAllCharacters() {
    productsRepo.getAllCharacters().then((characters) {
      emit(CharactersLoaded(characters));
      this.myProducts = characters;
    });

    return myProducts;
  }




}
