class PromoCodeModel {
  bool? success;
  List<PromoCodeListData>? data;

  PromoCodeModel({this.success, this.data});

  PromoCodeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data =[];
      json['data'].forEach((v) {
        data!.add(new PromoCodeListData.fromJson(v));
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

class PromoCodeListData {
  int? id;
  String? name;
  String? promoCode;
  String? image;
  int? displayCustomerApp;
  String? vendorId;
  String? customerId;
  int? isFlat;
  String? maxUser;
  int? countMaxUser;
  int? flatDiscount;
  String? discountType;
  int? discount;
  String? maxDiscAmount;
  String? minOrderAmount;
  int? maxCount;
  int? countMaxCount;
  String? maxOrder;
  int? countMaxOrder;
  String? coupenType;
  String? description;
  String? startEndDate;
  String? displayText;
  int? status;
  String? createdAt;
  String? updatedAt;

  PromoCodeListData(
      {this.id,
        this.name,
        this.promoCode,
        this.image,
        this.displayCustomerApp,
        this.vendorId,
        this.customerId,
        this.isFlat,
        this.maxUser,
        this.countMaxUser,
        this.flatDiscount,
        this.discountType,
        this.discount,
        this.maxDiscAmount,
        this.minOrderAmount,
        this.maxCount,
        this.countMaxCount,
        this.maxOrder,
        this.countMaxOrder,
        this.coupenType,
        this.description,
        this.startEndDate,
        this.displayText,
        this.status,
        this.createdAt,
        this.updatedAt});

  PromoCodeListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    promoCode = json['promo_code'];
    image = json['image'];
    displayCustomerApp = json['display_customer_app'];
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    isFlat = json['isFlat'];
    maxUser = json['max_user'];
    countMaxUser = json['count_max_user'];
    flatDiscount = json['flatDiscount'];
    discountType = json['discountType'];
    discount = json['discount'];
    maxDiscAmount = json['max_disc_amount'];
    minOrderAmount = json['min_order_amount'];
    maxCount = json['max_count'];
    countMaxCount = json['count_max_count'];
    maxOrder = json['max_order'];
    countMaxOrder = json['count_max_order'];
    coupenType = json['coupen_type'];
    description = json['description'];
    startEndDate = json['start_end_date'];
    displayText = json['display_text'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['promo_code'] = this.promoCode;
    data['image'] = this.image;
    data['display_customer_app'] = this.displayCustomerApp;
    data['vendor_id'] = this.vendorId;
    data['customer_id'] = this.customerId;
    data['isFlat'] = this.isFlat;
    data['max_user'] = this.maxUser;
    data['count_max_user'] = this.countMaxUser;
    data['flatDiscount'] = this.flatDiscount;
    data['discountType'] = this.discountType;
    data['discount'] = this.discount;
    data['max_disc_amount'] = this.maxDiscAmount;
    data['min_order_amount'] = this.minOrderAmount;
    data['max_count'] = this.maxCount;
    data['count_max_count'] = this.countMaxCount;
    data['max_order'] = this.maxOrder;
    data['count_max_order'] = this.countMaxOrder;
    data['coupen_type'] = this.coupenType;
    data['description'] = this.description;
    data['start_end_date'] = this.startEndDate;
    data['display_text'] = this.displayText;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}