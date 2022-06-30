import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripeLib;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/payment_setting_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/PaypalPayment.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/screens/stripe.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:scoped_model/scoped_model.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int? venderId,
      orderAmount,
      addressId,
      vendorDiscountAmount,
      vendorDiscountId;
  final String? orderDate,
      orderTime,
      orderStatus,
      orderCustomization,
      ordrePromoCode,
      orderDeliveryType,
      strTaxAmount,
      orderDeliveryCharge;
  // final double orderItem;
  final List<Map<String, dynamic>>? orderItem;
  final List<Map<String, dynamic>>? allTax;

  // final List<String> orderItem;

  const PaymentMethodScreen(
      {Key? key,
      this.venderId,
      this.orderDeliveryType,
      this.orderDate,
      this.orderTime,
      this.orderAmount,
      this.orderItem,
      this.addressId,
      this.orderDeliveryCharge,
      this.orderStatus,
      this.orderCustomization,
      this.ordrePromoCode,
      this.vendorDiscountAmount,
      this.vendorDiscountId,
      this.strTaxAmount,
      this.allTax})
      : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

// enum PaymentMethod { paypal, rozarpay, stripe, cashOnDelivery }

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int radioIndex = -1;
  String? orderPaymentType;


  final dbHelper = DatabaseHelper.instance;

  // Razorpay _razorpay;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String strPaymentToken = '';

  String? stripePublicKey;
  String? stripeSecretKey;
  String? stripeToken;
  int? paymentTokenKnow;
  int? paymentStatus;
  String? paymentType;
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int? selectedIndex;

  List<int> listPayment = [];
  List<String> listPaymentName = [];
  List<String> listPaymentImage = [];

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callGetPaymentSettingAPI());
  }

  Future<BaseModel<PaymentSettingModel>> callGetPaymentSettingAPI() async {
    PaymentSettingModel response;
    try{
      final dio = Dio();
      dio.options.headers["Accept"] = "application/json"; // config your dio headers globally// config your dio headers globally
      dio.options.followRedirects = false;
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;

     // response  = await  RestClient(dio).paymentSetting();
      response  = await RestClient(RetroApi().dioData()).paymentSetting();
      print(response.success);

      if (response.success!) {
        if (mounted)
          setState(() {
            SharedPreferenceUtil.putString(Constants.appPaymentCOD, response.data!.cod.toString());
            if(response.data!.wallet != null){
              SharedPreferenceUtil.putString(Constants.appPaymentWallet, response.data!.wallet.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaymentWallet, '0');
            }
            if(response.data!.stripe != null){
              SharedPreferenceUtil.putString(Constants.appPaymentStripe, response.data!.stripe.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaymentStripe, '0');
            }
            if(response.data!.razorpay != null){
              SharedPreferenceUtil.putString(Constants.appPaymentRozerPay, response.data!.razorpay.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaymentRozerPay, '0');
            }

            if(response.data!.paypal != null){
              SharedPreferenceUtil.putString(Constants.appPaymentPaypal, response.data!.paypal.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaymentPaypal, '0');
            }

            if(response.data!.stripePublishKey != null){
              SharedPreferenceUtil.putString(Constants.appStripePublishKey, response.data!.stripePublishKey.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appStripePublishKey, '0');
            }

            if(response.data!.stripeSecretKey != null){
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey, response.data!.stripeSecretKey.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey, '0');
            }

            if(response.data!.paypalProduction != null){
              SharedPreferenceUtil.putString(Constants.appPaypalProduction, response.data!.paypalProduction.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaypalProduction, '0');
            }

            if(response.data!.stripeSecretKey != null){
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox, response.data!.stripeSecretKey.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox, '0');
            }

            if(response.data!.paypalClientId != null){
              SharedPreferenceUtil.putString(Constants.appPaypalClientId, response.data!.paypalClientId.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaypalClientId, '0');
            }
            if(response.data!.paypalSecretKey != null){
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey, response.data!.paypalSecretKey.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey, '0');
            }

            if(response.data!.razorpayPublishKey != null){
              SharedPreferenceUtil.putString(Constants.appRozerpayPublishKey, response.data!.razorpayPublishKey.toString());
            }else{
              SharedPreferenceUtil.putString(Constants.appRozerpayPublishKey, '0');
            }
          });
        if (SharedPreferenceUtil.getString(Constants.appPaymentCOD) == '1') {
          listPayment.add(0);
          listPaymentName.add('Cash on Delivery');
          listPaymentImage.add('images/cod.svg');
        } else {
          listPayment.remove(0);
          listPaymentName.remove('Cash on Delivery');
          listPaymentImage.remove('images/code.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1') {
          listPayment.add(1);
          listPaymentName.add('MealUp Wallet');
          listPaymentImage.add('images/wallet.svg');
        } else {
          listPayment.remove(1);
          listPaymentName.remove('MealUp Wallet');
          listPaymentImage.remove('images/wallet.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentStripe) == '1') {
          listPayment.add(2);
          listPaymentName.add('Stripe');
          listPaymentImage.add('images/ic_stripe.svg');
        } else {
          listPayment.remove(2);
          listPaymentName.remove('Stripe');
          listPaymentImage.remove('images/ic_stripe.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentRozerPay) == '1') {
          listPayment.add(3);
          listPaymentName.add('Rozerpay');
          listPaymentImage.add('images/ic_rozar_pay.svg');
        } else {
          listPayment.remove(3);
          listPaymentName.remove('Rozerpay');
          listPaymentImage.add('images/ic_rozar_pay.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentPaypal) == '1') {
          listPayment.add(4);
          listPaymentName.add('PayPal');
          listPaymentImage.add('images/ic_paypal.svg');
        } else {
          listPayment.remove(4);
          listPaymentName.remove('PayPal');
          listPaymentImage.remove('images/ic_paypal.svg');
        }

        print('listPayment' + listPayment.length.toString());

        stripeLib.Stripe.publishableKey =  SharedPreferenceUtil.getString(Constants.appStripePublishKey);
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }

    }catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }


  @override
  void dispose() {
    super.dispose();
  }

  void openCheckout() async {
    // var options = {
    //   'key': SharedPreferenceUtil.getString(Constants.appRozerpayPublishKey),
    //   'amount': widget.orderAmount! * 100,
    //   'name': SharedPreferenceUtil.getString(Constants.loginUserName),
    //   'description': 'Payment',
    //   'prefill': {
    //     'contact': SharedPreferenceUtil.getString(Constants.loginPhone),
    //     'email': SharedPreferenceUtil.getString(Constants.loginEmail)
    //   },
    //   'external': {
    //     'wallets': ['paytm']
    //   }
    // };
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context)!.labelPaymentMethod,
          ),
          backgroundColor: Color(0xFFFAFAFA),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/ic_background_image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: listPayment.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Column(
                                  children: [
                                    customRadioList(
                                        listPaymentName[index],
                                        listPayment[index],
                                        listPaymentImage[index]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: RoundedCornerAppButton(
                              onPressed: () {
                                if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1) {
                                  if (orderPaymentType != null) {
                                    if (orderPaymentType == 'COD') {
                                      placeOrder();
                                    }
                                    if (orderPaymentType == 'WALLET') {
                                      placeOrder();
                                    } else if (orderPaymentType == 'RAZOR') {
                                      openCheckout();
                                    } else if (orderPaymentType == 'STRIPE') {
                                      stripeSecretKey =
                                          SharedPreferenceUtil.getString(
                                              Constants.appStripeSecretKey);
                                      stripePublicKey =
                                          SharedPreferenceUtil.getString(
                                              Constants.appStripePublishKey);
                                      stripeLib.Stripe.publishableKey =   SharedPreferenceUtil.getString(
                                          Constants.appStripePublishKey);
                                      Navigator.of(context).push(
                                        Transitions(
                                          transitionType: TransitionType.slideUp,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                          widget: PaymentStripe(
                                            orderDeliveryType:
                                            widget.orderDeliveryType,
                                            orderAmount: widget.orderAmount,
                                            venderId: widget.venderId,
                                            ordrePromoCode: widget.ordrePromoCode,
                                            orderTime: widget.orderTime,
                                            orderDate: widget.orderDate,
                                            orderStatus: widget.orderStatus,
                                            orderDeliveryCharge:
                                            widget.orderDeliveryCharge,
                                            orderCustomization:
                                            widget.orderCustomization,
                                            addressId: widget.addressId,
                                            orderItem: widget.orderItem,
                                            vendorDiscountAmount: widget
                                                .vendorDiscountAmount!
                                                .toInt(),
                                            vendorDiscountId:
                                            widget.vendorDiscountId,
                                            allTax: widget.allTax,
                                            // strTaxAmount: widget.strTaxAmount,
                                          ),
                                        ),
                                      );
                                    } else if (orderPaymentType == 'PAYPAL') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              PaypalPayment(
                                                total: widget.orderAmount.toString(),
                                                onFinish: (number) async {
                                                  // payment done
                                                  print('order id: ' + number);
                                                  if (number != null &&
                                                      number.toString() != '') {
                                                    strPaymentToken =
                                                        number.toString();
                                                    placeOrder();
                                                  }
                                                },
                                              ),
                                        ),
                                      );
                                    }
                                  } else {
                                    Constants.toastMessage(Languages
                                        .of(context)!
                                        .labelPleaseSelectPaymentMethod);
                                  }
                                }else{
                                  Constants.toastMessage(Constants.appPaymentCOD);
                                }
                              },
                              btnLabel:
                                  Languages.of(context)!.labelPlaceYourOrder,
                            ),
                          ),
                        ],
                      )),
                ),
              );
            },
          )),
    );
  }

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget customRadioList(String title, int index, String icon) {
    return GestureDetector(
      onTap: () {
        changeIndex(index);
        if (index == 0) {
          orderPaymentType = 'COD';
        }else if (index == 1) {
          orderPaymentType = 'WALLET';
        } else if (index == 2) {
          orderPaymentType = 'STRIPE';
        } else if (index == 3) {
          orderPaymentType = 'RAZOR';
        } else if (index == 4) {
          orderPaymentType = 'PAYPAL';
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          height: ScreenUtil().setHeight(90),
          alignment: Alignment.center,
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SvgPicture.asset(icon),
            ),
            title: Text(
              title,
              style: TextStyle(fontFamily: Constants.appFont, fontSize: 16),
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: SizedBox(
                  width: 25.0,
                  height: ScreenUtil().setHeight(25),
                  child: SvgPicture.asset(
                    radioIndex == index
                        ? 'images/ic_completed.svg'
                        : 'images/ic_gray.svg',
                    width: 15,
                    height: ScreenUtil().setHeight(15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CommenRes>> placeOrder() async {
    CommenRes response;
    try{
      Constants.onLoading(context);
      print('without ${json.encode(widget.orderItem.toString())}');
      String item1 = json.encode(widget.orderItem).toString();
      print('with ${item1.toString()}');
      // var json = jsonEncode(widget.orderItem, toEncodable: (e) => e.toString());
      Map<String, dynamic> item = {"id": 11, "price": 200, "qty": 1};

      item = {"id": 10, "price": 195, "qty": 3};

      List<Map<String, dynamic>> temp = [];
      temp.add({'id': 10, 'price': 195, 'qty': 3});
      temp.add({'id': 11, 'price': 200, 'qty': 1});

      print('with $item');
      print('temp without ${json.encode(temp.toString())}');
      print('temp with' + json.encode(temp).toString());

      print('item with' + jsonEncode(item));
      // item.addEntries({"id": 2, "price": 200, "qty": 2});
      print('the amount ${widget.orderAmount.toString()}');
      Map<String, String?> body = {
        'vendor_id': widget.venderId.toString(),
        'date': widget.orderDate,
        'time': widget.orderTime,
        'item': json.encode(widget.orderItem).toString(),
        // 'item': json.encode(widget.orderItem).toString(),
        // 'item': '[{\'id\':\'11\',\'price\':\'200\',\'qty\':\'1\'},{\'id\':\'10\',\'price\':\'195\',\'qty\':\'3\'}]',
        'amount': widget.orderAmount.toString(),
        'delivery_type': widget.orderDeliveryType,
        'address_id': widget.orderDeliveryType == 'SHOP' ? '' : widget.addressId.toString(),
        'delivery_charge': widget.orderDeliveryCharge,
        'payment_type': orderPaymentType,
        'payment_status': orderPaymentType == 'COD' ? '0' : '1',
        'order_status': widget.orderStatus,
        'custimization': json.encode(widget.orderCustomization).toString(),
        'promocode_id': widget.ordrePromoCode,
        'payment_token': strPaymentToken,
        'vendor_discount_price': widget.vendorDiscountAmount != 0
            ? widget.vendorDiscountAmount.toString()
            : '',
        'vendor_discount_id': widget.vendorDiscountId != 0
            ? widget.vendorDiscountId.toString()
            : '',
        // 'tax': widget.strTaxAmount,
        'tax': json.encode(widget.allTax).toString(),
      };
      response  = await RestClient(RetroApi().dioData()).bookOrder(body);
      Constants.hideDialog(context);
      print(response);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        _deleteTable();
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
        strPaymentToken = '';
        Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OrderHistoryScreen(
                isFromProfile: false,
              ),
            ),
                (Route<dynamic> route) => true);
      } else {
       if(response.data != null) {
          Constants.toastMessage(response.data!);
        }else{
          Constants.toastMessage('Error while place order.');
        }
      }

    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<BaseModel<CommenRes>> getWalletBalance() async {
    CommenRes response;
    try{
      Constants.onLoading(context);
      response  = await RestClient(RetroApi().dioData()).getWalletBalance();
      Constants.hideDialog(context);
      if(widget.orderAmount! > int.parse(response.data!)){
        Constants.toastMessage('Not Enough money in wallet please add first');
      }else{
        placeOrder();
      }
    }catch (error, stacktrace) {
     Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

}
