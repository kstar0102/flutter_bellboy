class TrackingModel {
  bool? success;
  Data? data;

  TrackingModel({this.success, this.data});

  TrackingModel.fromJson(Map<String, dynamic> json) {
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
  String? userLat;
  String? userLang;
  String? vendorLat;
  String? vendorLang;
  String? driverLat;
  String? driverLang;

  Data(
      {this.userLat,
        this.userLang,
        this.vendorLat,
        this.vendorLang,
        this.driverLat,
        this.driverLang});

  Data.fromJson(Map<String, dynamic> json) {
    userLat = json['user_lat'];
    userLang = json['user_lang'];
    vendorLat = json['vendor_lat'];
    vendorLang = json['vendor_lang'];
    driverLat = json['driver_lat'];
    driverLang = json['driver_lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_lat'] = this.userLat;
    data['user_lang'] = this.userLang;
    data['vendor_lat'] = this.vendorLat;
    data['vendor_lang'] = this.vendorLang;
    data['driver_lat'] = this.driverLat;
    data['driver_lang'] = this.driverLang;
    return data;
  }
}
