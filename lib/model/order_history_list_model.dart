class OrderHistoryListModel {
  bool? success;
  List<OrderHistoryData>? data;

  OrderHistoryListModel({this.success, this.data});

  OrderHistoryListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new OrderHistoryData.fromJson(v));
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

class OrderHistoryData {
  int? id;
  int? amount;
  int? vendorId;
  String? orderStatus;
  int? deliveryPersonId;
  int? deliveryCharge;
  String? date;
  String? time;
  int? addressId;
  DeliveryPerson? deliveryPerson;
  Vendor? vendor;
  Null user;
  List<OrderItems>? orderItems;
  UserAddress? userAddress;

  OrderHistoryData(
      {this.id,
      this.amount,
      this.vendorId,
      this.orderStatus,
      this.deliveryPersonId,
      this.deliveryCharge,
      this.date,
      this.time,
      this.addressId,
      this.deliveryPerson,
      this.vendor,
      this.user,
      this.orderItems,
      this.userAddress});

  OrderHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    vendorId = json['vendor_id'];
    orderStatus = json['order_status'];
    deliveryPersonId = json['delivery_person_id'];
    deliveryCharge = json['delivery_charge'];
    date = json['date'];
    time = json['time'];
    addressId = json['address_id'];
    deliveryPerson = json['delivery_person'] != null
        ? new DeliveryPerson.fromJson(json['delivery_person'])
        : null;
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    user = json['user'];
    if (json['orderItems'] != null) {
      orderItems = [];
      json['orderItems'].forEach((v) {
        orderItems!.add(new OrderItems.fromJson(v));
      });
    }
    userAddress = json['user_address'] != null
        ? new UserAddress.fromJson(json['user_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['vendor_id'] = this.vendorId;
    data['order_status'] = this.orderStatus;
    data['delivery_person_id'] = this.deliveryPersonId;
    data['delivery_charge'] = this.deliveryCharge;
    data['date'] = this.date;
    data['time'] = this.time;
    data['address_id'] = this.addressId;
    if (this.deliveryPerson != null) {
      data['delivery_person'] = this.deliveryPerson!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    data['user'] = this.user;
    if (this.orderItems != null) {
      data['orderItems'] = this.orderItems!.map((v) => v.toJson()).toList();
    }
    if (this.userAddress != null) {
      data['user_address'] = this.userAddress!.toJson();
    }
    return data;
  }
}

class DeliveryPerson {
  String? name;
  String? image;
  String? contact;

  DeliveryPerson({this.name, this.image, this.contact});

  DeliveryPerson.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    contact = json['contact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    data['contact'] = this.contact;
    return data;
  }
}

class Vendor {
  int? id;
  int? userId;
  String? name;
  String? vendorLogo;
  String? emailId;
  String? image;
  String? password;
  String? contact;
  String? cuisineId;
  String? address;
  String? lat;
  String? lang;
  String? mapAddress;
  String? minOrderAmount;
  String? forTwoPerson;
  String? avgDeliveryTime;
  String? licenseNumber;
  String? adminComissionType;
  String? adminComissionValue;
  String? vendorType;
  String? timeSlot;
  String? tax;
  Null deliveryTypeTimeSlot;
  int? isExplorer;
  int? isTop;
  int? vendorOwnDriver;
  Null paymentOption;
  int? status;
  String? vendorLanguage;
  String? createdAt;
  String? updatedAt;
  List<Cuisine>? cuisine;
  double? rate;
  int? review;

  Vendor(
      {this.id,
      this.userId,
      this.name,
      this.vendorLogo,
      this.emailId,
      this.image,
      this.password,
      this.contact,
      this.cuisineId,
      this.address,
      this.lat,
      this.lang,
      this.mapAddress,
      this.minOrderAmount,
      this.forTwoPerson,
      this.avgDeliveryTime,
      this.licenseNumber,
      this.adminComissionType,
      this.adminComissionValue,
      this.vendorType,
      this.timeSlot,
      this.tax,
      this.deliveryTypeTimeSlot,
      this.isExplorer,
      this.isTop,
      this.vendorOwnDriver,
      this.paymentOption,
      this.status,
      this.vendorLanguage,
      this.createdAt,
      this.updatedAt,
      this.cuisine,
      this.rate,
      this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    vendorLogo = json['vendor_logo'];
    emailId = json['email_id'];
    image = json['image'];
    password = json['password'];
    contact = json['contact'];
    cuisineId = json['cuisine_id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    mapAddress = json['map_address'];
    minOrderAmount = json['min_order_amount'];
    forTwoPerson = json['for_two_person'];
    avgDeliveryTime = json['avg_delivery_time'];
    licenseNumber = json['license_number'];
    adminComissionType = json['admin_comission_type'];
    adminComissionValue = json['admin_comission_value'];
    vendorType = json['vendor_type'];
    timeSlot = json['time_slot'];
    tax = json['tax'];
    deliveryTypeTimeSlot = json['delivery_type_timeSlot'];
    isExplorer = json['isExplorer'];
    isTop = json['isTop'];
    vendorOwnDriver = json['vendor_own_driver'];
    paymentOption = json['payment_option'];
    status = json['status'];
    vendorLanguage = json['vendor_language'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(new Cuisine.fromJson(v));
      });
    }
    rate = json['rate'].toDouble();
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['vendor_logo'] = this.vendorLogo;
    data['email_id'] = this.emailId;
    data['image'] = this.image;
    data['password'] = this.password;
    data['contact'] = this.contact;
    data['cuisine_id'] = this.cuisineId;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['map_address'] = this.mapAddress;
    data['min_order_amount'] = this.minOrderAmount;
    data['for_two_person'] = this.forTwoPerson;
    data['avg_delivery_time'] = this.avgDeliveryTime;
    data['license_number'] = this.licenseNumber;
    data['admin_comission_type'] = this.adminComissionType;
    data['admin_comission_value'] = this.adminComissionValue;
    data['vendor_type'] = this.vendorType;
    data['time_slot'] = this.timeSlot;
    data['tax'] = this.tax;
    data['delivery_type_timeSlot'] = this.deliveryTypeTimeSlot;
    data['isExplorer'] = this.isExplorer;
    data['isTop'] = this.isTop;
    data['vendor_own_driver'] = this.vendorOwnDriver;
    data['payment_option'] = this.paymentOption;
    data['status'] = this.status;
    data['vendor_language'] = this.vendorLanguage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.cuisine != null) {
      data['cuisine'] = this.cuisine!.map((v) => v.toJson()).toList();
    }
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class Cuisine {
  String? name;
  String? image;

  Cuisine({this.name, this.image});

  Cuisine.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

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
  OrderHistoryData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null
        ? new OrderHistoryData.fromJson(json['data'])
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

class Data {
  String? name;
  String? price;

  Data({this.name, this.price});

  Data.fromJson(Map<String, dynamic> json) {
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

class UserAddress {
  String? lat;
  String? lang;
  String? address;

  UserAddress({this.lat, this.lang, this.address});

  UserAddress.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lang = json['lang'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['address'] = this.address;
    return data;
  }
}
