import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripeLib;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/payment_setting_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/wallet/WalletPaypalPayment.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/screens/wallet/wallet_stripe.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
//TODO:ios build change
// import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletPaymentMethodScreen extends StatefulWidget {
  final orderAmount;
  const WalletPaymentMethodScreen({
    Key? key,
    this.orderAmount,
  }) : super(key: key);

  @override
  _WalletPaymentMethodScreenState createState() =>
      _WalletPaymentMethodScreenState();
}

// enum PaymentMethod { paypal, rozarpay, stripe, cashOnDelivery }

class _WalletPaymentMethodScreenState extends State<WalletPaymentMethodScreen> {
  int radioindex = -1;
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
    try {
      final dio = Dio();
      dio.options.headers["Accept"] =
          "application/json"; // config your dio headers globally// config your dio headers globally
      dio.options.followRedirects = false;
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;
      response = await RestClient(dio).paymentSetting();
      print(response.success);

      if (response.success!) {
        if (mounted)
          setState(() {
            SharedPreferenceUtil.putString(
                Constants.appPaymentCOD, response.data!.cod.toString());
            if (response.data!.wallet != null) {
              SharedPreferenceUtil.putString(
                  Constants.appPaymentWallet, response.data!.wallet.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentWallet, '0');
            }
            if (response.data!.stripe != null) {
              SharedPreferenceUtil.putString(
                  Constants.appPaymentStripe, response.data!.stripe.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentStripe, '0');
            }
            if (response.data!.razorpay != null) {
              SharedPreferenceUtil.putString(Constants.appPaymentRozerPay,
                  response.data!.razorpay.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentRozerPay, '0');
            }

            if (response.data!.paypal != null) {
              SharedPreferenceUtil.putString(
                  Constants.appPaymentPaypal, response.data!.paypal.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentPaypal, '0');
            }

            if (response.data!.stripePublishKey != null) {
              SharedPreferenceUtil.putString(Constants.appStripePublishKey,
                  response.data!.stripePublishKey.toString());
            } else {
              SharedPreferenceUtil.putString(
                  Constants.appStripePublishKey, '0');
            }

            if (response.data!.stripeSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey,
                  response.data!.stripeSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey, '0');
            }

            if (response.data!.paypalProduction != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalProduction,
                  response.data!.paypalProduction.toString());
            } else {
              SharedPreferenceUtil.putString(
                  Constants.appPaypalProduction, '0');
            }

            if (response.data!.stripeSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox,
                  response.data!.stripeSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox, '0');
            }

            if (response.data!.paypalClientId != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalClientId,
                  response.data!.paypalClientId.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalClientId, '0');
            }
            if (response.data!.paypalSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey,
                  response.data!.paypalSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey, '0');
            }

            if (response.data!.razorpayPublishKey != null) {
              SharedPreferenceUtil.putString(Constants.appRozerpayPublishKey,
                  response.data!.razorpayPublishKey.toString());
            } else {
              SharedPreferenceUtil.putString(
                  Constants.appRozerpayPublishKey, '0');
            }
          });
        /*if (SharedPreferenceUtil.getString(Constants.appPaymentCOD) == '1') {
          listPayment.add(0);
          listPaymentName.add('Cash on Delivery');
          listPaymentImage.add('images/cod.svg');
        } else {
          listPayment.remove(0);
          listPaymentName.remove('Cash on Delivery');
          listPaymentImage.remove('images/code.svg');
        }*/

        /* if (SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1') {
          listPayment.add(1);
          listPaymentName.add('MealUp Wallet');
          listPaymentImage.add('images/wallet.svg');
        } else {
          listPayment.remove(1);
          listPaymentName.remove('MealUp Wallet');
          listPaymentImage.remove('images/wallet.svg');
        }*/

        if (SharedPreferenceUtil.getString(Constants.appPaymentStripe) == '1') {
          listPayment.add(0);
          listPaymentName.add('Stripe');
          listPaymentImage.add('images/ic_stripe.svg');
        } else {
          listPayment.remove(0);
          listPaymentName.remove('Stripe');
          listPaymentImage.remove('images/ic_stripe.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentRozerPay) ==
            '1') {
          listPayment.add(1);
          listPaymentName.add('Rozerpay');
          listPaymentImage.add('images/ic_rozar_pay.svg');
        } else {
          listPayment.remove(1);
          listPaymentName.remove('Rozerpay');
          listPaymentImage.add('images/ic_rozar_pay.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentPaypal) == '1') {
          listPayment.add(2);
          listPaymentName.add('PayPal');
          listPaymentImage.add('images/ic_paypal.svg');
        } else {
          listPayment.remove(2);
          listPaymentName.remove('PayPal');
          listPaymentImage.remove('images/ic_paypal.svg');
        }

        print('listPayment' + listPayment.length.toString());
        stripeLib.Stripe.publishableKey =
            SharedPreferenceUtil.getString(Constants.appStripePublishKey);
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  void dispose() {
    super.dispose();
  }

//TODO:ios build change
  // void openCheckout() async {
  //   Razorpay _razorpay = Razorpay();
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  //   var options = {
  //     'key': SharedPreferenceUtil.getString(Constants.appRozerpayPublishKey),
  //     'amount': double.parse('${widget.orderAmount}')  * 100,
  //     'name': SharedPreferenceUtil.getString(Constants.loginUserName),
  //     'description': 'Payment',
  //     'prefill': {
  //       'contact': SharedPreferenceUtil.getString(Constants.loginPhone),
  //       'email': SharedPreferenceUtil.getString(Constants.loginEmail)
  //     },
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint('Error: e');
  //   }
  // }

//TODO:ios build change
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Constants.toastMessage("SUCCESS: " + response.paymentId!);
  //   addUserBalance(response.paymentId);
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Constants.toastMessage("ERROR: " + response.code.toString() + " - " + response.message!);
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Constants.toastMessage("EXTERNAL_WALLET: " + response.walletName!);

  // }

  Future<BaseModel<CommenRes>> addUserBalance(String? paymentId) async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body = {
        'amount': widget.orderAmount,
        'payment_type': 'RazorPay',
        'payment_token': paymentId,
      };
      response = await RestClient(RetroApi().dioData()).addBalance(body);
      setState(() {
        Constants.hideDialog(context);
        Constants.toastMessage(response.data!);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => WalletScreen(),
        ));
      });
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  Widget build(BuildContext context) {
    /*  progressDialog.style(
      message: Languages.of(context).labelPleaseWait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Constants.colorTheme),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
      messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
    );
*/
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
                              child: listPayment.length > 0
                                  ? ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: listPayment.length,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              Column(
                                        children: [
                                          customRadioList(
                                              listPaymentName[index],
                                              listPayment[index],
                                              listPaymentImage[index]),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(30)),
                                      child: Text(
                                        Languages.of(context)!.labelNoData,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(18),
                                          fontFamily: Constants.appFontBold,
                                          color: Constants.colorTheme,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: RoundedCornerAppButton(
                              onPressed: () {
                                if (orderPaymentType != null) {
                                  if (orderPaymentType == 'RAZOR') {
                                    //TODO:ios build change
                                    // openCheckout();
                                  } else if (orderPaymentType == 'STRIPE') {
                                    stripeSecretKey =
                                        SharedPreferenceUtil.getString(
                                            Constants.appStripeSecretKey);
                                    stripePublicKey =
                                        SharedPreferenceUtil.getString(
                                            Constants.appStripePublishKey);
                                    stripeLib.Stripe.publishableKey =
                                        SharedPreferenceUtil.getString(
                                            Constants.appStripePublishKey);
                                    Navigator.of(context).push(
                                      Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: WalletPaymentStripe(
                                          orderAmount: widget.orderAmount,
                                          // strTaxAmount: widget.strTaxAmount,
                                        ),
                                      ),
                                    );
                                  } else if (orderPaymentType == 'PAYPAL') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            WalletPaypalPayment(
                                          total: widget.orderAmount.toString(),
                                          onFinish: (number) async {
                                            // payment done
                                            print('order id: ' + number);
                                            if (number != null &&
                                                number.toString() != '') {
                                              strPaymentToken =
                                                  number.toString();
                                              // placeOrder();
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  Constants.toastMessage(Languages.of(context)!
                                      .labelPleaseSelectPaymentMethod);
                                }
                              },
                              btnLabel: Languages.of(context)!.topUpWallet,
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
      radioindex = index;
    });
  }

  Widget customRadioList(String title, int index, String icon) {
    return GestureDetector(
      onTap: () {
        changeIndex(index);
        if (index == 0) {
          orderPaymentType = 'STRIPE';
        } else if (index == 1) {
          orderPaymentType = 'RAZOR';
        } else if (index == 2) {
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
                    radioindex == index
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
}
