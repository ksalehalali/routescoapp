class TransactionModel{
  String? transactionId;
  String? userId;
  double? amount;
  String? type;
  String? time;
  bool? isPay;
  TransactionModel({this.userId,this.time,this.amount,this.type,this.transactionId,this.isPay});
}
