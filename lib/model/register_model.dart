class RegisterModel {
  bool? success;
  Data? data;
  String? msg;

  RegisterModel({this.success, this.data, this.msg});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  String? name;
  String? emailId;
  String? phone;
  int? status;
  String? image;
  int? isVerified;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? otp;

  Data(
      {this.name,
        this.emailId,
        this.phone,
        this.status,
        this.image,
        this.isVerified,
        this.updatedAt,
        this.createdAt,
        this.id,
        this.otp});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    emailId = json['email_id'];
    phone = json['phone'];
    status = json['status'];
    image = json['image'];
    isVerified = json['is_verified'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email_id'] = this.emailId;
    data['phone'] = this.phone;
    data['status'] = this.status;
    data['image'] = this.image;
    data['is_verified'] = this.isVerified;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['otp'] = this.otp;
    return data;
  }
}