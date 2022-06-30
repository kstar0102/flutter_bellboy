class CartTaxModal {
  bool? success;
  List<CartTaxModalData>? data;

  CartTaxModal({this.success, this.data});

  CartTaxModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new CartTaxModalData.fromJson(v));
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

class CartTaxModalData {
  int? id;
  String? name;
  String? tax;
  String? type;

  CartTaxModalData({this.id, this.name, this.tax, this.type});

  CartTaxModalData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tax = json['tax'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tax'] = this.tax;
    data['type'] = this.type;
    return data;
  }
}
