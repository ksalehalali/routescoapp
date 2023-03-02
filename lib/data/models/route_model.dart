class RouteModel {
  final String id;
  final String name;
  final String area;
  final String from_To;
  final String company;

  const RouteModel({
    required this.id,
    required this.area,
    required this.name,
    required this.from_To,
    required this.company
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'],
        area: json['area'],
        name: json['name'],
    from_To: json['from_To'],
    company: json['company'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': name,
        'area': area,
        'from_To': from_To,
    'company':company
      };
}
