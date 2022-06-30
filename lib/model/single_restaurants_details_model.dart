class SingleRestaurantsDetailsModel {
  bool? success;
  Data? data;

  SingleRestaurantsDetailsModel({this.success, this.data});

  SingleRestaurantsDetailsModel.fromJson(Map<String, dynamic> json) {
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
  Vendor? vendor;
  List<RestaurantsDetailsMenuListData>? menu;
  VendorDiscount? vendorDiscount;
  List<DeliveryTimeslot>? deliveryTimeslot;
  List<PickUpTimeslot>? pickUpTimeslot;
  List<SellingTimeslot>? sellingTimeslot;

  Data(
      {this.vendor,
      this.menu,
      this.vendorDiscount,
      this.deliveryTimeslot,
      this.pickUpTimeslot,
      this.sellingTimeslot});

  Data.fromJson(Map<String, dynamic> json) {
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    if (json['menu'] != null) {
      menu = [];
      json['menu'].forEach((v) {
        menu!.add(new RestaurantsDetailsMenuListData.fromJson(v));
      });
    }
    vendorDiscount = json['vendor_discount'] != null
        ? new VendorDiscount.fromJson(json['vendor_discount'])
        : null;
    if (json['delivery_timeslot'] != null) {
      deliveryTimeslot = [];
      json['delivery_timeslot'].forEach((v) {
        deliveryTimeslot!.add(new DeliveryTimeslot.fromJson(v));
      });
    }
    if (json['pick_up_timeslot'] != null) {
      pickUpTimeslot = [];
      json['pick_up_timeslot'].forEach((v) {
        pickUpTimeslot!.add(new PickUpTimeslot.fromJson(v));
      });
    }
    if (json['selling_timeslot'] != null) {
      sellingTimeslot = [];
      json['selling_timeslot'].forEach((v) {
        sellingTimeslot!.add(new SellingTimeslot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.menu != null) {
      data['menu'] = this.menu!.map((v) => v.toJson()).toList();
    }
    if (this.vendorDiscount != null) {
      data['vendor_discount'] = this.vendorDiscount!.toJson();
    }
    if (this.deliveryTimeslot != null) {
      data['delivery_timeslot'] =
          this.deliveryTimeslot!.map((v) => v.toJson()).toList();
    }
    if (this.pickUpTimeslot != null) {
      data['pick_up_timeslot'] =
          this.pickUpTimeslot!.map((v) => v.toJson()).toList();
    }
    if (this.sellingTimeslot != null) {
      data['selling_timeslot'] =
          this.sellingTimeslot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vendor {
  String? image;
  String? name;
  String? mapAddress;
  String? forTwoPerson;
  String? vendorType;
  String? lat;
  String? lang;
  String? cuisineId;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;
  int? id;
  String? tax;

  Vendor(
      {this.image,
      this.name,
      this.mapAddress,
      this.forTwoPerson,
      this.vendorType,
        this.lat,
        this.lang,
      this.cuisineId,
      this.cuisine,
      this.rate,
      this.id,
      this.tax,
      this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    tax = json['tax'];
    name = json['name'];
    mapAddress = json['map_address'];
    forTwoPerson = json['for_two_person'];
    vendorType = json['vendor_type'];
    lat = json['lat'];
    lang = json['lang'];
    cuisineId = json['cuisine_id'];
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(new Cuisine.fromJson(v));
      });
    }
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    data['map_address'] = this.mapAddress;
    data['for_two_person'] = this.forTwoPerson;
    data['vendor_type'] = this.vendorType;
    data['cuisine_id'] = this.cuisineId;
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

class RestaurantsDetailsMenuListData {
  int? id;
  String? name;
  String? image;
  List<SubMenuListData>? submenu;
  String? menuCategory;

  RestaurantsDetailsMenuListData(
      {this.id, this.name, this.image, this.submenu, this.menuCategory});

  RestaurantsDetailsMenuListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    if (json['submenu'] != null) {
      submenu = [];
      json['submenu'].forEach((v) {
        submenu!.add(new SubMenuListData.fromJson(v));
      });
    }
    menuCategory = json['menuCategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    if (this.submenu != null) {
      data['submenu'] = this.submenu!.map((v) => v.toJson()).toList();
    }
    data['menuCategory'] = this.menuCategory;
    return data;
  }
}

class SubMenuListData {
  int? id;
  String? name;
  String? image;
  String? price;
  String? type;
  List<Custimization>? custimization;
  bool? isAdded = false;
  int count = 0;
  int itemQty = 0;
  bool? isRepeatCustomization = false;
  int? tempQty;
  String?  qtyReset;
  int? itemResetValue;
  int? availableItem;

  SubMenuListData(
      {this.id,
      this.name,
      this.image,
      this.price,
      this.type,
      this.custimization,
      required this.count,
      this.isAdded,
      this.isRepeatCustomization,
      this.qtyReset,
      this.itemResetValue,
      this.availableItem,
      });

  SubMenuListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    type = json['type'].toString();
    image = json['image'];
    price = json['price'];
    qtyReset =  json['qty_reset'];
    itemResetValue =  json['item_reset_value'];
    availableItem =  json['availabel_item'];
    if (json['custimization'] != null) {
      custimization = [];
      json['custimization'].forEach((v) {
        custimization!.add(new Custimization.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['image'] = this.image;
    data['price'] = this.price;
    data['qty_reset'] = this.qtyReset;
    data['item_reset_value'] = this.itemResetValue;
    data['availabel_item'] = this.availableItem;
    if (this.custimization != null) {
      data['custimization'] =
          this.custimization!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Custimization {
  int? id;
  String? name;
  String? custimazationItem;
  String? type;

  Custimization({this.id, this.name, this.custimazationItem, this.type});

  Custimization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    custimazationItem = json['custimazation_item'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['custimazation_item'] = this.custimazationItem;
    data['type'] = this.type;
    return data;
  }
}

class VendorDiscount {
  int? id;
  String? type;
  int? discount;
  String? minItemAmount;
  String? maxDiscountAmount;
  String? startEndDate;

  VendorDiscount(
      {this.id,
      this.type,
      this.discount,
      this.minItemAmount,
      this.maxDiscountAmount,
      this.startEndDate});

  VendorDiscount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    discount = json['discount'];
    minItemAmount = json['min_item_amount'];
    maxDiscountAmount = json['max_discount_amount'];
    startEndDate = json['start_end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['discount'] = this.discount;
    data['min_item_amount'] = this.minItemAmount;
    data['max_discount_amount'] = this.maxDiscountAmount;
    data['start_end_date'] = this.startEndDate;
    return data;
  }
}

class DeliveryTimeslot {
  int? id;
  String? dayIndex;
  List<PeriodList>? periodList;
  int? status;

  DeliveryTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  DeliveryTimeslot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayIndex = json['day_index'];
    if (json['period_list'] != null) {
      periodList = [];
      json['period_list'].forEach((v) {
        periodList!.add(new PeriodList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['day_index'] = this.dayIndex;
    if (this.periodList != null) {
      data['period_list'] = this.periodList!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class PeriodList {
  String? startTime;
  String? endTime;
  String? newStartTime;
  String? newEndTime;

  PeriodList(
      {this.startTime, this.endTime, this.newStartTime, this.newEndTime});

  PeriodList.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    newStartTime = json['new_start_time'];
    newEndTime = json['new_end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['new_start_time'] = this.newStartTime;
    data['new_end_time'] = this.newEndTime;
    return data;
  }
}

class PickUpTimeslot {
  int? id;
  String? dayIndex;
  List<PeriodList>? periodList;
  int? status;

  PickUpTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  PickUpTimeslot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayIndex = json['day_index'];
    if (json['period_list'] != null) {
      periodList = [];
      json['period_list'].forEach((v) {
        periodList!.add(new PeriodList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['day_index'] = this.dayIndex;
    if (this.periodList != null) {
      data['period_list'] = this.periodList!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class SellingTimeslot {
  int? id;
  String? dayIndex;
  String? periodList;
  int? status;

  SellingTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  SellingTimeslot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayIndex = json['day_index'];
    periodList = json['period_list'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['day_index'] = this.dayIndex;
    data['period_list'] = this.periodList;
    data['status'] = this.status;
    return data;
  }
}
