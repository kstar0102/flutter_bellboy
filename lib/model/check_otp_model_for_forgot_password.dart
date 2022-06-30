class CheckOTPForForgotPasswordModel {
  bool? success;
  int? data;
  String? msg;

  CheckOTPForForgotPasswordModel({this.success, this.data, this.msg});

  CheckOTPForForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['data'] = this.data;
    data['msg'] = this.msg;
    return data;
  }
}
