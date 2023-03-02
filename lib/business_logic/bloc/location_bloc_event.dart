part of 'location_bloc_bloc.dart';

abstract class LocationBlocEvent {}

class StartEvent extends LocationBlocEvent {}

class GetCurrentLocation extends LocationBlocEvent {}

class FindPlaces extends LocationBlocEvent {
  final String msg;
  FindPlaces({required this.msg});
}
