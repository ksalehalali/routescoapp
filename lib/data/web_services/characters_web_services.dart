import 'dart:convert';
import 'package:dio/dio.dart';

import '../../constants/strings.dart';
import 'package:http/http.dart' as http;

import '../models/products.dart';

class ProductsWebServices {
  late Dio dio;
  ProductsWebServices() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      queryParameters: {
        "PageNumber": "1",
        "SizeNumber": "1"
      },
      method: "POST"
    );

    dio = Dio(options);
  }

  Future<List<Product>> getAllProducts() async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://dashcommerce.click68.com/api/ListProduct'));
    request.body = json.encode({
      "PageNumber": "1",
      "SizeNumber": "1"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final services = serviceFromJson(await response.stream.bytesToString());

      print(services.description[2].categoryNameEn);
      return services.description;
    }
    else {
      print(response.reasonPhrase);
      return [];
  }

}}
