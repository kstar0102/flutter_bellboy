class TopRestaurantsListModel {
  bool? success;
  List<TopRestaurantsListData>? data;

  TopRestaurantsListModel({this.success, this.data});

  TopRestaurantsListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new TopRestaurantsListData.fromJson(v));
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

class TopRestaurantsListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? vendorType;
  String? cuisineId;
  int? distance;
  bool? like;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  TopRestaurantsListData(
      {this.id,
      this.image,
      this.name,
      this.lat,
      this.lang,
      this.vendorType,
      this.cuisineId,
      this.distance,
      this.like,
      this.cuisine,
      this.rate,
      this.review});

  TopRestaurantsListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    vendorType = json['vendor_type'];
    cuisineId = json['cuisine_id'];
    distance = json['distance'];
    like = json['like'];
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
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['vendor_type'] = this.vendorType;
    data['cuisine_id'] = this.cuisineId;
    data['distance'] = this.distance;
    data['like'] = this.like;
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
