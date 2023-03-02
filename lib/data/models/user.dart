


import 'location.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? avatarUrl;
  String? accessToken;
  String? fcmToken;
  double? totalBalance;
  String? PaymentCode;
  bool? isConnected;
  LocationModel? currentLocation;

  User({this.phone,this.name,this.email,this.id,this.avatarUrl,this.accessToken,this.fcmToken,this.totalBalance,this.PaymentCode,this.isConnected,this.currentLocation});

  User.fromSnapshot(){
    id ='';
    email ='';
    name = '';
    phone = '';
    avatarUrl = '';
    PaymentCode = '';
    isConnected =false;
    currentLocation = LocationModel(0.0, 0.0);
  }
}