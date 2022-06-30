class OrderStatus {
  List<OrderStatusData>? data;
  bool? success;

  OrderStatus({this.data, this.success});

  OrderStatus.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new OrderStatusData.fromJson(v));
      });
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['success'] = this.success;
    return data;
  }
}

class OrderStatusData {
  String? orderStatus;
  int? id;

  OrderStatusData({this.orderStatus, this.id});

  OrderStatusData.fromJson(Map<String, dynamic> json) {
    orderStatus = json['order_status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_status'] = this.orderStatus;
    data['id'] = this.id;
    return data;
  }
}
