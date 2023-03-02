import 'dart:convert';

Service serviceFromJson(String str) => Service.fromJson(json.decode(str));

String serviceToJson(Service data) => json.encode(data.toJson());

class Service {
  Service({
    required this.status,
    required this.description,
    required this.total,
  });

  bool? status;
  List<Description> description;
  int total;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    status: json["status"],
    description: List<Description>.from(json["description"].map((x) => Description.fromJson(x))),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "description": List<dynamic>.from(description.map((x) => x.toJson())),
    "total": total,
  };
}

class Description {
  Description({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descAr,
    this.descEn,
    required this.price,
    required this.offer,
    required this.image,
    required this.catId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.brandId,
    required this.brandNameAr,
    required this.brandNameEn,
    required this.modelId,
    required this.modelName,
    required this.userId,
    required this.merchentName,
  });

  String id;
  String nameAr;
  String nameEn;
  String? descAr;
  String? descEn;
  int price;
  int offer;
  String image;
  String catId;
  String categoryNameEn;
  String categoryNameAr;
  String brandId;
  String brandNameAr;
  String brandNameEn;
  String modelId;
  String modelName;
  String userId;
  MerchentName merchentName;

  factory Description.fromJson(Map<String, dynamic> json) => Description(
    id: json["id"],
    nameAr: json["name_AR"],
    nameEn: json["name_EN"],
    descAr: json["desc_AR"],
    descEn: json["desc_EN"],
    price: json["price"],
    offer: json["offer"],
    image: json["image"],
    catId: json["catID"],
    categoryNameEn: json["categoryName_EN"],
    categoryNameAr: json["categoryName_AR"],
    brandId: json["brandID"],
    brandNameAr: json["brandNameAR"],
    brandNameEn: json["brandNameEN"],
    modelId: json["modelID"],
    modelName: json["modelName"],
    userId: json["userID"],
    merchentName: merchentNameValues.map[json["merchentName"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_AR": nameAr,
    "name_EN": nameEn,
    "desc_AR": descAr,
    "desc_EN": descEn,
    "price": price,
    "offer": offer,
    "image": image,
    "catID": catId,
    "categoryName_EN": categoryNameEn,
    "categoryName_AR": categoryNameAr,
    "brandID": brandId,
    "brandNameAR": brandNameAr,
    "brandNameEN": brandNameEn,
    "modelID": modelId,
    "modelName": modelName,
    "userID": userId,
    "merchentName": merchentNameValues.reverse[merchentName],
  };
}

enum MerchentName { Q_MARKET }

final merchentNameValues = EnumValues({
  "Q Market": MerchentName.Q_MARKET
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
