class UserAddressListModel {
  bool? success;
  List<UserAddressListData>? data;

  UserAddressListModel({this.success, this.data});

  UserAddressListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new UserAddressListData.fromJson(v));
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

class UserAddressListData {
  int? id;
  int? userId;
  String? lat;
  String? lang;
  String? address;
  String? type;
  String? createdAt;
  String? updatedAt;

  UserAddressListData(
      {this.id,
        this.userId,
        this.lat,
        this.lang,
        this.address,
        this.type,
        this.createdAt,
        this.updatedAt});

  UserAddressListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    lat = json['lat'];
    lang = json['lang'];
    address = json['address'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['address'] = this.address;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}