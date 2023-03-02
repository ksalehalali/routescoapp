

import '../models/char-quotes.dart';
import '../models/products.dart';
import '../web_services/characters_web_services.dart';

class ProductRepo {
  final ProductsWebServices productsWebServices;

  ProductRepo(this.productsWebServices);

  Future<List<Product>> getAllCharacters() async {
    List<Product> products = await productsWebServices.getAllProducts();
    return products;
  }

}
