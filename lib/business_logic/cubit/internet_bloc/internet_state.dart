abstract class InternetState {}

class InitialState extends InternetState{}

class Connected extends InternetState {
  String msg;
Connected({required this.msg});
}

class NotConnected extends InternetState{
  String msg;
  NotConnected({required this.msg});
}