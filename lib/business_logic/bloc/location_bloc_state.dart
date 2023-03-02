part of 'location_bloc_bloc.dart';


 class LocationBlocState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationInitState extends LocationBlocState {
}

class LoadingState extends LocationBlocState {
}

class LoadedState extends LocationBlocState {
  final location;
  LoadedState(this.location);

  @override
  List<Object?> get props => [location];
}

class ErrorState extends LocationBlocState {
  final String msg;
  ErrorState(this.msg);

  @override
  List<Object?> get props => [msg];
}
