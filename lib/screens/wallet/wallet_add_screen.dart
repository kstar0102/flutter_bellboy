import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/wallet/wallet_payment_method_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class WalletAddScreen extends StatefulWidget {
  @override
  _WalletAddScreenState createState() => _WalletAddScreenState();
}

class _WalletAddScreenState extends State<WalletAddScreen> {
  bool _isSyncing = false;
  String? balance = '';
  TextEditingController amountController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = '';
    Constants.checkNetwork().whenComplete(() => getWalletBalance());
  }

  /*void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => getWalletBalance());
    if (mounted) setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(appbarTitle: '' //Languages.of(context).walletSetting,
            ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ModalProgressHUD(
                      inAsyncCall: _isSyncing,
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      Languages.of(context)!.mealUpWallet,
                                      style: TextStyle(
                                          color: Constants.colorBlack,
                                          fontFamily: Constants.appFontBold,
                                          fontSize: 22),
                                    ),
                                    Text(
                                      "${Languages.of(context)!.availableMealUpBalance} ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} $balance",
                                      style: TextStyle(
                                          color: Constants.colorBlack,
                                          fontFamily: Constants.appFont,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Languages.of(context)!.addMoney,
                                          style: TextStyle(
                                              color: Constants.colorBlack,
                                              fontFamily: Constants.appFontBold,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        TextField(
                                          style: TextStyle(color: Colors.black, fontSize: 25),
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 1,
                                                style: BorderStyle.none,
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            hintText: Languages.of(context)!.enterAmount,
                                            hintStyle: TextStyle(
                                                color: Constants.colorGray,
                                                fontSize: 25,
                                                fontFamily: Constants.appFontBold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Center(
                                          child: Text(
                                            Languages.of(context)!.moneyWillBeAddedToMealUpWallet,
                                            style: TextStyle(
                                                color: Constants.colorBlack,
                                                fontFamily: Constants.appFont,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: RawMaterialButton(
                                  onPressed: () {
                                    if (amountController.text.toString().trim().isEmpty) {
                                      Constants.toastMessage('Enter amount');
                                    } else {
                                      Navigator.of(context).pushReplacement(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                          widget: WalletPaymentMethodScreen(
                                            orderAmount: amountController.text.toString(),
                                          ),
                                        ),
                                      );
                                      /*Map<String, String> body = {
                                            'amount': amountController.text.toString(),
                                            'payment_type': 'paypal',
                                            'payment_token': 'fff4f11f1f1',
                                          };
                                          addUserBalance(body);*/
                                    }
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.green,
                                  child: Text(
                                    'Process',
                                    style: TextStyle(
                                        color: Constants.colorWhite,
                                        fontFamily: Constants.appFontBold,
                                        fontSize: 20),
                                  ),
                                  splashColor: Colors.grey.withAlpha(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }

  Future<BaseModel<CommenRes>> addUserBalance(map) async {
    CommenRes response;
    try{
      setState(() {
        _isSyncing = true;
      });
      response  = await RestClient(RetroApi().dioData()).addBalance(map);
      setState(() {
        _isSyncing = false;
        Constants.toastMessage(response.data!);
        Navigator.of(context).pop({'selection': 'done'});
      });
    }catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> getWalletBalance() async {
    CommenRes response;
    try{
      setState(() {
        _isSyncing = true;
      });
      response  = await RestClient(RetroApi().dioData()).getWalletBalance();
      setState(() {
        _isSyncing = false;
        balance = response.data;
      });
    }catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
