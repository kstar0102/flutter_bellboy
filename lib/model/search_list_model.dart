class SearchListModel {
  bool? success;
  Data? data;

  SearchListModel({this.success, this.data});

  SearchListModel.fromJson(Map<String, dynamic> json) {
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
  List<VendorListData>? vendor;
  List<CuisineListData>? cuisine;

  Data({this.vendor, this.cuisine});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['vendor'] != null) {
      vendor = [];
      json['vendor'].forEach((v) {
        vendor!.add(new VendorListData.fromJson(v));
      });
    }
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(new CuisineListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.map((v) => v.toJson()).toList();
    }
    if (this.cuisine != null) {
      data['cuisine'] = this.cuisine!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VendorListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? cuisineId;
  String? vendorType;
  List<VendorCuisine>? cuisine;
  dynamic rate;
  int? review;

  VendorListData(
      {this.id,
      this.image,
      this.name,
      this.lat,
      this.lang,
      this.cuisineId,
      this.vendorType,
      this.cuisine,
      this.rate,
      this.review});

  VendorListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    cuisineId = json['cuisine_id'];
    vendorType = json['vendor_type'];
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(new VendorCuisine.fromJson(v));
      });
    }
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['cuisine_id'] = this.cuisineId;
    data['vendor_type'] = this.vendorType;
    if (this.cuisine != null) {
      data['cuisine'] = this.cuisine!.map((v) => v.toJson()).toList();
    }
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class VendorCuisine {
  String? name;
  String? image;

  VendorCuisine({this.name, this.image});

  VendorCuisine.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

class CuisineListData {
  int? id;
  String? name;
  String? image;

  CuisineListData({this.id, this.name, this.image});

  CuisineListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
