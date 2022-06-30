class Balance {
  bool? success;
  List<Data>? data;

  Balance({this.success, this.data});

  Balance.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? payableId;
  String? type;
  String? amount;
  String? createdAt;
  PaymentDetails? paymentDetails;
  String? date;
  Order? order;
  String? vendorName;

  Data(
      {this.id,
        this.payableId,
        this.type,
        this.amount,
        this.createdAt,
        this.paymentDetails,
        this.date,
        this.order,
        this.vendorName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    payableId = json['payable_id'];
    type = json['type'];
    amount = json['amount'];
    createdAt = json['created_at'];
    paymentDetails = json['payment_details'] != null
        ? new PaymentDetails.fromJson(json['payment_details'])
        : null;
    date = json['date'];
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
    vendorName = json['vendor_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['payable_id'] = this.payableId;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    if (this.paymentDetails != null) {
      data['payment_details'] = this.paymentDetails!.toJson();
    }
    data['date'] = this.date;
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    data['vendor_name'] = this.vendorName;
    return data;
  }
}

class PaymentDetails {
  int? id;
  int? transactionId;
  String? paymentType;
  String? paymentToken;
  String? addedBy;
  String? createdAt;
  String? updatedAt;

  PaymentDetails(
      {this.id,
        this.transactionId,
        this.paymentType,
        this.paymentToken,
        this.addedBy,
        this.createdAt,
        this.updatedAt});

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transaction_id'];
    paymentType = json['payment_type'];
    paymentToken = json['payment_token'];
    addedBy = json['added_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transaction_id'] = this.transactionId;
    data['payment_type'] = this.paymentType;
    data['payment_token'] = this.paymentToken;
    data['added_by'] = this.addedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Order {
  int? id;
  int? vendorId;
  String? orderId;

  Order({this.id, this.vendorId, this.orderId});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vendor_id'] = this.vendorId;
    data['order_id'] = this.orderId;
    return data;
  }
}