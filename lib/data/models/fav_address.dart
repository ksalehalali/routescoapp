
import 'location.dart';

class FavoriteAddress{
  final String id;
  final String name;
  final String address;
  final LocationModel location;
  final String createdDate;

  FavoriteAddress(
      {required this.name, required this.address, required this.location, required this.createdDate,  required this.id});

}