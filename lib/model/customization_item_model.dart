class CustomizationItemModel{

  final String name;
  String? price;
  int? isDefault;
  final int? status;
  bool? isSelected;

  CustomizationItemModel(this.name, this.price, this.isDefault, this.status);

  CustomizationItemModel.fromJson(Map<String, dynamic> json)
      : name = json['name'].toString(),
        price = json['price'],
        isDefault = json['isDefault'],
        status = json['status'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'price': price,
        'status': status,
        'isDefault': isDefault,
      };

}