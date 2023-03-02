
abstract class RegisterStates {}

class RegisterInitial extends RegisterStates {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class TryingLogin extends RegisterStates {}

class LoggedIn extends RegisterStates {
  final  userInfo;

  LoggedIn(this.userInfo);
}

class ServiceErrorState extends RegisterStates{
  String msg;
  ServiceErrorState({required this.msg});

  @override
  // TODO: implement props
  List<Object?> get props => [];

}