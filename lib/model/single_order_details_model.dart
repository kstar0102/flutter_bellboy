class SingleOrderDetailsModel {
  bool? success;
  Data? data;

  SingleOrderDetailsModel({this.success, this.data});

  SingleOrderDetailsModel.fromJson(Map<String, dynamic> json) {
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
  dynamic tax;
  String? orderId;
  int? vendorId;
  int? amount;
  int? deliveryPersonId;
  String? orderStatus;
  int? deliveryCharge;
  int? addressId;
  int? promoCodeId;
  int? promoCodePrice;
  int? userId;
  int? vendorDiscountPrice;
  DeliveryPerson? deliveryPerson;
  Vendor? vendor;
  User? user;
  UserAddress? userAddress;
  List<OrderItems>? orderItems;

  Data(
      {this.id,
      this.orderId,
      this.tax,
      this.vendorId,
      this.amount,
      this.deliveryCharge,
      this.deliveryPersonId,
      this.orderStatus,
      this.addressId,
      this.promoCodeId,
      this.promoCodePrice,
      this.userId,
      this.vendorDiscountPrice,
      this.deliveryPerson,
      this.vendor,
      this.user,
      this.userAddress,
      this.orderItems});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    vendorId = json['vendor_id'];
    amount = json['amount'];
    tax = json['tax'];
    deliveryPersonId = json['delivery_person_id'];
    orderStatus = json['order_status'];
    deliveryCharge = json['delivery_charge'];
    addressId = json['address_id'];
    promoCodeId = json['promocode_id'];
    promoCodePrice = json['promocode_price'];
    userId = json['user_id'];
    vendorDiscountPrice = json['vendor_discount_price'];
    deliveryPerson = json['delivery_person'] != null
        ? new DeliveryPerson.fromJson(json['delivery_person'])
        : null;
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    userAddress = json['user_address'] != null
        ? new UserAddress.fromJson(json['user_address'])
        : null;
    if (json['orderItems'] != null) {
      orderItems = [];
      json['orderItems'].forEach((v) {
        orderItems!.add(new OrderItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['vendor_id'] = this.vendorId;
    data['delivery_person_id'] = this.deliveryPersonId;
    data['amount'] = this.amount;
    data['tax'] = this.tax;
    data['order_status'] = this.orderStatus;
    data['address_id'] = this.addressId;
    data['promocode_id'] = this.promoCodeId;
    data['promocode_price'] = this.promoCodePrice;
    data['user_id'] = this.userId;
    data['vendor_discount_price'] = this.vendorDiscountPrice;
    if (this.deliveryPerson != null) {
      data['delivery_person'] = this.deliveryPerson!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.userAddress != null) {
      data['user_address'] = this.userAddress!.toJson();
    }
    if (this.orderItems != null) {
      data['orderItems'] = this.orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryPerson {
  String? firstName;
  String? lastName;
  String? image;
  int? deliveryzone;

  DeliveryPerson(
      {this.firstName, this.lastName, this.image, this.deliveryzone});

  DeliveryPerson.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    image = json['image'];
    deliveryzone = json['deliveryzone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['image'] = this.image;
    data['deliveryzone'] = this.deliveryzone;
    return data;
  }
}

class Vendor {
  String? name;
  String? mapAddress;
  String? image;
  String? lat;
  String? lang;
  List<Null>? cuisine;
  dynamic rate;
  String? tax;
  int? review;

  Vendor(
      {this.name,
      this.mapAddress,
      this.image,
      this.lat,
      this.lang,
      this.cuisine,
      this.rate,
      this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    mapAddress = json['map_address'];
    image = json['image'];
    lat = json['lat'];
    tax = json['tax'];
    lang = json['lang'];
    if (json['cuisine'] != null) {
      cuisine = [];
      // json['cuisine'].forEach((v) { cuisine.add(new Null.fromJson(v)); });
    }
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['map_address'] = this.mapAddress;
    data['image'] = this.image;
    data['tax'] = this.tax;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    if (this.cuisine != null) {
      // data['cuisine'] = this.cuisine.map((v) => v.toJson()).toList();
    }
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class Cuisine {
  Cuisine();

  Cuisine.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? image;
  String? emailId;
  Null emailVerifiedAt;
  String? deviceToken;
  String? phone;
  int? isVerified;
  int? status;
  int? otp;
  String? faviroute;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.name,
      this.image,
      this.emailId,
      this.emailVerifiedAt,
      this.deviceToken,
      this.phone,
      this.isVerified,
      this.status,
      this.otp,
      this.faviroute,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    deviceToken = json['device_token'];
    phone = json['phone'];
    isVerified = json['is_verified'];
    status = json['status'];
    otp = json['otp'];
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['email_id'] = this.emailId;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['device_token'] = this.deviceToken;
    data['phone'] = this.phone;
    data['is_verified'] = this.isVerified;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['faviroute'] = this.faviroute;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class UserAddress {
  String? address;
  String? lat;
  String? lang;

  UserAddress({this.address, this.lat, this.lang});

  UserAddress.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    return data;
  }
}

/*class OrderItems {
  int id;
  // String custimization;
  int item;
  int price;
  int qty;
  String itemName;

  OrderItems({this.id,  this.item, this.price, this.qty, this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // custimization = json['custimization'];
    item = json['item'];
    price = json['price'];
    qty = json['qty'];
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    // data['custimization'] = this.custimization;
    data['item'] = this.item;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['itemName'] = this.itemName;
    return data;
  }
}*/

class OrderItems {
  int? id;
  int? orderId;
  int? item;
  int? price;
  int? qty;
  List<Custimization>? custimization;
  String? createdAt;
  String? updatedAt;
  String? itemName;

  OrderItems(
      {this.id,
      this.orderId,
      this.item,
      this.price,
      this.qty,
      this.custimization,
      this.createdAt,
      this.updatedAt,
      this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    item = json['item'];
    price = json['price'];
    qty = json['qty'];
    if (json['custimization'] != null) {
      custimization = [];
      json['custimization'].forEach((v) {
        custimization!.add(new Custimization.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['item'] = this.item;
    data['price'] = this.price;
    data['qty'] = this.qty;
    if (this.custimization != null) {
      data['custimization'] =
          this.custimization!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['itemName'] = this.itemName;
    return data;
  }
}

class Custimization {
  String? mainMenu;
  CustimizationData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null
        ? new CustimizationData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['main_menu'] = this.mainMenu;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CustimizationData {
  String? name;
  String? price;

  CustimizationData({this.name, this.price});

  CustimizationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
