class OrderSettingModel {
  bool? success;
  Data? data;

  OrderSettingModel({this.success, this.data});

  OrderSettingModel.fromJson(Map<String, dynamic> json) {
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
  String? minOrderValue;
  String? orderAssignManually;
  String? orderRefresh;
  int? orderCommission;
  String? orderDashboardDefaultTime;
  String? vendorOrderMaxTime;
  String? driverOrderMaxTime;
  String? deliveryChargeType;
  String? charges;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.minOrderValue,
        this.orderAssignManually,
        this.orderRefresh,
        this.orderCommission,
        this.orderDashboardDefaultTime,
        this.vendorOrderMaxTime,
        this.driverOrderMaxTime,
        this.deliveryChargeType,
        this.charges,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    minOrderValue = json['min_order_value'];
    orderAssignManually = json['order_assign_manually'];
    orderRefresh = json['orderRefresh'];
    orderCommission = json['order_commission'];
    orderDashboardDefaultTime = json['order_dashboard_default_time'];
    vendorOrderMaxTime = json['vendor_order_max_time'];
    driverOrderMaxTime = json['driver_order_max_time'];
    deliveryChargeType = json['delivery_charge_type'];
    charges = json['charges'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['min_order_value'] = this.minOrderValue;
    data['order_assign_manually'] = this.orderAssignManually;
    data['orderRefresh'] = this.orderRefresh;
    data['order_commission'] = this.orderCommission;
    data['order_dashboard_default_time'] = this.orderDashboardDefaultTime;
    data['vendor_order_max_time'] = this.vendorOrderMaxTime;
    data['driver_order_max_time'] = this.driverOrderMaxTime;
    data['delivery_charge_type'] = this.deliveryChargeType;
    data['charges'] = this.charges;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}