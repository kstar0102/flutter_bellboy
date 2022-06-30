import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/model/apply_promocode_model.dart';
import 'package:mealup/model/cart_tax_modal.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/customization_item_model.dart';
import 'package:mealup/model/promoCode_model.dart';
import 'package:mealup/model/single_restaurants_details_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/address/add_address_screen.dart';
import 'package:mealup/screens/address/edit_address_screen.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/payment_method_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dashboard_screen.dart';

class MyCartScreen extends StatefulWidget {
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];
  List<SubMenuListData> cartMenuItem = [];
  List<Map<String, dynamic>> sendAllTax = [];
  String? restName = '', restImage = '';
  double totalPrice = 0, subTotal = 0, tempTotalWithoutDeliveryCharge = 0;
  int? restId;

  List<PromoCodeListData> _listPromoCode = [];
  List<UserAddressListData> _userAddressList = [];
  List<RestaurantsDetailsMenuListData> _listRestaurantsMenu = [];

  List<DeliveryTimeslot> _listDeliveryTimeSlot = [];
  List<PickUpTimeslot> _listPickupTimeSlot = [];
  List<CartTaxModalData> _listOtherTax = [];

  int radioIndex = -1, deliveryTypeIndex = -1;

  int? selectedAddressId;
  String? strSelectedAddress = '';

  int? vendorDiscount, vendorDiscountID;
  String? vendorDiscountMinItemAmount = '',
      vendorDiscountMaxDiscAmount = '',
      vendorDiscountType = '',
      vendorDiscountStartDtEndDt = '',
      vendorDiscountAvailable = '';

  double otherTaxValue = 0.0;
  double tempOtherTaxTotal = 0.0;
  double tempVar = 0.0;
  double addToFinalTax = 0.0;
  String vandorLat = '';
  String vandorLong = '';

  // double globalTaxDecTotal = 0.0;
  // double globalTaxIncTotal = 0.0;
  double addGlobalTax = 0.0;

  bool calculateTaxFirstTime = true;
  bool inBuildMethodCalculateTaxFirstTime = true;
  bool taxCalDecrementTotal = false;
  bool taxCalIncrementTotal = false;
  bool decTaxInKm = false;
  bool incTaxInKm = false;
  bool isTakeAway = false;
  bool isDelivery = false;
  bool isSetStateAvailable = true;

  String strDeliveryCharges = '';
  String? strOrderSettingDeliveryChargeType = '',
      strFinalDeliveryCharge = '0.0',
      strTaxAmount = '',
      strOtherTaxAmount = '',
      strTaxPercentage = '';
  bool isPromocodeApplied = false,
      isTaxApplied = false,
      isVendorDiscount = false,
      _isSyncing = false;

  late Position currentLocation;
  double? _currentLatitude;
  double? _currentLongitude;
  BitmapDescriptor? _markerIcon;

  double discountAmount = 0;
  String? appliedCouponName, appliedCouponPercentage, strAppiedPromocodeId = '';
  double vendorDiscountAmount = 0;

  int itemLength = 0;

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    _queryNew();
    getUserLocation();
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor =
          await _bitmapDescriptorFromSvgAsset(context, 'images/ic_marker.svg');
      //  _updateBitmap(bitmapDescriptor);
      setState(() {
        _markerIcon = bitmapDescriptor;
      });
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    print('selectedLat $_currentLatitude');
    print('selectedLng $_currentLongitude');
  }

  void _queryNew() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    _products.clear();
    totalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    setState(() {
      if (allRows.length != 0) {
        for (int i = 0; i < allRows.length; i++) {
          _products.add(Product(
            id: allRows[i]['pro_id'],
            restaurantsName: allRows[i]['restName'],
            title: allRows[i]['pro_name'],
            imgUrl: allRows[i]['pro_image'],
            price: double.parse(allRows[i]['pro_price']),
            qty: allRows[i]['pro_qty'],
            restaurantsId: allRows[i]['restId'],
            restaurantImage: allRows[i]['restImage'],
            foodCustomization: allRows[i]['pro_customization'],
            isCustomization: allRows[i]['isCustomization'],
            isRepeatCustomization: allRows[i]['isRepeatCustomization'],
            itemQty: allRows[i]['itemQty'],
            tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
            proType: allRows[i]['pro_type'].toString(),
          ));
          restName = allRows[i]['restName'];
          restImage = allRows[i]['restImage'];
          restId = allRows[i]['restId'];
          totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          print(totalPrice);
          print(restId);
          print(allRows[i]['pro_id']);

          // int isRepeatCustomization = allRows[i]['isRepeatCustomization'];
          /*bool isRepeat;
          if (isRepeatCustomization == 0) {
            isRepeat = false;
          } else {
            isRepeat = true;
          }*/

/*          if (allRows[i]['pro_customization'] == '') {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['pro_price'],
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: [],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          } else {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['itemTempPrice'].toString(),
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: allRows[i]['pro_customization'],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          }*/

          if (allRows[i]['pro_customization'] == '') {
            totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
            tempTotal1 += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          } else {
            totalPrice += double.parse(allRows[i]['pro_price']) + totalPrice;
            tempTotal2 += double.parse(allRows[i]['pro_price']);
          }

          print(totalPrice);
        }

        Constants.checkNetwork().whenComplete(() => callGetRestaurantsDetails(restId, _products));

        Constants.checkNetwork().whenComplete(() => callGetPromocodeListData(restId));
      } else {
        totalPrice = 0;
      }

      print('TempTotal1 $tempTotal1');
      print('TempTotal2 $tempTotal2');
      totalPrice = tempTotal1 + tempTotal2;
      subTotal = totalPrice;
      calculateTax(subTotal);
      if (totalPrice > 0) {
        calculateDeliveryCharge(totalPrice);
      }
    });
  }

  void _query() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    _products.clear();
    totalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    setState(() {
      if (allRows.length != 0) {
        for (int i = 0; i < allRows.length; i++) {
          _products.add(Product(
            id: allRows[i]['pro_id'],
            restaurantsName: allRows[i]['restName'],
            title: allRows[i]['pro_name'],
            imgUrl: allRows[i]['pro_image'],
            price: double.parse(allRows[i]['pro_price']),
            qty: allRows[i]['pro_qty'],
            restaurantsId: allRows[i]['restId'],
            restaurantImage: allRows[i]['restImage'],
            foodCustomization: allRows[i]['pro_customization'],
            isCustomization: allRows[i]['isCustomization'],
            isRepeatCustomization: allRows[i]['isRepeatCustomization'],
            itemQty: allRows[i]['itemQty'],
            tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
            proType: allRows[i]['pro_type'].toString(),
          ));

          restName = allRows[i]['restName'];
          restImage = allRows[i]['restImage'];
          restId = allRows[i]['restId'];
          totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          print(totalPrice);
          print(restId);
          print(allRows[i]['pro_id']);

          // int isRepeatCustomization = allRows[i]['isRepeatCustomization'];
          /*  bool isRepeat;
          if (isRepeatCustomization == 0) {
            isRepeat = false;
          } else {
            isRepeat = true;
          }*/

/*          if (allRows[i]['pro_customization'] == '') {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['pro_price'],
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: [],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          } else {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['itemTempPrice'].toString(),
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: allRows[i]['pro_customization'],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          }*/

          if (allRows[i]['pro_customization'] == '') {
            totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
            tempTotal1 += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          } else {
            totalPrice += double.parse(allRows[i]['pro_price']) + totalPrice;
            tempTotal2 += double.parse(allRows[i]['pro_price']);
          }

          print(totalPrice);
        }

        if (_products.length != 0) {
          for (int i = 0; i < _products.length; i++) {
            if (_listRestaurantsMenu.length != 0) {
              for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                for (int k = 0; k < _listRestaurantsMenu[j].submenu!.length; k++) {
                  if (_listRestaurantsMenu[j].submenu![k].id == _products[i].id) {
                    if (_products[i].foodCustomization == '') {
                      cartMenuItem.add(
                        SubMenuListData(
                            price: _products[i].price.toString(),
                            id: _products[i].id,
                            name: _products[i].title,
                            image: _products[i].imgUrl,
                            count: _products[i].qty!,
                            custimization: [],
                            type: _products[i].proType,
                            isRepeatCustomization:
                                _products[i].isRepeatCustomization == 0 ? false : true,
                            isAdded: true),
                      );
                    } else {
                      cartMenuItem.add(SubMenuListData(
                          price: _products[i].tempPrice.toString(),
                          id: _products[i].id,
                          name: _products[i].title,
                          image: _products[i].imgUrl,
                          count: _products[i].qty!,
                          custimization: _listRestaurantsMenu[j].submenu![k].custimization,
                          type: _products[i].proType,
                          isRepeatCustomization:
                              _products[i].isRepeatCustomization == 0 ? false : true,
                          isAdded: true));
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        setState(() {
          totalPrice = 0;
        });
      }

      print('TempTotal1 $tempTotal1');
      print('TempTotal2 $tempTotal2');
      totalPrice = tempTotal1 + tempTotal2;
      tempTotalWithoutDeliveryCharge = totalPrice;

      if (deliveryTypeIndex == 0) {
        if (totalPrice > 0) {
          calculateDeliveryCharge(totalPrice);
        }
      } else {
        setState(() {
          strFinalDeliveryCharge = '0.0';
          subTotal = totalPrice;
          print('calling calculationTax in query function');
          calculateTax(totalPrice);
          if (vendorDiscountAvailable != null) {
            calculateVendorDiscount();
          }
        });
      }
    });
  }

  Future<BaseModel<SingleRestaurantsDetailsModel>> callGetRestaurantsDetails(
      int? restaurantId, List<Product> _listCart) async {
    SingleRestaurantsDetailsModel response;
    try {
      setState(() {
        _isSyncing = true;
      });

      response = await RestClient(RetroApi().dioData()).singleVendor(restaurantId);
      print(response.success);
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        setState(() {
          _listDeliveryTimeSlot.addAll(response.data!.deliveryTimeslot!);
          _listPickupTimeSlot.addAll(response.data!.pickUpTimeslot!);

          _listRestaurantsMenu.addAll(response.data!.menu!);

          strTaxPercentage = response.data!.vendor!.tax;
          // print('main tax fun calling 2');
          // print('srtTaxPercentage amount $strTaxPercentage');
          double addToMap = 0.0;
          addToMap = subTotal * double.parse(strTaxPercentage!) / 100;
          // print('this is the addition to send all tax $addToMap');
          sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
          getTax();

          if (_listDeliveryTimeSlot.length > 0) {
            selectedAddressId = SharedPreferenceUtil.getInt(Constants.selectedAddressId);
            strSelectedAddress = SharedPreferenceUtil.getString(Constants.selectedAddress);

            if (selectedAddressId == 0) {
              selectedAddressId = null;
            }
            if (strSelectedAddress == '') {
              strSelectedAddress = Languages.of(context)!.labelSelectAddress;
            }

            deliveryTypeIndex = 0;

            var date = DateTime.now();
            print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
            print(DateFormat('EEEE').format(date));
            String day = DateFormat('EEEE').format(date);

            for (int i = 0; i < _listDeliveryTimeSlot.length; i++) {
              if (_listDeliveryTimeSlot[i].status == 1) {
                if (_listDeliveryTimeSlot[i].dayIndex == day) {
                  for (int j = 0; j < _listDeliveryTimeSlot[i].periodList!.length; j++) {
                    String fstartTime = _listDeliveryTimeSlot[i].periodList![j].newStartTime!;
                    String fendTime = _listDeliveryTimeSlot[i].periodList![j].newEndTime!;
                    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                    // DateFormat dateFormat = DateFormat("HH:mm: a");

                    DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
                    DateTime dateTimeEndTime = dateFormat.parse(fendTime);

                    if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
                      _query();
                    } else {
                      if (j == _listDeliveryTimeSlot[i].periodList!.length - 1) {
                        Constants.toastMessage(Languages.of(context)!.labelDeliveryUnavailable);
                        setState(() {
                          deliveryTypeIndex = -1;
                        });
                      } else {
                        continue;
                      }
                    }
                  }
                }
              }
            }
          }

          print('total price before function calling ${totalPrice.runtimeType}');

          if (response.data!.vendorDiscount != null) {
            vendorDiscountStartDtEndDt = response.data!.vendorDiscount!.startEndDate;
            vendorDiscount = response.data!.vendorDiscount!.discount;
            vendorDiscountID = response.data!.vendorDiscount!.id;
            vendorDiscountMaxDiscAmount = response.data!.vendorDiscount!.maxDiscountAmount;
            vendorDiscountMinItemAmount = response.data!.vendorDiscount!.minItemAmount;
            vendorDiscountType = response.data!.vendorDiscount!.type;

            calculateVendorDiscount();
          } else {
            vendorDiscountAvailable = null;
          }

          if (response.data!.vendor != null) {
            if (response.data!.vendor!.lat != null) {
              vandorLat = response.data!.vendor!.lat!;
              vandorLong = response.data!.vendor!.lang!;
            } else {
              vandorLat = '0.0';
              vandorLong = '0.0';
            }
          } else {
            vandorLat = '0.0';
            vandorLong = '0.0';
          }

          if (_listCart.length != 0) {
            for (int i = 0; i < _listCart.length; i++) {
              if (_listRestaurantsMenu.length != 0) {
                for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                  for (int k = 0; k < _listRestaurantsMenu[j].submenu!.length; k++) {
                    if (_listRestaurantsMenu[j].submenu![k].id == _listCart[i].id) {
                      if (_listCart[i].foodCustomization == '') {
                        cartMenuItem.add(SubMenuListData(
                            price: _listCart[i].price.toString(),
                            id: _listCart[i].id,
                            name: _listCart[i].title,
                            image: _listCart[i].imgUrl,
                            count: _listCart[i].qty!,
                            custimization: [],
                            type: _products[i].proType,
                            isRepeatCustomization:
                                _listCart[i].isRepeatCustomization == 0 ? false : true,
                            isAdded: true));
                      } else {
                        cartMenuItem.add(SubMenuListData(
                            price: _listCart[i].tempPrice.toString(),
                            id: _listCart[i].id,
                            name: _listCart[i].title,
                            image: _listCart[i].imgUrl,
                            count: _listCart[i].qty!,
                            custimization: _listRestaurantsMenu[j].submenu![k].custimization,
                            type: _products[i].proType,
                            isRepeatCustomization:
                                _listCart[i].isRepeatCustomization == 0 ? false : true,
                            isAdded: true));
                      }
                    }
                  }
                }
              }
            }
          }
        });
      } else {
        Constants.toastMessage('Error while getting details');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CartTaxModal>> getTax() async {
    CartTaxModal response;
    try {
      setState(() {
        _isSyncing = true;
      });
      response = await RestClient(RetroApi().dioData()).getTax();
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        _listOtherTax.addAll(response.data!);
        otherTax();
      } else {
        Constants.toastMessage('Error while getting details');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> otherTax() async {
    print("how many times i'm calling");
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }

      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    print('srtTaxPercentage amount $strTaxPercentage');
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print("other tax $tempOtherTaxTotal");
    tempOtherTaxTotal += addToMap;
    double additionToTotal = 0.0;
    if (strTaxAmount != null && strTaxAmount != '') {
      additionToTotal = double.parse(strTaxAmount!) + tempOtherTaxTotal;
      print("new additionToTotal==== $additionToTotal");
    } else {
      additionToTotal = tempOtherTaxTotal;
      print("new additionToTotal $additionToTotal");
    }
    setState(() {
      strTaxAmount = additionToTotal.toString();
      print("new strTaxAmount $strTaxAmount");
      // totalPrice = totalPrice + additionToTotal;
      print("new totalPrice $totalPrice");
    });
  }

  Future<void> decrementTax() async {
    sendAllTax.clear();
    addGlobalTax = 0.0;
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    // List<map<String, dynamic>> getItemsFromDb = [];
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }
      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    tempOtherTaxTotal = 0.0;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print('this is the addition to send all tax $addToMap');
    sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
    print('srtTaxPercentage amount $strTaxPercentage');
    print("other tax $tempOtherTaxTotal");
    double additionToTotal = 0.0;
    // if (strTaxAmount != null && strTaxAmount != '') {
    // additionToTotal = double.parse(strTaxAmount) + tempOtherTaxTotal;
    // } else {
    additionToTotal = tempOtherTaxTotal + addToMap;
    // additionToTotal = tempOtherTaxTotal + addToMap;
    // globalTaxDecTotal = additionToTotal;
    addGlobalTax = additionToTotal;
    // }
    setState(() {
      taxCalDecrementTotal = true;
      decTaxInKm = true;
      strTaxAmount = additionToTotal.toString();
      totalPrice = totalPrice + additionToTotal;
    });
  }

  Future<void> incrementTax() async {
    sendAllTax.clear();
    addGlobalTax = 0.0;
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    // List<map<String, dynamic>> getItemsFromDb = [];
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }

      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    tempOtherTaxTotal = 0.0;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print('this is the addition to send all tax $addToMap');
    sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
    print('srtTaxPercentage amount $strTaxPercentage');
    print("other tax $tempOtherTaxTotal");
    double additionToTotal = 0.0;
    // if (strTaxAmount != null && strTaxAmount != '') {
    // additionToTotal = double.parse(strTaxAmount) + tempOtherTaxTotal;
    // } else {
    // additionToTotal = (tempOtherTaxTotal + addToMap);
    additionToTotal = tempOtherTaxTotal + addToMap;
    // additionToTotal = (tempOtherTaxTotal + addToMap);
    // globalTaxIncTotal = additionToTotal;
    addGlobalTax = additionToTotal;
    // }
    setState(() {
      taxCalIncrementTotal = true;
      incTaxInKm = true;
      strTaxAmount = additionToTotal.toString();
      totalPrice = totalPrice + additionToTotal;
    });
  }

  void _update(int? proId, int? proQty, String proPrice, String? proImage, String? proName,
      int? restId, String? restName, String fromWhere) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    if (fromWhere == "increment") {
      incrementTax();
    } else if (fromWhere == "decrement") {
      print("i'm here outside");
      if (rowsAffected == null) {
        print("i'm here");
        setState(() {
          subTotal = 0;
        });
      }
      decrementTax();
    }
    _query();
  }

  @override
  Widget build(BuildContext context) {
    print('==========================My C A R T Screen =================================');
    print('new new total is in build method $totalPrice');

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690), orientation: Orientation.portrait);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Constants.colorBlack),
          backgroundColor: Colors.transparent,
          title: Text(
            Languages.of(context)!.labelYourCart,
            style: TextStyle(
                color: Constants.colorBlack,
                fontWeight: FontWeight.w900,
                fontSize: ScreenUtil().setSp(20),
                fontFamily: Constants.appFontBold),
          ),
        ),
        bottomNavigationBar: subTotal <= 0 || itemLength <= 0
            ? Container(
                height: 1,
              )
            : GestureDetector(
                onTap: () {
                  if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                    if (deliveryTypeIndex == 0) {
                      Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
                    }
                  } else {
                    Navigator.of(context).push(
                      Transitions(
                        transitionType: TransitionType.fade,
                        curve: Curves.bounceInOut,
                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                        widget: LoginScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  height: ScreenUtil().setHeight(50),
                  color: Constants.colorBlack,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10),
                                  right: ScreenUtil().setHeight(10)),
                              child: SvgPicture.asset(
                                'images/ic_map.svg',
                                width: ScreenUtil().setWidth(15),
                                color: Colors.white,
                                height: ScreenUtil().setHeight(15),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Padding(
                                // deliveryTypeIndex
                                padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                child: Text(
                                  () {
                                    if (deliveryTypeIndex == 0) {
                                      return selectedAddressId == null
                                          ? Languages.of(context)!.labelSelectAddress
                                          : strSelectedAddress;
                                    } else {
                                      return Languages.of(context)!.labelBookOrder;
                                    }
                                  }()!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Constants.appFont,
                                      fontSize: ScreenUtil().setSp(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                            if (SharedPreferenceUtil.getInt(Constants.appSettingIsPickup) == 1) {
                              if (deliveryTypeIndex == -1) {
                                Constants.toastMessage('Please select order delivery type.');
                              } else if (deliveryTypeIndex == 0) {
                                if (selectedAddressId == null) {
                                  Constants.toastMessage(
                                      'Please select address for deliver order.');
                                } else {
                                  getAllData();
                                }
                              } else if (deliveryTypeIndex == 1) {
                                getAllData();
                              }
                            } else {
                              if (deliveryTypeIndex == 0) {
                                if (selectedAddressId == null) {
                                  Constants.toastMessage(
                                      'Please select address for deliver order.');
                                } else {
                                  getAllData();
                                }
                              } else if (deliveryTypeIndex == -1) {
                                Constants.toastMessage('Please select order delivery type.');
                              }
                            }
                          } else {
                            Navigator.of(context).push(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: LoginScreen(),
                              ),
                            );
                          }
                          isSetStateAvailable = true;
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: ScreenUtil().setWidth(15)),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Constants.colorTheme,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
        body: ModalProgressHUD(
          inAsyncCall: _isSyncing,
          child: subTotal <= 0 || itemLength <= 0
              ? Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image(
                            image: AssetImage('images/ic_empty_cart.png'),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                          child: Text(
                            Languages.of(context)!.labelNoData,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(18),
                              fontFamily: Constants.appFontBold,
                              color: Constants.colorTheme,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints viewportConstraints) {
                    print("the number of $subTotal");
                    return ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage('images/ic_background_image.png'),
                            fit: BoxFit.cover,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(7)),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15.0),
                                          child: CachedNetworkImage(
                                            height: ScreenUtil().setHeight(70),
                                            width: ScreenUtil().setWidth(70),
                                            imageUrl: restImage!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitFadingCircle(color: Constants.colorTheme),
                                            errorWidget: (context, url, error) => Container(
                                              child:
                                                  Center(child: Image.asset('images/noimage.png')),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(10),
                                                right: ScreenUtil().setWidth(5)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restName!,
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: ScreenUtil().setSp(16)),
                                                ),
                                                Text(
                                                  '',
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont,
                                                      color: Constants.colorGray,
                                                      fontSize: ScreenUtil().setSp(12)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10),
                                    top: 0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    height: ScreenUtil().setHeight(70),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedAddressId = SharedPreferenceUtil.getInt(
                                                  Constants.selectedAddressId);
                                              strSelectedAddress = SharedPreferenceUtil.getString(
                                                  Constants.selectedAddress);

                                              if (selectedAddressId == 0) {
                                                selectedAddressId = null;
                                              }
                                              if (strSelectedAddress == '') {
                                                strSelectedAddress =
                                                    Languages.of(context)!.labelSelectAddress;
                                              }

                                              deliveryTypeIndex = 0;

                                              isDelivery = true;

                                              var date = DateTime.now();
                                              print(date
                                                  .toString()); // prints something like 2019-12-10 10:02:22.287949
                                              print(DateFormat('EEEE').format(date));
                                              String day = DateFormat('EEEE').format(date);

                                              // day = 'Monday';
                                              for (int i = 0;
                                                  i < _listDeliveryTimeSlot.length;
                                                  i++) {
                                                if (_listDeliveryTimeSlot[i].status == 1) {
                                                  if (_listDeliveryTimeSlot[i].dayIndex == day) {
                                                    for (int j = 0;
                                                        j <
                                                            _listDeliveryTimeSlot[i]
                                                                .periodList!
                                                                .length;
                                                        j++) {
                                                      String fstartTime = _listDeliveryTimeSlot[i]
                                                          .periodList![j]
                                                          .newStartTime!;
                                                      String fendTime = _listDeliveryTimeSlot[i]
                                                          .periodList![j]
                                                          .newEndTime!;
                                                      DateFormat dateFormat =
                                                          DateFormat("yyyy-MM-dd HH:mm:ss");
                                                      // DateFormat dateFormat = DateFormat("HH:mm: a");

                                                      DateTime dateTimeStartTime =
                                                          dateFormat.parse(fstartTime);
                                                      DateTime dateTimeEndTime =
                                                          dateFormat.parse(fendTime);

                                                      if (isCurrentDateInRange1(
                                                          dateTimeStartTime, dateTimeEndTime)) {
                                                        _query();
                                                      } else {
                                                        if (j ==
                                                            _listDeliveryTimeSlot[i]
                                                                    .periodList!
                                                                    .length -
                                                                1) {
                                                          Constants.toastMessage(
                                                              Languages.of(context)!
                                                                  .labelDeliveryUnavailable);
                                                          setState(() {
                                                            deliveryTypeIndex = -1;
                                                          });
                                                        } else {
                                                          continue;
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                              if (isDelivery == true || isTakeAway == true) {
                                                if (tempOtherTaxTotal > 0.0) {
                                                  totalPrice += tempOtherTaxTotal;
                                                }
                                                isDelivery = false;
                                                isTakeAway = false;
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 25.0,
                                                height: ScreenUtil().setHeight(25),
                                                child: SvgPicture.asset(
                                                  deliveryTypeIndex == 0
                                                      ? 'images/ic_completed.svg'
                                                      : 'images/ic_gray.svg',
                                                  width: 15,
                                                  height: ScreenUtil().setHeight(15),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(10)),
                                                child: Text(
                                                  Languages.of(context)!.labelDelivery,
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont, fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(30),
                                        ),
                                        SharedPreferenceUtil.getInt(Constants.appSettingIsPickup) ==
                                                1
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    deliveryTypeIndex = 1;
                                                    isTakeAway = true;

                                                    selectedAddressId = null;
                                                    strSelectedAddress = '';

                                                    var date = DateTime.now();
                                                    print(date
                                                        .toString()); // prints something like 2019-12-10 10:02:22.287949
                                                    print(DateFormat('EEEE').format(date));
                                                    String day = DateFormat('EEEE').format(date);

                                                    // day = 'Monday';
                                                    for (int i = 0;
                                                        i < _listPickupTimeSlot.length;
                                                        i++) {
                                                      if (_listPickupTimeSlot[i].status == 1) {
                                                        if (_listPickupTimeSlot[i].dayIndex ==
                                                            day) {
                                                          for (int j = 0;
                                                              j <
                                                                  _listPickupTimeSlot[i]
                                                                      .periodList!
                                                                      .length;
                                                              j++) {
                                                            String fstartTime =
                                                                _listPickupTimeSlot[i]
                                                                    .periodList![j]
                                                                    .newStartTime!;
                                                            String fendTime = _listPickupTimeSlot[i]
                                                                .periodList![j]
                                                                .newEndTime!;
                                                            DateFormat dateFormat =
                                                                DateFormat("yyyy-MM-dd HH:mm:ss");
                                                            // DateFormat dateFormat = DateFormat("HH:mm: a");

                                                            DateTime dateTimeStartTime =
                                                                dateFormat.parse(fstartTime);
                                                            DateTime dateTimeEndTime =
                                                                dateFormat.parse(fendTime);

                                                            if (isCurrentDateInRange1(
                                                                dateTimeStartTime,
                                                                dateTimeEndTime)) {
                                                              // Constants.toastMessage('you can order');
                                                              _query();
                                                            } else {
                                                              if (j ==
                                                                  _listPickupTimeSlot[i]
                                                                          .periodList!
                                                                          .length -
                                                                      1) {
                                                                Constants.toastMessage(
                                                                    Languages.of(context)!
                                                                        .labelTakeawayUnavailable);
                                                                setState(() {
                                                                  deliveryTypeIndex = -1;
                                                                });
                                                              } else {
                                                                continue;
                                                              }
                                                            }
                                                          }
                                                        }
                                                      } else {
                                                        Constants.toastMessage(
                                                            Languages.of(context)!
                                                                .labelTakeawayUnavailable);
                                                        setState(() {
                                                          deliveryTypeIndex = -1;
                                                        });
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 25.0,
                                                      height: ScreenUtil().setHeight(25),
                                                      child: SvgPicture.asset(
                                                        deliveryTypeIndex == 1
                                                            ? 'images/ic_completed.svg'
                                                            : 'images/ic_gray.svg',
                                                        width: 15,
                                                        height: ScreenUtil().setHeight(15),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: ScreenUtil().setWidth(10)),
                                                      child: Text(
                                                        Languages.of(context)!.labelTakeaway,
                                                        style: TextStyle(
                                                            fontFamily: Constants.appFont,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    Transitions(
                                      transitionType: TransitionType.slideUp,
                                      curve: Curves.bounceInOut,
                                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                                      widget: DashboardScreen(0),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(15)),
                                  child: RichText(
                                    textAlign: TextAlign.end,
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                            child: SvgPicture.asset(
                                              'images/ic_plus.svg',
                                              width: ScreenUtil().setWidth(10),
                                              height: ScreenUtil().setHeight(12),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: Languages.of(context)!.labelAddMoreItems,
                                          style: TextStyle(
                                              color: Constants.colorTheme,
                                              fontFamily: Constants.appFont,
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              //this widget for add item quantity
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10),
                                    top: 0),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: ListView.separated(
                                    separatorBuilder: (context, index) => Divider(
                                      color: Constants.colorGray,
                                    ),
                                    itemCount: cartMenuItem.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, position) {
                                      return ScopedModelDescendant<CartModel>(
                                        builder: (context, child, model) {
                                          return Container(
                                            height: ScreenUtil().setHeight(95),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScreenUtil().setWidth(5),
                                                  top: ScreenUtil().setHeight(15),
                                                  bottom: ScreenUtil().setHeight(5)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    child: CachedNetworkImage(
                                                      height: ScreenUtil().setHeight(100),
                                                      width: ScreenUtil().setWidth(70),
                                                      imageUrl: cartMenuItem[position].image!,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context, url) =>
                                                          SpinKitFadingCircle(
                                                              color: Constants.colorTheme),
                                                      errorWidget: (context, url, error) =>
                                                          Container(
                                                        child: Center(
                                                            child:
                                                                Image.asset('images/noimage.png')),
                                                      ),
                                                    ),
                                                  ),
                                                  //cartMenuItem[
                                                  //                                                                     position]
                                                  //                                                                 .name!
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil().setWidth(10), top: 5),
                                                    child: Container(
                                                      alignment: Alignment.topLeft,

                                                      child: (() {
                                                        if (cartMenuItem[position].type == 'veg') {
                                                          return Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(right: 2),
                                                                child: SvgPicture.asset(
                                                                  'images/ic_veg.svg',
                                                                  height:
                                                                      ScreenUtil().setHeight(10.0),
                                                                  width:
                                                                      ScreenUtil().setHeight(10.0),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else if (cartMenuItem[position].type ==
                                                            'non_veg') {
                                                          return Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(right: 2),
                                                                child: SvgPicture.asset(
                                                                  'images/ic_non_veg.svg',
                                                                  height:
                                                                      ScreenUtil().setHeight(10.0),
                                                                  width:
                                                                      ScreenUtil().setHeight(10.0),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else if (cartMenuItem[position].type ==
                                                            'all') {
                                                          return Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                    right:
                                                                        ScreenUtil().setWidth(5)),
                                                                child: SvgPicture.asset(
                                                                  'images/ic_veg.svg',
                                                                  height:
                                                                      ScreenUtil().setHeight(10.0),
                                                                  width:
                                                                      ScreenUtil().setHeight(10.0),
                                                                ),
                                                              ),
                                                              SvgPicture.asset(
                                                                'images/ic_non_veg.svg',
                                                                height:
                                                                    ScreenUtil().setHeight(10.0),
                                                                width: ScreenUtil().setHeight(10.0),
                                                              )
                                                            ],
                                                          );
                                                        }
                                                      }()), // child: SvgPicture.asset(
                                                      //   'images/ic_veg.svg',
                                                      //   width: ScreenUtil()
                                                      //       .setWidth(15),
                                                      //   height: ScreenUtil()
                                                      //       .setHeight(15),
                                                      // ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil().setWidth(10)),
                                                    child: Container(
                                                      width: ScreenUtil().setWidth(180),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.stretch,
                                                        children: [
                                                          Text(
                                                            cartMenuItem[position].name!,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontFamily: Constants.appFont,
                                                                fontSize: ScreenUtil().setSp(16)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                top: ScreenUtil().setHeight(5)),
                                                            child: Text(
                                                              SharedPreferenceUtil.getString(Constants
                                                                      .appSettingCurrencySymbol) +
                                                                  double.parse(
                                                                          cartMenuItem[position]
                                                                              .price!)
                                                                      .toStringAsFixed(2),
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFontBold,
                                                                  color: Constants.colorBlack,
                                                                  fontSize: ScreenUtil().setSp(14)),
                                                            ),
                                                          ),
                                                          cartMenuItem[position]
                                                                      .custimization!
                                                                      .length >
                                                                  0
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    var ab;
                                                                    String? finalFoodCustomization,
                                                                        currentPriceWithoutCustomization;
                                                                    // String title;
                                                                    double? price, tempPrice;
                                                                    // int qty;
                                                                    for (int q = 0;
                                                                        q <
                                                                            _listRestaurantsMenu
                                                                                .length;
                                                                        q++) {
                                                                      for (int w = 0;
                                                                          w <
                                                                              _listRestaurantsMenu[
                                                                                      q]
                                                                                  .submenu!
                                                                                  .length;
                                                                          w++) {
                                                                        if (cartMenuItem[position]
                                                                                .id ==
                                                                            _listRestaurantsMenu[q]
                                                                                .submenu![w]
                                                                                .id) {
                                                                          currentPriceWithoutCustomization =
                                                                              _listRestaurantsMenu[
                                                                                      q]
                                                                                  .submenu![w]
                                                                                  .price;
                                                                        }
                                                                      }
                                                                    }
                                                                    print(
                                                                        currentPriceWithoutCustomization);
                                                                    for (int z = 0;
                                                                        z < model.cart.length;
                                                                        z++) {
                                                                      if (cartMenuItem[position]
                                                                              .id ==
                                                                          model.cart[z].id) {
                                                                        ab = json.decode(model
                                                                            .cart[z]
                                                                            .foodCustomization!);
                                                                        finalFoodCustomization =
                                                                            model.cart[z]
                                                                                .foodCustomization;
                                                                        price = model.cart[z].price;
                                                                        //  title = model.cart[z].title;
                                                                        //  qty = model.cart[z].qty;
                                                                        tempPrice =
                                                                            model.cart[z].tempPrice;
                                                                      }
                                                                    }
                                                                    List<String?>
                                                                        nameOfcustomization = [];
                                                                    for (int i = 0;
                                                                        i < ab.length;
                                                                        i++) {
                                                                      nameOfcustomization.add(
                                                                          ab[i]['data']['name']);
                                                                    }
                                                                    print('before starting $price');
                                                                    print(
                                                                        'before starting tempPrice $tempPrice');
                                                                    cartMenuItem[position]
                                                                            .isRepeatCustomization =
                                                                        true;
                                                                    openFoodCustomizationBottomSheet(
                                                                        model,
                                                                        cartMenuItem[position],
                                                                        double.parse(
                                                                            cartMenuItem[position]
                                                                                .price
                                                                                .toString()),
                                                                        double.parse(
                                                                            currentPriceWithoutCustomization!),
                                                                        totalPrice,
                                                                        cartMenuItem[position]
                                                                            .custimization!,
                                                                        finalFoodCustomization!,
                                                                      position,
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          Languages.of(context)!
                                                                              .labelCustomizable,
                                                                          style: TextStyle(
                                                                              fontFamily:
                                                                                  Constants.appFont,
                                                                              color: Constants
                                                                                  .colorTheme,
                                                                              fontSize: ScreenUtil()
                                                                                  .setSp(15)),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: ScreenUtil()
                                                                                  .setWidth(5)),
                                                                          child: SvgPicture.asset(
                                                                            'images/ic_green_arrow.svg',
                                                                            width: 13,
                                                                            height: 10,
                                                                            color: Constants
                                                                                .colorBlack,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    margin: EdgeInsets.only(
                                                                        top: ScreenUtil()
                                                                            .setHeight(5)),
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(15)),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        //decrement section
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              // getTax();
                                                              if (cartMenuItem[position].count >
                                                                  1) {
                                                                cartMenuItem[position].count--;
                                                                /* double price, tempPrice;
                                                              int qty;*/
                                                                model.updateProduct(
                                                                    cartMenuItem[position].id,
                                                                    cartMenuItem[position].count);
                                                                String? customization,
                                                                    currentPriceWithoutCustomization;
                                                                for (int z = 0;
                                                                    z < model.cart.length;
                                                                    z++) {
                                                                  if (cartMenuItem[position].id ==
                                                                      model.cart[z].id) {
                                                                    /* price = model.cart[z].price;
                                                                  qty = model.cart[z].qty;
                                                                  tempPrice = model.cart[z].tempPrice;*/
                                                                    customization = model
                                                                        .cart[z].foodCustomization;
                                                                  }
                                                                }

                                                                for (int q = 0;
                                                                    q < _listRestaurantsMenu.length;
                                                                    q++) {
                                                                  for (int w = 0;
                                                                      w <
                                                                          _listRestaurantsMenu[q]
                                                                              .submenu!
                                                                              .length;
                                                                      w++) {
                                                                    if (cartMenuItem[position].id ==
                                                                        _listRestaurantsMenu[q]
                                                                            .submenu![w]
                                                                            .id) {
                                                                      currentPriceWithoutCustomization =
                                                                          _listRestaurantsMenu[q]
                                                                              .submenu![w]
                                                                              .price;
                                                                    }
                                                                  }
                                                                }
                                                                print(
                                                                    currentPriceWithoutCustomization);

                                                                if (cartMenuItem[position]
                                                                        .custimization!
                                                                        .length >
                                                                    0) {
                                                                  int isRepeatCustomization =
                                                                      cartMenuItem[position]
                                                                              .isRepeatCustomization!
                                                                          ? 1
                                                                          : 0;
                                                                  _updateForCustomizedFood(
                                                                      cartMenuItem[position].id,
                                                                      cartMenuItem[position].count,
                                                                      double.parse(
                                                                          cartMenuItem[position]
                                                                              .price
                                                                              .toString()),
                                                                      currentPriceWithoutCustomization,
                                                                      cartMenuItem[position].image,
                                                                      cartMenuItem[position].name,
                                                                      restId,
                                                                      restName,
                                                                      customization,
                                                                      isRepeatCustomization,
                                                                      1,
                                                                      "decrement");
                                                                } else {
                                                                  _update(
                                                                      cartMenuItem[position].id,
                                                                      cartMenuItem[position].count,
                                                                      cartMenuItem[position]
                                                                          .price
                                                                          .toString(),
                                                                      cartMenuItem[position].image,
                                                                      cartMenuItem[position].name,
                                                                      restId,
                                                                      restName,
                                                                      "decrement");
                                                                }
                                                              } else {
                                                                cartMenuItem[position].isAdded =
                                                                    false;
                                                                cartMenuItem[position].count = 0;
                                                                model.updateProduct(
                                                                    cartMenuItem[position].id,
                                                                    cartMenuItem[position].count);

                                                                String? customization,
                                                                    currentPriceWithoutCustomization;
                                                                for (int z = 0;
                                                                    z < model.cart.length;
                                                                    z++) {
                                                                  if (cartMenuItem[position].id ==
                                                                      model.cart[z].id) {
                                                                    /*price = model.cart[z].price;
                                                          qty = model.cart[z].qty;
                                                          tempPrice = model.cart[z].tempPrice;*/
                                                                    customization = model
                                                                        .cart[z].foodCustomization;
                                                                  }
                                                                }

                                                                for (int q = 0;
                                                                    q < _listRestaurantsMenu.length;
                                                                    q++) {
                                                                  for (int w = 0;
                                                                      w <
                                                                          _listRestaurantsMenu[q]
                                                                              .submenu!
                                                                              .length;
                                                                      w++) {
                                                                    if (cartMenuItem[position].id ==
                                                                        _listRestaurantsMenu[q]
                                                                            .submenu![w]
                                                                            .id) {
                                                                      currentPriceWithoutCustomization =
                                                                          _listRestaurantsMenu[q]
                                                                              .submenu![w]
                                                                              .price;
                                                                    }
                                                                  }
                                                                }
                                                                print(
                                                                    currentPriceWithoutCustomization);

                                                                if (cartMenuItem[position]
                                                                        .custimization!
                                                                        .length >
                                                                    0) {
                                                                  int isRepeatCustomization =
                                                                      cartMenuItem[position]
                                                                              .isRepeatCustomization!
                                                                          ? 1
                                                                          : 0;
                                                                  _updateForCustomizedFood(
                                                                      cartMenuItem[position].id,
                                                                      cartMenuItem[position].count,
                                                                      double.parse(
                                                                          cartMenuItem[position]
                                                                              .price
                                                                              .toString()),
                                                                      currentPriceWithoutCustomization,
                                                                      cartMenuItem[position].image,
                                                                      cartMenuItem[position].name,
                                                                      restId,
                                                                      restName,
                                                                      customization,
                                                                      isRepeatCustomization,
                                                                      1,
                                                                      "decrement");
                                                                } else {
                                                                  _update(
                                                                      cartMenuItem[position].id,
                                                                      cartMenuItem[position].count,
                                                                      cartMenuItem[position]
                                                                          .price
                                                                          .toString(),
                                                                      cartMenuItem[position].image,
                                                                      cartMenuItem[position].name,
                                                                      restId,
                                                                      restName,
                                                                      "decrement");
                                                                }
                                                              }
                                                              // decrementTax();
                                                            });
                                                            print(
                                                                "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                    ScopedModel.of<CartModel>(
                                                                            context,
                                                                            rebuildOnChange: true)
                                                                        .totalCartValue
                                                                        .toString() +
                                                                    "");
                                                            print("Cart List" +
                                                                ScopedModel.of<CartModel>(context,
                                                                        rebuildOnChange: true)
                                                                    .cart
                                                                    .toString() +
                                                                "");
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(21),
                                                            width: ScreenUtil().setWidth(36),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10),
                                                                  topRight: Radius.circular(10)),
                                                              color: Color(0xfff1f1f1),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '-',
                                                                style: TextStyle(
                                                                    color: Constants.colorTheme),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              top: ScreenUtil().setHeight(5),
                                                              bottom: ScreenUtil().setHeight(5)),
                                                          child: Container(
                                                            alignment: Alignment.center,
                                                            height: ScreenUtil().setHeight(21),
                                                            width: ScreenUtil().setWidth(36),
                                                            child: Text(
                                                              cartMenuItem[position]
                                                                  .count
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFont),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                        //increment section
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              cartMenuItem[position].count++;
                                                            });
                                                            model.updateProduct(
                                                                cartMenuItem[position].id,
                                                                cartMenuItem[position].count);
                                                            print(
                                                                "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                    ScopedModel.of<CartModel>(
                                                                            context,
                                                                            rebuildOnChange: true)
                                                                        .totalCartValue
                                                                        .toString() +
                                                                    "");
                                                            print("Cart List" +
                                                                ScopedModel.of<CartModel>(context,
                                                                        rebuildOnChange: true)
                                                                    .cart
                                                                    .toString() +
                                                                "");
                                                            if (cartMenuItem[position]
                                                                    .custimization!
                                                                    .length >
                                                                0) {
                                                              int isRepeatCustomization =
                                                                  cartMenuItem[position]
                                                                          .isRepeatCustomization!
                                                                      ? 1
                                                                      : 0;
                                                              String? customization,
                                                                  currentPriceWithoutCustomization;
                                                              for (int z = 0;
                                                                  z < model.cart.length;
                                                                  z++) {
                                                                if (cartMenuItem[position].id ==
                                                                    model.cart[z].id) {
                                                                  customization = model
                                                                      .cart[z].foodCustomization;
                                                                }
                                                              }
                                                              for (int q = 0;
                                                                  q < _listRestaurantsMenu.length;
                                                                  q++) {
                                                                for (int w = 0;
                                                                    w <
                                                                        _listRestaurantsMenu[q]
                                                                            .submenu!
                                                                            .length;
                                                                    w++) {
                                                                  if (cartMenuItem[position].id ==
                                                                      _listRestaurantsMenu[q]
                                                                          .submenu![w]
                                                                          .id) {
                                                                    currentPriceWithoutCustomization =
                                                                        _listRestaurantsMenu[q]
                                                                            .submenu![w]
                                                                            .price;
                                                                  }
                                                                }
                                                              }
                                                              print(
                                                                  currentPriceWithoutCustomization);
                                                              _updateForCustomizedFood(
                                                                  cartMenuItem[position].id,
                                                                  cartMenuItem[position].count,
                                                                  double.parse(
                                                                      cartMenuItem[position]
                                                                          .price
                                                                          .toString()),
                                                                  currentPriceWithoutCustomization,
                                                                  cartMenuItem[position].image,
                                                                  cartMenuItem[position].name,
                                                                  restId,
                                                                  restName,
                                                                  customization,
                                                                  isRepeatCustomization,
                                                                  1,
                                                                  "increment");
                                                            } else {
                                                              _update(
                                                                  cartMenuItem[position].id,
                                                                  cartMenuItem[position].count,
                                                                  cartMenuItem[position]
                                                                      .price
                                                                      .toString(),
                                                                  cartMenuItem[position].image,
                                                                  cartMenuItem[position].name,
                                                                  restId,
                                                                  restName,
                                                                  "increment");
                                                            }
                                                            incrementTax();
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(21),
                                                            width: ScreenUtil().setWidth(36),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius.circular(10),
                                                                  bottomRight: Radius.circular(10)),
                                                              color: Color(0xfff1f1f1),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '+',
                                                                style: TextStyle(
                                                                    color: Constants.colorTheme),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10)),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(15),
                                        right: ScreenUtil().setWidth(15)),
                                    child: TextField(
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                                        hintText: Languages.of(context)!.labelAddRequestToRest,
                                        hintStyle: TextStyle(
                                          fontSize: ScreenUtil().setSp(16),
                                          fontFamily: Constants.appFont,
                                          color: Constants.colorGray,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                                child: Text(
                                  '(${Languages.of(context)!.labelOptional})',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      fontSize: ScreenUtil().setSp(12),
                                      color: Constants.colorGray),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              !isPromocodeApplied
                                  ? Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return Container(
                                                      height: MediaQuery.of(context).size.height *
                                                          0.965,
                                                      child: Scaffold(
                                                        appBar: ApplicationToolbar(
                                                          appbarTitle: Languages.of(context)!
                                                              .labelFoodOfferCoupons,
                                                        ),
                                                        body: LayoutBuilder(
                                                          builder: (BuildContext context,
                                                              BoxConstraints viewportConstraints) {
                                                            return ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                  minHeight: viewportConstraints
                                                                      .maxHeight),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Color(0xfff6f6f6),
                                                                    image: DecorationImage(
                                                                      image: AssetImage(
                                                                          'images/ic_background_image.png'),
                                                                      fit: BoxFit.cover,
                                                                    )),
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    /* Container(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: ScreenUtil().setWidth(20),
                                                                          right: ScreenUtil().setWidth(20),
                                                                          top: ScreenUtil().setHeight(10)),
                                                                      child: TextField(
                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.only(
                                                                                  left: ScreenUtil()
                                                                                      .setWidth(
                                                                                          10)),
                                                                          suffixIcon: IconButton(
                                                                            onPressed: () => {},
                                                                            icon:
                                                                                SvgPicture.asset(
                                                                              'images/search.svg',
                                                                              width: ScreenUtil()
                                                                                  .setWidth(20),
                                                                              height: ScreenUtil()
                                                                                  .setHeight(20),
                                                                              color: Color(
                                                                                  Constants
                                                                                      .colorGray),
                                                                            ),
                                                                          ),
                                                                          hintText: Languages.of(
                                                                                  context)!.labelSearchRestOrCoupon,
                                                                          hintStyle: TextStyle(
                                                                            fontSize: ScreenUtil()
                                                                                .setSp(14),
                                                                            fontFamily:
                                                                                Constants.appFont,
                                                                            color: Color(Constants
                                                                                .colorGray),
                                                                          ),
                                                                          border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                const BorderRadius
                                                                                    .all(
                                                                              const Radius
                                                                                  .circular(10.0),
                                                                            ),
                                                                            borderSide:
                                                                                BorderSide.none,
                                                                          ),
                                                                          filled: true,
                                                                          fillColor:
                                                                              Color(0xFFeeeeee),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),*/
                                                                    Expanded(
                                                                      flex: 10,
                                                                      child:
                                                                          _listPromoCode.length != 0
                                                                              ? GridView.count(
                                                                                  crossAxisCount: 2,
                                                                                  crossAxisSpacing:
                                                                                      10,
                                                                                  mainAxisSpacing:
                                                                                      10,
                                                                                  childAspectRatio:
                                                                                      0.90,
                                                                                  padding:
                                                                                      EdgeInsets
                                                                                          .all(10),
                                                                                  children: List.generate(
                                                                                      _listPromoCode
                                                                                          .length,
                                                                                      (index) {
                                                                                    return InkWell(
                                                                                      onTap: () {
                                                                                        final DateTime
                                                                                            now =
                                                                                            DateTime
                                                                                                .now();
                                                                                        final DateFormat
                                                                                            formatter =
                                                                                            DateFormat(
                                                                                                'y-MM-dd');
                                                                                        final String
                                                                                            orderDate =
                                                                                            formatter
                                                                                                .format(now);
                                                                                        isSetStateAvailable =
                                                                                            true;
                                                                                        if (SharedPreferenceUtil.getBool(
                                                                                            Constants
                                                                                                .isLoggedIn)) {
                                                                                          callApplyPromoCall(
                                                                                              context,
                                                                                              _listPromoCode[index]
                                                                                                  .name,
                                                                                              orderDate,
                                                                                              totalPrice,
                                                                                              _listPromoCode[index]
                                                                                                  .id);
                                                                                        } else {
                                                                                          Navigator.of(
                                                                                                  context)
                                                                                              .push(
                                                                                            Transitions(
                                                                                              transitionType:
                                                                                                  TransitionType.fade,
                                                                                              curve:
                                                                                                  Curves.bounceInOut,
                                                                                              reverseCurve:
                                                                                                  Curves.fastLinearToSlowEaseIn,
                                                                                              widget:
                                                                                                  LoginScreen(),
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      child:
                                                                                          Container(
                                                                                        child: Card(
                                                                                          elevation:
                                                                                              2,
                                                                                          shape:
                                                                                              RoundedRectangleBorder(
                                                                                            borderRadius:
                                                                                                BorderRadius.circular(20.0),
                                                                                          ),
                                                                                          child:
                                                                                              Column(
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding:
                                                                                                    const EdgeInsets.only(top: 10),
                                                                                                child:
                                                                                                    ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(15.0),
                                                                                                  child: CachedNetworkImage(
                                                                                                    height: ScreenUtil().setHeight(70),
                                                                                                    width: ScreenUtil().setWidth(70),
                                                                                                    imageUrl: _listPromoCode[index].image!,
                                                                                                    fit: BoxFit.cover,
                                                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Constants.colorTheme),
                                                                                                    errorWidget: (context, url, error) => Container(
                                                                                                      child: Center(child: Image.asset('images/noimage.png')),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding:
                                                                                                    EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                                child:
                                                                                                    Text(
                                                                                                  _listPromoCode[index].name!,
                                                                                                  style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(14)),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding:
                                                                                                    EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                                child:
                                                                                                    Text(
                                                                                                  _listPromoCode[index].promoCode!,
                                                                                                  style: TextStyle(
                                                                                                    fontFamily: Constants.appFont,
                                                                                                    fontSize: ScreenUtil().setSp(18),
                                                                                                    letterSpacing: 4,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                _listPromoCode[index].displayText!,
                                                                                                style: TextStyle(
                                                                                                    fontFamily: Constants.appFont,
                                                                                                    fontSize: ScreenUtil().setSp(12),
                                                                                                    color: Constants.colorTheme),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding:
                                                                                                    EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                                child:
                                                                                                    Text(
                                                                                                  '${Languages.of(context)!.labelValidUpTo} ${_listPromoCode[index].startEndDate!.substring(_listPromoCode[index].startEndDate!.indexOf(" - ") + 1)}',
                                                                                                  style: TextStyle(color: Constants.colorGray, fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(12)),
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                                )
                                                                              : Container(
                                                                                  width: ScreenUtil()
                                                                                      .screenWidth,
                                                                                  height: ScreenUtil()
                                                                                      .screenHeight,
                                                                                  child: Column(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment
                                                                                            .center,
                                                                                    crossAxisAlignment:
                                                                                        CrossAxisAlignment
                                                                                            .center,
                                                                                    children: [
                                                                                      Image(
                                                                                        width: ScreenUtil()
                                                                                            .setWidth(
                                                                                                150),
                                                                                        height: ScreenUtil()
                                                                                            .setHeight(
                                                                                                180),
                                                                                        image: AssetImage(
                                                                                            'images/ic_no_offer.png'),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsets.only(
                                                                                            top: ScreenUtil()
                                                                                                .setHeight(10)),
                                                                                        child: Text(
                                                                                          Languages.of(
                                                                                                  context)!
                                                                                              .labelNoOffer,
                                                                                          textAlign:
                                                                                              TextAlign
                                                                                                  .center,
                                                                                          style:
                                                                                              TextStyle(
                                                                                            fontSize:
                                                                                                ScreenUtil().setSp(18),
                                                                                            fontFamily:
                                                                                                Constants.appFontBold,
                                                                                            color: Constants
                                                                                                .colorTheme,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              });
                                        },
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: Radius.circular(16),
                                          strokeWidth: 2,
                                          dashPattern: [8, 4],
                                          color: Constants.colorTheme,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(12)),
                                            child: Container(
                                              height: ScreenUtil().setHeight(50),
                                              color: Color(0xffd4e1db),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(15),
                                                    right: ScreenUtil().setWidth(15)),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      Languages.of(context)!.labelYouHaveCoupon,
                                                      style: TextStyle(
                                                          fontFamily: Constants.appFont,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      Languages.of(context)!.labelApplyIt,
                                                      style: TextStyle(
                                                          fontFamily: Constants.appFont,
                                                          color: Constants.colorTheme,
                                                          fontSize: ScreenUtil().setSp(16)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(20),
                                        right: ScreenUtil().setWidth(20)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: ScreenUtil().setHeight(20),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              Languages.of(context)!.labelSubtotal,
                                              style: TextStyle(
                                                  fontFamily: Constants.appFont,
                                                  fontSize: ScreenUtil().setSp(16)),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                              child: Text(
                                                "${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                    subTotal.toString(),
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    fontSize: ScreenUtil().setSp(14)),
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(20),
                                              bottom: ScreenUtil().setHeight(20)),
                                          child: DottedLine(
                                            direction: Axis.horizontal,
                                            dashColor: Constants.colorGray,
                                          ),
                                        ),
                                        isPromocodeApplied
                                            ? Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            Languages.of(context)!
                                                                .labelAppliedCoupon,
                                                            style: TextStyle(
                                                                fontFamily: Constants.appFont,
                                                                fontSize: ScreenUtil().setSp(16)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                top: ScreenUtil().setHeight(2)),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  '$appliedCouponName($appliedCouponPercentage)',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          Constants.appFontBold,
                                                                      color: Constants.colorTheme,
                                                                      fontSize:
                                                                          ScreenUtil().setSp(12)),
                                                                ),
                                                                SizedBox(
                                                                  width: ScreenUtil().setWidth(20),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    setState(() {
                                                                      appliedCouponName = '';
                                                                      appliedCouponPercentage = '';
                                                                      totalPrice = totalPrice +
                                                                          discountAmount;
                                                                      discountAmount = 0;
                                                                      isPromocodeApplied = false;
                                                                      strAppiedPromocodeId = '';
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    Languages.of(context)!
                                                                        .labelRemoveCoupon,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants.appFont,
                                                                        color: Constants.colorLike,
                                                                        fontSize:
                                                                            ScreenUtil().setSp(12)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: ScreenUtil().setWidth(10)),
                                                        child: Text(
                                                          "- ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                              discountAmount.toString(),
                                                          style: TextStyle(
                                                              fontFamily: Constants.appFont,
                                                              fontSize: ScreenUtil().setSp(14)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(20),
                                                        bottom: ScreenUtil().setHeight(20)),
                                                    child: DottedLine(
                                                      direction: Axis.horizontal,
                                                      dashColor: Constants.colorGray,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                height: 0,
                                              ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              Languages.of(context)!.labelDeliveryCharge,
                                              style: TextStyle(
                                                  fontFamily: Constants.appFont,
                                                  fontSize: ScreenUtil().setSp(16)),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                              child: Text(
                                                () {
                                                  if (0 < double.parse(strFinalDeliveryCharge!)) {
                                                    return "+ ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                        double.parse(strFinalDeliveryCharge!)
                                                            .roundToDouble()
                                                            .toString();
                                                  } else {
                                                    return "0";
                                                  }
                                                }(),
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    fontSize: ScreenUtil().setSp(14)),
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(20),
                                              bottom: ScreenUtil().setHeight(20)),
                                          child: DottedLine(
                                            direction: Axis.horizontal,
                                            dashColor: Constants.colorGray,
                                          ),
                                        ),
                                        isTaxApplied
                                            ? Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        Languages.of(context)!.labelTax,
                                                        style: TextStyle(
                                                            fontFamily: Constants.appFont,
                                                            fontSize: ScreenUtil().setSp(16)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: ScreenUtil().setWidth(10)),
                                                        child: Text(
                                                          () {
                                                            if (strTaxAmount == "") {
                                                              return "+ ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                  "0";
                                                            } else {
                                                              return "+ ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                  double.parse(strTaxAmount!)
                                                                      .roundToDouble()
                                                                      .toString();
                                                            }
                                                          }(),
                                                          style: TextStyle(
                                                              fontFamily: Constants.appFont,
                                                              fontSize: ScreenUtil().setSp(14)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(20),
                                                        bottom: ScreenUtil().setHeight(20)),
                                                    child: DottedLine(
                                                      direction: Axis.horizontal,
                                                      dashColor: Constants.colorGray,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        isVendorDiscount
                                            ? Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        Languages.of(context)!.labelVendorDiscount,
                                                        style: TextStyle(
                                                            fontFamily: Constants.appFont,
                                                            fontSize: ScreenUtil().setSp(16)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: ScreenUtil().setWidth(10)),
                                                        child: Text(
                                                          "- ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                              vendorDiscountAmount.toString(),
                                                          style: TextStyle(
                                                              fontFamily: Constants.appFont,
                                                              fontSize: ScreenUtil().setSp(14)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(20),
                                                        bottom: ScreenUtil().setHeight(20)),
                                                    child: DottedLine(
                                                      direction: Axis.horizontal,
                                                      dashColor: Constants.colorGray,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)!.labelGrandTotal,
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    color: Constants.colorTheme,
                                                    fontSize: ScreenUtil().setSp(16)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil().setWidth(10)),
                                                child: Text(
                                                  () {
                                                    if (isSetStateAvailable == true) {
                                                      if (addGlobalTax == 0.0 &&
                                                          strTaxAmount != '') {
                                                        totalPrice += double.parse(strTaxAmount!);
                                                        print(
                                                            "new new total is $totalPrice & strtaxamount  $strTaxAmount");
                                                      } else {
                                                        totalPrice += addGlobalTax;
                                                        print(
                                                            "new new total is $totalPrice & addglobaltax  $addGlobalTax");
                                                      }
                                                      // totalPrice +=
                                                      //     addGlobalTax;
                                                      //
                                                      // if (strTaxAmount != '') {
                                                      //   totalPrice +=
                                                      //       double.parse(
                                                      //           strTaxAmount!);
                                                      // }
                                                    }
                                                    if (totalPrice == 0) {
                                                      return "${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                          "0.0";
                                                    } else {
                                                      return "${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                          totalPrice.roundToDouble().toString();
                                                    }
                                                  }(),
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont,
                                                      color: Constants.colorTheme,
                                                      fontSize: ScreenUtil().setSp(14)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  showRemoveAddressdialog(int? id, String? address, String? type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding:
                EdgeInsets.only(left: ScreenUtil().setWidth(10), right: ScreenUtil().setWidth(10)),
            child: Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20),
                  bottom: 0,
                  top: ScreenUtil().setHeight(10)),
              child: Container(
                height: ScreenUtil().setHeight(200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelRemoveAddress,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(18),
                            fontWeight: FontWeight.w900,
                            fontFamily: Constants.appFontBold,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(10),
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setHeight(10),
                              left: ScreenUtil().setWidth(30),
                              bottom: 8),
                          child: Text(
                            type!,
                            style: TextStyle(
                                fontFamily: Constants.appFontBold,
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'images/ic_map.svg',
                              width: ScreenUtil().setWidth(18),
                              height: ScreenUtil().setHeight(18),
                              color: Constants.colorTheme,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(12),
                                    top: ScreenUtil().setHeight(2)),
                                child: Text(
                                  address!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(12),
                                      fontFamily: Constants.appFont,
                                      color: Constants.colorBlack),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  Languages.of(context)!.labelNoGoBack,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.appFontBold,
                                      color: Constants.colorGray),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                                child: GestureDetector(
                                  onTap: () {
                                    callRemoveAddress(id);
                                  },
                                  child: Text(
                                    Languages.of(context)!.labelYesRemoveIt,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.appFontBold,
                                        color: Constants.colorBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  showSelectAddressdialog() {
    isSetStateAvailable = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, addressSetState) {
            return Dialog(
              insetPadding: EdgeInsets.all(5),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    bottom: 0,
                    top: ScreenUtil().setHeight(20)),
                child: Container(
                  height: ScreenUtil().setHeight(400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          if (_currentLongitude != null) {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: AddAddressScreen(
                                  isFromAddAddress: false,
                                  currentLat: _currentLatitude,
                                  currentLong: _currentLongitude,
                                  marker: _markerIcon,
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context)!.labelSelectAddress,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
                                fontWeight: FontWeight.w900,
                                fontFamily: Constants.appFontBold,
                              ),
                            ),
                            GestureDetector(
                              child: Icon(Icons.close),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (_currentLongitude != null) {
                                Navigator.pop(context);
                                Navigator.of(context).push(Transitions(
                                    transitionType: TransitionType.fade,
                                    curve: Curves.bounceInOut,
                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                    // widget: HereMapDemo())
                                    widget: AddAddressScreen(
                                      isFromAddAddress: false,
                                      currentLat: _currentLatitude,
                                      currentLong: _currentLongitude,
                                      marker: _markerIcon,
                                    )));
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(8),
                                  bottom: ScreenUtil().setHeight(8)),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                        child: SvgPicture.asset(
                                          'images/ic_plus.svg',
                                          width: ScreenUtil().setWidth(10),
                                          height: ScreenUtil().setHeight(12),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: Languages.of(context)!.labelAddNewAddress,
                                      style: TextStyle(
                                          color: Constants.colorTheme,
                                          fontFamily: Constants.appFont,
                                          fontSize: ScreenUtil().setSp(12)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: Color(0xffcccccc),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                            child: Text(
                              Languages.of(context)!.labelSavedAddress,
                              style: TextStyle(
                                  fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(16)),
                            ),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(270),
                            child: _userAddressList.length == 0
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          width: ScreenUtil().setWidth(100),
                                          height: ScreenUtil().setHeight(100),
                                          image: AssetImage('images/ic_no_rest.png'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                          child: Text(
                                            '${Languages.of(context)!.labelNoData} \n ${Languages.of(context)!.labelPleaseAddAddress}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(18),
                                              fontFamily: Constants.appFontBold,
                                              color: Constants.colorTheme,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: _userAddressList.length,
                                    itemBuilder: (BuildContext context, int index) => InkWell(
                                      onTap: () {
                                        addressSetState(() {
                                          radioIndex = index;
                                          selectedAddressId = _userAddressList[index].id;
                                          strSelectedAddress = _userAddressList[index].address;

                                          SharedPreferenceUtil.putString(
                                              'selectedLat1', _userAddressList[index].lat!);
                                          SharedPreferenceUtil.putString(
                                              'selectedLng1', _userAddressList[index].lang!);
                                          SharedPreferenceUtil.putString(Constants.selectedAddress,
                                              _userAddressList[index].address!);

                                          SharedPreferenceUtil.putInt(Constants.selectedAddressId,
                                              _userAddressList[index].id);

                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DashboardScreen(2),
                                              ));

                                          setState(() {});
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(20),
                                                    top: ScreenUtil().setHeight(10)),
                                                child: Text(
                                                  _userAddressList[index].type != null
                                                      ? _userAddressList[index].type!
                                                      : '',
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: ScreenUtil().setSp(16),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              ClipRRect(
                                                clipBehavior: Clip.hardEdge,
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                child: SizedBox(
                                                  width: ScreenUtil().setWidth(20),
                                                  height: ScreenUtil().setHeight(20),
                                                  child: Image.asset(
                                                    radioIndex == index
                                                        ? 'images/ic_black_checked.png'
                                                        : 'images/ic_gray_ball.png',
                                                    width: ScreenUtil().setWidth(15),
                                                    height: ScreenUtil().setHeight(15),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'images/ic_map.svg',
                                                  width: ScreenUtil().setWidth(15),
                                                  height: ScreenUtil().setHeight(15),
                                                  color: Constants.colorTheme,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil().setWidth(5),
                                                        top: ScreenUtil().setHeight(2)),
                                                    child: Text(
                                                      _userAddressList[index].address!,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil().setSp(12),
                                                          fontFamily: Constants.appFont,
                                                          color: Constants.colorBlack),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(20),
                                                top: ScreenUtil().setHeight(20)),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context).push(Transitions(
                                                      transitionType: TransitionType.fade,
                                                      curve: Curves.bounceInOut,
                                                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                      // widget: HereMapDemo())
                                                      widget: EditAddressScreen(
                                                          addressId: _userAddressList[index].id,
                                                          latitude: _userAddressList[index].lat,
                                                          longitude: _userAddressList[index].lang,
                                                          strAddress:
                                                              _userAddressList[index].address,
                                                          strAddressType:
                                                              _userAddressList[index].type,
                                                          userId: _userAddressList[index].userId,
                                                          marker: _markerIcon),
                                                    ));
                                                  },
                                                  child: Text(
                                                    Languages.of(context)!.labelEditAddress,
                                                    style: TextStyle(
                                                        color: Constants.colorBlue,
                                                        fontFamily: Constants.appFont,
                                                        fontSize: ScreenUtil().setSp(12)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: ScreenUtil().setWidth(10)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      showRemoveAddressdialog(
                                                          _userAddressList[index].id,
                                                          _userAddressList[index].address,
                                                          _userAddressList[index].type);
                                                    },
                                                    child: Text(
                                                      Languages.of(context)!.labelRemoveThisAddress,
                                                      style: TextStyle(
                                                          color: Constants.colorLike,
                                                          fontFamily: Constants.appFont,
                                                          fontSize: ScreenUtil().setSp(12)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(10),
                                          ),
                                          Divider(
                                            thickness: 1,
                                            color: Color(0xffcccccc),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openFoodCustomizationBottomSheet(
      CartModel cartModel,
      SubMenuListData item,
      double currentFoodItemPrice,
      double currentPriceWithoutCustomization,
      double totalCartAmount,
      List<Custimization> custimization,
      String previousFoodCustomization,
      int position,
      ) {
    print(currentFoodItemPrice);
    print(item.price);

    double tempPrice = 0;

    List<String> _listForAPI = [];

    var previous = jsonDecode(previousFoodCustomization);
    List<PreviousCustomizationItemModel> _listPreviousCustomization = [];

    _listPreviousCustomization =
        (previous as List).map((i) => PreviousCustomizationItemModel.fromJson(i)).toList();

    int previousPrice = 0;
    List<String?> previousItemName = [];
    for (int i = 0; i < _listPreviousCustomization.length; i++) {
      previousPrice += int.parse(_listPreviousCustomization[i].datamodel!.price!);
      previousItemName.add(_listPreviousCustomization[i].datamodel!.name);
    }
    print(previousPrice);

    double singleFinal = currentFoodItemPrice - previousPrice;

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    for (int i = 0; i < custimization.length; i++) {
      String? myJSON = custimization[i].custimazationItem;
      if (custimization[i].custimazationItem != null) {
        var json = jsonDecode(myJSON!);

        _listCustomizationItem = (json as List).map((i) => CustomizationItemModel.fromJson(i)).toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization.add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          for (int z = 0; z < previousItemName.length; z++) {
            if (_listFinalCustomization[i].list[k].name == previousItemName[z]) {
              _listFinalCustomization[i].list[k].isSelected = true;
              _radioButtonFlagList.add(k);
              /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

              tempPrice += double.parse(_listFinalCustomization[i].list[k].price!);
              _listForAPI.add(
                  '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
            } else {
              _listFinalCustomization[i].list[k].isSelected = false;
            }
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization.add(CustomModel(custimization[i].name, _listCustomizationItem));
        continue;
      }

      // _listCustomizationItem.add(CustomizationItemModel(json[i]['name'], json[i]['price'], json[i]['isDefault'], json[i]['status']));
    }

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Scaffold(
                    bottomNavigationBar: Container(
                      height: ScreenUtil().setHeight(50),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: Text(
                                    '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${singleFinal + tempPrice}',
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // ic_green_arrow.svg
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                print('===================Continue with List Data=================');
                                print(_listForAPI.toString());
                                double price = singleFinal + tempPrice;
                                /*CartModel cartModel,
                                    SubMenuListData item,
                                double currentFoodItemPrice,
                                double totalCartAmount,
                                List<Custimization> custimization,
                                String previousFoodCustomization*/
                                int isRepeatCustomization = item.isRepeatCustomization! ? 1 : 0;
                                cartModel.cart[position].foodCustomization = _listForAPI.toString();
                                _updateForCustomizedFood(
                                    item.id,
                                    item.count,
                                    price,
                                    currentPriceWithoutCustomization.toString(),
                                    item.image,
                                    item.name,
                                    restId,
                                    restName,
                                    _listForAPI.toString(),
                                    isRepeatCustomization,
                                    1,
                                    "bottomSheet");
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: Languages.of(context)!.labelContinue,
                                          style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'images/ic_green_arrow.svg',
                                              width: 15,
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: ListView.builder(
                      itemBuilder: (context, outerIndex) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20), left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title!,
                                style: TextStyle(fontSize: 20, fontFamily: Constants.appFontBold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.length != 0
                                ? ListView.builder(
                                    itemBuilder: (context, innerIndex) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              left: ScreenUtil().setWidth(20)),
                                          child: InkWell(
                                            onTap: () {
                                              // changeIndex(index);
                                              print({'On Tap tempPrice : ' + tempPrice.toString()});

                                              if (!_listFinalCustomization[outerIndex]
                                                  .list[innerIndex]
                                                  .isSelected!) {
                                                tempPrice = 0;
                                                _listForAPI.clear();
                                                setState(() {
                                                  _radioButtonFlagList[outerIndex] = innerIndex;
                                                  _listFinalCustomization[outerIndex].list.forEach(
                                                      (element) => element.isSelected = false);
                                                  _listFinalCustomization[outerIndex]
                                                      .list[innerIndex]
                                                      .isSelected = true;

                                                  for (int i = 0;
                                                      i < _listFinalCustomization.length;
                                                      i++) {
                                                    for (int j = 0;
                                                        j < _listFinalCustomization[i].list.length;
                                                        j++) {
                                                      if (_listFinalCustomization[i]
                                                          .list[j]
                                                          .isSelected!) {
                                                        tempPrice += double.parse(
                                                            _listFinalCustomization[i]
                                                                .list[j]
                                                                .price!);
                                                        _listForAPI.add('{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                        print(_listForAPI.toString());
                                                      }
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _listFinalCustomization[outerIndex]
                                                          .list[innerIndex]
                                                          .name,
                                                      style: TextStyle(
                                                          fontFamily: Constants.appFont,
                                                          fontSize: ScreenUtil().setSp(14)),
                                                    ),
                                                    Text(
                                                      SharedPreferenceUtil.getString(
                                                              Constants.appSettingCurrencySymbol) +
                                                          ' ' +
                                                          _listFinalCustomization[outerIndex]
                                                              .list[innerIndex]
                                                              .price!,
                                                      style: TextStyle(
                                                          fontFamily: Constants.appFont,
                                                          fontSize: ScreenUtil().setSp(14)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: ScreenUtil().setWidth(20)),
                                                  child:
                                                      _radioButtonFlagList[outerIndex] == innerIndex
                                                          ? getChecked()
                                                          : getunChecked(),
                                                ),
                                              ],
                                            ),
                                          ));
                                    },
                                    itemCount: _listFinalCustomization[outerIndex].list.length,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                  )
                                : Container(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        'No Customization Data Avaialble.',
                                        style: TextStyle(
                                            fontFamily: Constants.appFontBold,
                                            fontSize: ScreenUtil().setSp(18)),
                                      ),
                                    ),
                                  )
                          ],
                        );
                      },
                      itemCount: _listFinalCustomization.length,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecorationChecked(true, Colors.white),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(Radius.circular(8.0) //                 <--- border radius here
          ),
    );
  }

  void _updateForCustomizedFood(
    int? proId,
    int proQty,
    double proPrice,
    String? currentPriceWithoutCustomization,
    String? proImage,
    String? proName,
    int? restId,
    String? restName,
    String? customization,
    int isRepeatCustomization,
    int isCustomization,
    String fromWhere,
  ) async {
    double price = proPrice * proQty;
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: price.toString(),
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemTempPrice: proPrice,
      DatabaseHelper.columnCurrentPriceWithoutCustomization: currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    if (fromWhere == "increment") {
      incrementTax();
    } else if (fromWhere == "decrement") {
      print("hellooooooooo outside");
      if (rowsAffected == null) {
        print("hellooooooooo");
        setState(() {
          subTotal = 0;
        });
      }
      decrementTax();
    }
    _query();
  }

  void getAllData() async {
    String deliveryType = '';
    if (deliveryTypeIndex == 0) {
      deliveryType = 'HOME';
    } else {
      deliveryType = 'SHOP';
    }
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    allRows.forEach((row) => print(row));
    if (allRows.length != 0) {
      List<Map<String, dynamic>> item = [];
      String? customization;
      for (int i = 0; i < allRows.length; i++) {
        if (allRows[i]['pro_customization'] == '') {
          print('procustom calling');
          var addToItem;
          addToItem = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          item.add({
            'id': allRows[i]['pro_id'],
            'price': addToItem,
            'qty': allRows[i]['pro_qty'],
          });
        } else {
          print('customise calling');
          String addToItem;
          dynamic calculation;
          calculation = allRows[i]['itemTempPrice'] * allRows[i]['pro_qty'];
          addToItem = calculation.toString();
          print('final addToItem is $addToItem');
          item.add({
            'id': allRows[i]['pro_id'],
            'price': addToItem,
            'qty': allRows[i]['pro_qty'],
            'custimization': jsonEncode(allRows[i]['pro_customization'])
          });
          customization = allRows[i]['pro_customization'];
        }
      }

      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('y-MM-dd');
      final String orderDate = formatter.format(now);

      String formattedDate = DateFormat('hh:mm a').format(now);
      print('Time' + formattedDate);

      print('new===' + formattedDate.substring(6, 8));

      String aMPM = '';
      if (formattedDate.substring(6, 8) == 'AM') {
        aMPM = 'am';
      } else {
        aMPM = 'pm';
      }
      String formattedDate1 = DateFormat('hh:mm').format(now);

      print('Address $strSelectedAddress');

      print('===================================');
      print('RestId $restId');
      print('Date' + orderDate);
      print('Time' + formattedDate1 + ' $aMPM');
      print('Total amount ' + totalPrice.toString());
      print({'all Food item $item'});
      print('Address id $selectedAddressId');
      if (isVendorDiscount) {
        print('vendorDiscountAmount $vendorDiscountAmount');
        print('vendorDiscountId $vendorDiscountID');
      } else {
        vendorDiscountID = 0;
        vendorDiscountAmount = 0;
      }

      print(tempTotalWithoutDeliveryCharge);

      Navigator.of(context).push(
        Transitions(
          transitionType: TransitionType.fade,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
          widget: PaymentMethodScreen(
              addressId: selectedAddressId,
              orderAmount: totalPrice.round(),
              orderCustomization: customization,
              orderDate: orderDate,
              orderDeliveryCharge: strFinalDeliveryCharge == '0.0' ? '' : strFinalDeliveryCharge,
              orderItem: item,
              orderDeliveryType: deliveryType,
              orderStatus: 'PENDING',
              orderTime: formattedDate1 + ' $aMPM',
              ordrePromoCode: strAppiedPromocodeId,
              venderId: restId,
              vendorDiscountAmount: vendorDiscountAmount.toInt(),
              vendorDiscountId: vendorDiscountID,
              strTaxAmount: strTaxAmount,
              allTax: sendAllTax),
        ),
      );
    }
  }

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try {
      _userAddressList.clear();
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).userAddress();
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _userAddressList.addAll(response.data!);
          if (_userAddressList.length == 0) {
            setState(() {
              radioIndex = -1;
              selectedAddressId = null;
              strSelectedAddress = '';
            });
          } else {
            setState(() {
              if (selectedAddressId != null) {
                for (int i = 0; i < _userAddressList.length; i++) {
                  if (selectedAddressId == _userAddressList[i].id) {
                    radioIndex = i;
                    SharedPreferenceUtil.putString('selectedLat1', _userAddressList[i].lat!);
                    SharedPreferenceUtil.putString('selectedLng1', _userAddressList[i].lang!);
                  }
                }
              } else {
                radioIndex = -1;
                selectedAddressId = null;
                strSelectedAddress = '';
              }
            });
          }
          showSelectAddressdialog();
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callRemoveAddress(int? id) async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).removeAddress(id);
      Constants.hideDialog(context);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        Navigator.pop(context);
        callGetUserAddresses();
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      setState(() {});
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void calculateTax(double tempTotalWithoutDeliveryCharge) {
    if (strTaxPercentage!.isNotEmpty && strTaxPercentage != null) {
      isTaxApplied = true;
      if (tempTotalWithoutDeliveryCharge != 0) {
        tempTotalWithoutDeliveryCharge =
            tempTotalWithoutDeliveryCharge * int.parse(strTaxPercentage!) / 100;
        // tempTotalWithoutDeliveryCharge.roundToDouble();
        setState(() {
          if (calculateTaxFirstTime == true) {
            if (strTaxAmount != null && strTaxAmount != '') {
              double convertToDouble = 0.0;
              convertToDouble = double.parse(strTaxAmount!);
              tempTotalWithoutDeliveryCharge += convertToDouble;
              addToFinalTax = tempTotalWithoutDeliveryCharge;
              strTaxAmount = tempTotalWithoutDeliveryCharge.toString();
            } else {
              strTaxAmount = tempTotalWithoutDeliveryCharge.toString();
              totalPrice = totalPrice + tempTotalWithoutDeliveryCharge;
              setState(() {
                inBuildMethodCalculateTaxFirstTime = true;
              });
            }
          }
          calculateTaxFirstTime = false;
        });
      }
    } else {
      isTaxApplied = true;
    }
  }

  void calculateVendorDiscount() {
    String apiData = vendorDiscountStartDtEndDt!;

    var parts = apiData.split(' - ');
    print('startttttinnngggggggg ${parts[0]}');
    print('startttttinnngggggggg ${parts[1]}');

    DateTime startDate = DateTime.parse(parts[0]);
    DateTime endDate = DateTime.parse(parts[1]);

    DateTime now = DateTime.now();

    print('now: $now');
    print('startDate: $startDate');
    print('endDate: $endDate');
    print(startDate.isBefore(now));
    print(endDate.isAfter(now));

    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      if (tempTotalWithoutDeliveryCharge > double.parse(vendorDiscountMinItemAmount!)) {
        isVendorDiscount = true;

        if (vendorDiscountType == 'percentage') {
          vendorDiscountAmount = tempTotalWithoutDeliveryCharge * vendorDiscount! / 100;
          print(vendorDiscountAmount);
          if (vendorDiscountAmount < double.parse(vendorDiscountMaxDiscAmount!)) {
            vendorDiscountAmount = vendorDiscountAmount;
          } else {
            vendorDiscountAmount = double.parse(vendorDiscountMaxDiscAmount!);
          }
        } else {
          vendorDiscountAmount = vendorDiscount!.toDouble();
          if (vendorDiscountAmount < double.parse(vendorDiscountMaxDiscAmount!)) {
            vendorDiscountAmount = vendorDiscountAmount;
          } else {
            vendorDiscountAmount = double.parse(vendorDiscountMaxDiscAmount!);
          }
        }
        totalPrice = totalPrice - vendorDiscountAmount;
        setState(() {});
      } else {
        isVendorDiscount = false;
      }
    } else {
      isVendorDiscount = false;
    }
  }

  Future<BaseModel<dynamic>> calculateDeliveryCharge(double subtotal) async {
    dynamic response;
    try {
      response = await RestClient(RetroApi().dioData()).orderSetting();
      print(response.success);
      if (response.success!) {
        strOrderSettingDeliveryChargeType = response.data!.deliveryChargeType;

        if (strOrderSettingDeliveryChargeType == 'order_amount') {
          strDeliveryCharges = response.data!.charges;
          List<DeliveryChargesModel> listDeliveryCharge = [];
          var deliveryCharge = jsonDecode(strDeliveryCharges);
          listDeliveryCharge =
              (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();

          for (int i = 0; i < listDeliveryCharge.length; i++) {
            if (double.parse(listDeliveryCharge[i].maxValue!) < subtotal) {
              setState(() {
                strFinalDeliveryCharge = listDeliveryCharge[i].charges;
              });
            }
          }

          setState(() {
            if (decTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
              decTaxInKm = false;
            } else if (incTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
              incTaxInKm = false;
            } else {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
            }
          });
        } else if (strOrderSettingDeliveryChargeType == 'delivery_distance') {
          double userLat = 0.0;
          double userLong = 0.0 ;
          if(SharedPreferenceUtil.getString('selectedLat1') != ''){
            userLat= double.parse(SharedPreferenceUtil.getString('selectedLat1'));
            userLong = double.parse(SharedPreferenceUtil.getString('selectedLng1'));
          }

          double vendorLat = vandorLat.isNotEmpty ? double.parse(vandorLat) : 0.0;
          double vendorLong = vandorLong.isNotEmpty? double.parse(vandorLong) : 0.0;

          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 -
              c((vendorLat - userLat) * p) / 2 +
              c(userLat * p) * c(vendorLat * p) * (1 - c((vendorLong - userLong) * p)) / 2;
          var distanceKm1 = 12742 * asin(sqrt(a));
          var distanceKm = distanceKm1.round();

          strDeliveryCharges = response.data!.charges;
          List<DeliveryChargesModel> listDeliveryCharge = [];
          var deliveryCharge = jsonDecode(strDeliveryCharges);
          listDeliveryCharge =
              (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();
          String strFinalDeliveryCharge1 = '';
          for (int i = 0; i < listDeliveryCharge.length; i++) {
            if (distanceKm >= double.parse(listDeliveryCharge[i].minValue!) &&
                distanceKm <= double.parse(listDeliveryCharge[i].maxValue!)) {
              strFinalDeliveryCharge1 = listDeliveryCharge[i].charges!;
            }

            /* if (double.parse(listDeliveryCharge[i].maxValue!) < subtotal) {
              setState(() {
                strFinalDeliveryCharge = listDeliveryCharge[i].charges;
              });
            }*/
          }
          if (strFinalDeliveryCharge1 == '') {
            var max = listDeliveryCharge.reduce((current, next) =>
                int.parse(current.charges!) > int.parse(next.charges!) ? current : next);
            strFinalDeliveryCharge = max.charges!;
          } else if (distanceKm < 1) {
            strFinalDeliveryCharge = '0.0';
          } else {
            strFinalDeliveryCharge = strFinalDeliveryCharge1;
          }

          setState(() {
            if (decTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
              decTaxInKm = false;
            } else if (incTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
              incTaxInKm = false;
            } else {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              print(
                  "new new total is in delivery function $totalPrice new new subtotal is $subtotal");
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PromoCodeModel>> callGetPromocodeListData(int? restaurantId) async {
    PromoCodeModel response;
    try {
      Constants.onLoading(context);
      _listPromoCode.clear();
      response = await RestClient(RetroApi().dioData()).promoCode(restaurantId);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _listPromoCode.addAll(response.data!);
        });
        setState(() {});
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<String>> callApplyPromoCall(BuildContext context, String? promocodeName,
      String orderDate, double orderAmount, int? id) async {
    isSetStateAvailable = false;
    String response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'date': orderDate,
        'amount': orderAmount.toString(),
        'delivery_type': 'delivery',
        'promocode_id': id.toString(),
      };
      response = (await RestClient(RetroApi().dioData()).applyPromoCode(body))!;
      Constants.hideDialog(context);
      print(response);
      final body1 = json.decode(response);
      bool success = body1['success'];
      if (success) {
        Map loginMap = jsonDecode(response.toString());
        var commenRes = ApplyPromoCodeModel.fromJson(loginMap as Map<String, dynamic>);
        calculateDiscount(promocodeName, commenRes.data!.discountType, commenRes.data!.discount,
            commenRes.data!.flatDiscount, commenRes.data!.isFlat, orderAmount);
        Navigator.pop(context);
        strAppiedPromocodeId = id.toString();
      } else {
        Map loginMap = jsonDecode(response.toString());
        var commenRes = CommenRes.fromJson(loginMap as Map<String, dynamic>);
        Constants.toastMessage(commenRes.data!);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void calculateDiscount(String? promoName, String? discountType, int? discount, int? flatDiscount,
      int? isFlat, double orderAmount) {
    double tempDisc = 0;
    if (discountType == 'percentage') {
      tempDisc = orderAmount * discount! / 100;
      print('Temp Discount $tempDisc');
      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount!;
        print('after flat disc add $tempDisc');
      }

      discountAmount = tempDisc;
      print('Grand Total = ${orderAmount - tempDisc}');
      appliedCouponPercentage = discount.toString() + '%';
      appliedCouponName = promoName;
    } else {
      tempDisc = tempDisc + discount!;

      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount!;
      }
      discountAmount = tempDisc;
      print(discountAmount);
      print('Grand Total = ${orderAmount - tempDisc}');
      appliedCouponPercentage = discount.toString();
    }

    appliedCouponName = promoName;
    isPromocodeApplied = true;
    totalPrice = totalPrice - discountAmount;
    setState(() {});
  }

  bool validation() {
    if (selectedAddressId == null) {
      Constants.toastMessage('Please select address for deliver order.');
      return false;
    } else if (deliveryTypeIndex == -1) {
      Constants.toastMessage('Please select address for deliver order.');
      return false;
    } else {
      return true;
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  bool isCurrentDateInRange1(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
      return true;
    }
    return false;
  }

  bool isDeliveryAvaible() {
    selectedAddressId = SharedPreferenceUtil.getInt(Constants.selectedAddressId);
    strSelectedAddress = SharedPreferenceUtil.getString(Constants.selectedAddress);

    if (selectedAddressId == 0) {
      selectedAddressId = null;
    }
    if (strSelectedAddress == '') {
      strSelectedAddress = Languages.of(context)!.labelSelectAddress;
    }

    deliveryTypeIndex = 0;

    var date = DateTime.now();
    print(date.toString());
    print(DateFormat('EEEE').format(date));
    String day = DateFormat('EEEE').format(date);

    for (int i = 0; i < _listDeliveryTimeSlot.length; i++) {
      if (_listDeliveryTimeSlot[i].status == 1) {
        if (_listDeliveryTimeSlot[i].dayIndex == day) {
          for (int j = 0; j < _listDeliveryTimeSlot[i].periodList!.length; j++) {
            String fstartTime = _listDeliveryTimeSlot[i].periodList![j].newStartTime!;
            String fendTime = _listDeliveryTimeSlot[i].periodList![j].newEndTime!;
            DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
            DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
            DateTime dateTimeEndTime = dateFormat.parse(fendTime);
            if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
              _query();
            } else {
              if (j == _listDeliveryTimeSlot[i].periodList!.length - 1) {
                Constants.toastMessage(Languages.of(context)!.labelDeliveryUnavailable);
                setState(() {
                  deliveryTypeIndex = -1;
                });
              } else {
                continue;
              }
            }
          }
        }
      }
    }
    return false;
  }

  bool isPickupAvaible() {
    deliveryTypeIndex = 1;

    selectedAddressId = null;
    strSelectedAddress = '';

    var date = DateTime.now();
    print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
    print(DateFormat('EEEE').format(date));
    String day = DateFormat('EEEE').format(date);

    for (int i = 0; i < _listPickupTimeSlot.length; i++) {
      if (_listPickupTimeSlot[i].status == 1) {
        if (_listPickupTimeSlot[i].dayIndex == day) {
          for (int j = 0; j < _listPickupTimeSlot[i].periodList!.length; j++) {
            String fstartTime = _listPickupTimeSlot[i].periodList![j].newStartTime!;
            String fendTime = _listPickupTimeSlot[i].periodList![j].newEndTime!;
            DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
            DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
            DateTime dateTimeEndTime = dateFormat.parse(fendTime);
            if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
              _query();
              return true;
            } else {
              if (j == _listPickupTimeSlot[i].periodList!.length - 1) {
                Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
                setState(() {
                  deliveryTypeIndex = -1;
                });
                return false;
              } else {
                continue;
              }
            }
          }
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
        setState(() {
          deliveryTypeIndex = -1;
        });
        return false;
      }
    }
    return false;
  }
}

class DeliveryChargesModel {
  String? minValue;
  String? maxValue;
  String? charges;

  DeliveryChargesModel({this.minValue, this.maxValue, this.charges});

  factory DeliveryChargesModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryChargesModel(
        minValue: parsedJson['min_value'],
        maxValue: parsedJson['max_value'],
        charges: parsedJson['charges']);
  }
}

class PreviousCustomizationItemModel {
  String? name;
  DataModel? datamodel;

  PreviousCustomizationItemModel(
    this.name,
    this.datamodel,
  );

  PreviousCustomizationItemModel.fromJson(Map<String, dynamic> json) {
    name = json['main_menu'];
    datamodel = DataModel.fromJson(json['data']);
  }

  // ignore: missing_return
  Map<String, dynamic>? toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['main_menu'] = this.name;
    data['data'] = datamodel;
  }
}

class DataModel {
  String? name;
  String? price;

  DataModel({this.name, this.price});

  DataModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}

class TimingSlot {
  String? startTime;
  String? endTime;

  TimingSlot({this.startTime, this.endTime});

  TimingSlot.fromJson(Map<String, dynamic> json)
      : startTime = json['start_time'],
        endTime = json['end_time'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    return data;
  }
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String? title;

  CustomModel(this.title, this.list);
}

/*Widget get rectBorderWidget {
  return DottedBorder(
    dashPattern: [8, 4],
    strokeWidth: 2,
    color: Constants.colorTheme,
    child: Container(
      height: ScreenUtil().setHeight(200),
      width: ScreenUtil().setWidth(120),
      color: Color(0xffd4e1db),
    ),
  );
}*/

/*Widget get roundedRectBorderWidget {
  return DottedBorder(
    borderType: BorderType.RRect,
    radius: Radius.circular(12),
    padding: EdgeInsets.all(6),
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Container(
        height: ScreenUtil().setHeight(200),
        width: ScreenUtil().setWidth(120),
        color: Colors.amber,
      ),
    ),
  );
}*/

/*bool isRestaurantOpen(DateTime currentTime, DateTime open, DateTime close) {
  if (open.isBefore(currentTime) && close.isAfter(currentTime)) {
    return true;
  }
  return false;
}*/
