import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  List<Product> cart = [];
  double totalCartValue = 0;

  int get total => cart.length;
  int totalQty = 0;
  int? restId;
  String? restName;

  void addProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    print(index);

    cart.add(product);
    calculateTotal();
    notifyListeners();
  }

  int getTotalQty() {
    totalQty = 0;
    cart.forEach((f) {
      totalQty += f.qty!;
    });
    return totalQty;
  }

  int? getRestId() {
    cart.forEach((f) {
      restId = f.restaurantsId;
    });
    return restId;
  }

  String? getRestName() {
    cart.forEach((f) {
      restName = f.restaurantsName;
    });
    return restName;
  }

  void removeProduct(id) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].qty = 1;
    cart.removeWhere((item) => item.id == id);
    calculateTotal();
    notifyListeners();
  }

  void updateProduct(id, qty) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].qty = qty;
    if (cart[index].qty == 0)
      removeProduct(id);

    calculateTotal();
    notifyListeners();
  }

  void updateProductPrice(id, price,qty) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].price = price * qty;
    cart[index].tempPrice = price;

    notifyListeners();
  }


  void clearCart() {
    cart.forEach((f) => f.qty = 1);
    cart = [];
    totalCartValue = 0;
    notifyListeners();
  }


  void calculateTotal() {
    totalCartValue = 0;
    cart.forEach((f) {
      totalCartValue += f.price! * f.qty!;
    });
  }
}

class Product {
  int? id;
  String? title;
  String? imgUrl;
  double? price;
  int? qty;
  int? restaurantsId;
  String? restaurantsName;
  String? restaurantImage;
  String? foodCustomization;
  int? isRepeatCustomization;
  int? isCustomization;
  int? itemQty;
  double? tempPrice;
  String? proType;

  Product(
      {this.id,
      this.title,
      this.price,
      this.qty,
      this.imgUrl,
      this.restaurantsId,
      this.restaurantsName,
      this.restaurantImage,
      this.foodCustomization,
      this.isRepeatCustomization,
      this.isCustomization,
      this.itemQty,
      this.tempPrice,
      this.proType
      });
}
