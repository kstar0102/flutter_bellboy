class ApplyPromoCodeModel {
  bool? success;
  Data? data;

  ApplyPromoCodeModel({this.success, this.data});

  ApplyPromoCodeModel.fromJson(Map<String, dynamic> json) {
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
  String? image;
  int? isFlat;
  int? flatDiscount;
  int? discount;
  String? discountType;

  Data(
      {this.id,
        this.image,
        this.isFlat,
        this.flatDiscount,
        this.discount,
        this.discountType});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    isFlat = json['isFlat'];
    flatDiscount = json['flatDiscount'];
    discount = json['discount'];
    discountType = json['discountType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['isFlat'] = this.isFlat;
    data['flatDiscount'] = this.flatDiscount;
    data['discount'] = this.discount;
    data['discountType'] = this.discountType;
    return data;
  }
}