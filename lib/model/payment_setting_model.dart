class PaymentSettingModel {
  bool? success;
  Data? data;

  PaymentSettingModel({this.success, this.data});

  PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? cod;
  int? stripe;
  int? razorpay;
  int? paypal;
  int? flutterwave;
  int? wallet;
  String? stripePublishKey;
  String? stripeSecretKey;
  String? paypalProduction;
  String? paypalSendbox;
  String? paypalClientId;
  String? paypalSecretKey;
  String? razorpayPublishKey;
  String? publicKey;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.cod,
        this.stripe,
        this.razorpay,
        this.paypal,
        this.flutterwave,
        this.wallet,
        this.stripePublishKey,
        this.stripeSecretKey,
        this.paypalProduction,
        this.paypalSendbox,
        this.paypalClientId,
        this.paypalSecretKey,
        this.razorpayPublishKey,
        this.publicKey,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cod = json['cod'];
    stripe = json['stripe'];
    razorpay = json['razorpay'];
    paypal = json['paypal'];
    flutterwave = json['flutterwave'];
    wallet = json['wallet'];
    stripePublishKey = json['stripe_publish_key'];
    stripeSecretKey = json['stripe_secret_key'];
    paypalProduction = json['paypal_production'];
    paypalSendbox = json['paypal_sendbox'];
    paypalClientId = json['paypal_client_id'];
    paypalSecretKey = json['paypal_secret_key'];
    razorpayPublishKey = json['razorpay_publish_key'];
    publicKey = json['public_key'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cod'] = this.cod;
    data['stripe'] = this.stripe;
    data['razorpay'] = this.razorpay;
    data['paypal'] = this.paypal;
    data['flutterwave'] = this.flutterwave;
    data['wallet'] = this.wallet;
    data['stripe_publish_key'] = this.stripePublishKey;
    data['stripe_secret_key'] = this.stripeSecretKey;
    data['paypal_production'] = this.paypalProduction;
    data['paypal_sendbox'] = this.paypalSendbox;
    data['paypal_client_id'] = this.paypalClientId;
    data['paypal_secret_key'] = this.paypalSecretKey;
    data['razorpay_publish_key'] = this.razorpayPublishKey;
    data['public_key'] = this.publicKey;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}