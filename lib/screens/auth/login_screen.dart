import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/login_model.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/change_password.dart';
import 'package:mealup/screens/auth/create_new_account.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../otp_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRememberMe = false;
  bool _passwordVisible = true;

  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  String provider = 'LOCAL';

  //bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }
    callAppSettingData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<BaseModel<AppSettingModel>> callAppSettingData() async {
    AppSettingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).setting();
      print(response.success);
      print('businessAvailability' + response.data!.businessAvailability.toString());

      if (response.success!) {
        if (response.data!.currencySymbol != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrencySymbol, response.data!.currencySymbol!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, '\$');
        }
        if (response.data!.currency != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, response.data!.currency!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }

        if (response.data!.termsAndCondition != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingTerm, response.data!.termsAndCondition!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
        }

        if (response.data!.help != null) {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, response.data!.help!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
        }

        if (response.data!.privacyPolicy != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingPrivacyPolicy, response.data!.privacyPolicy!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
        }

        if (response.data!.companyDetails != null) {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, response.data!.companyDetails!);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }
        if (response.data!.driverAutoRefrese != null) {
          SharedPreferenceUtil.putInt(
              Constants.appSettingDriverAutoRefresh, response.data!.driverAutoRefrese);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data!.isPickup != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, response.data!.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data!.customerAppId != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCustomerAppId, response.data!.customerAppId!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        if (response.data!.androidCustomerVersion != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAndroidCustomerVersion, response.data!.androidCustomerVersion!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAndroidCustomerVersion, '');
        }

        SharedPreferenceUtil.putInt(
            Constants.appSettingBusinessAvailability, response.data!.businessAvailability);

        if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 0) {
          SharedPreferenceUtil.putString(
              Constants.appSettingBusinessMessage, response.data!.message!);
        }

        if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
          getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
        }
      } else {
        Constants.toastMessage('Error while get app setting data.');
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                child: Image.asset(
                  'images/ic_login_page.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Scaffold(
              primary: true,
              //backgroundColor: Color(0xFFFAFAFA),
              backgroundColor: Colors.transparent,
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: ListView.builder(
                      itemCount: 1,
                      shrinkWrap: false,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(Transitions(
                                    transitionType: TransitionType.slideUp,
                                    curve: Curves.bounceInOut,
                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                    widget: DashboardScreen(0)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      Languages.of(context)!.labelSkipNow,
                                      style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        decorationThickness: 2,
                                        fontSize: ScreenUtil().setSp(16),
                                        fontFamily: Constants.appFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            HeroImage(),
                            SizedBox(height: 20),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AppLableWidget(
                                      title: Languages.of(context)!.labelEmail,
                                    ),
                                    CardTextFieldWidget(
                                      focus: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      textInputAction: TextInputAction.next,
                                      hintText: Languages.of(context)!.labelEnterYourEmailID,
                                      textInputType: TextInputType.emailAddress,
                                      textEditingController: _textEmail,
                                      validator: kvalidateEmail,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppLableWidget(
                                          title: Languages.of(context)!.labelPassword,
                                        ),
                                      ],
                                    ),
                                    CardPasswordTextFieldWidget(
                                        textEditingController: _textPassword,
                                        validator: kvalidatePassword,
                                        hintText: Languages.of(context)!.labelEnterYourPassword,
                                        isPasswordVisible: _passwordVisible),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        /* Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: ClipRRect(
                                                clipBehavior: Clip.hardEdge,
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                child: SizedBox(
                                                  width: 40.0,
                                                  height: ScreenUtil().setHeight(40),
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    child: Container(
                                                      child: Theme(
                                                        data: ThemeData(
                                                          unselectedWidgetColor: Colors.transparent,
                                                        ),
                                                        child: Checkbox(
                                                          value: isRememberMe,
                                                          onChanged: (state) =>
                                                              setState(() => isRememberMe = !isRememberMe),
                                                          activeColor: Colors.transparent,
                                                          checkColor: Color(Constants.colorTheme),
                                                          materialTapTargetSize: MaterialTapTargetSize.padded,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Languages.of(context)!.labelRememberMe,
                                              style: TextStyle(fontSize: 14.0, fontFamily: Constants.appFont),
                                            ),
                                          ],
                                        ),*/
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(Transitions(
                                                  transitionType: TransitionType.fade,
                                                  curve: Curves.bounceInOut,
                                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                  widget: ChangePassword()));
                                            },
                                            child: Text(
                                              Languages.of(context)!.labelForgotPassword,
                                              style: TextStyle(
                                                fontFamily: Constants.appFontBold,
                                                fontSize: ScreenUtil().setSp(16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 20.0, right: 20, top: 10, bottom: 10),
                                      child: RoundedCornerAppButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            // if (SharedPreferenceUtil.getString(
                                            //         Constants
                                            //             .appPush_oneSingleToken)
                                            //     .isEmpty) {
                                            //   getOneSingleToken(SharedPreferenceUtil
                                            //       .getString(Constants
                                            //           .appSettingCustomerAppId));
                                            // } else {
                                            // }
                                            Constants.checkNetwork()
                                                .whenComplete(() => callUserLogin());
                                          } else {
                                            setState(() {
                                              // validation error
                                              //_autoValidate = true;
                                            });
                                          }
                                        },
                                        btnLabel: Languages.of(context)!.labelLogin,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(Transitions(
                                            transitionType: TransitionType.slideUp,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: CreateNewAccount()));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            Languages.of(context)!.labelDonthaveAcc,
                                            style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              fontSize: ScreenUtil().setSp(14),
                                            ),
                                          ),
                                          Text(
                                            Languages.of(context)!.labelCreateNow,
                                            style: TextStyle(
                                              fontFamily: Constants.appFontBold,
                                              fontSize: ScreenUtil().setSp(16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? kvalidateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.labelEmailRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelEnterValidEmail;
    else
      return null;
  }

  String? kvalidatePassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelPasswordValidation;
    else
      return null;
  }

  getOneSingleToken(String appId) async {
    // String push_token = '';
    // String userId = '';
    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/

    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    //var status = await OneSignal.shared.getDeviceState();
    await OneSignal.shared.getDeviceState().then(
        (value) => SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, value!.userId!));
    print("pushtoken1:${SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)}");
    // var pushtoken = await status.subscriptionStatus.pushToken;
    // userId = status.userId;
    //print("pushtoken1:$userId");
    // print("pushtoken123456:$pushtoken");
    // push_token = pushtoken;
    //  userId == null ? userId = '' : userId = status.userId;
    //  SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId);

    /* if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  Future<BaseModel<LoginModel>> callUserLogin() async {
    LoginModel response;
    try {
      Constants.onLoading(context);

      Map<String, String> body = {
        'email_id': _textEmail.text,
        'password': _textPassword.text,
        'provider': provider,
        'device_token': SharedPreferenceUtil.getString(Constants.appPushOneSingleToken),
      };

      response = await RestClient(RetroApi().dioData()).userLogin(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        if (response.data!.isVerified == 1) {
          Constants.toastMessage(Languages.of(context)!.labelLoginSuccessfully);
          response.data!.otp == null
              ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0)
              : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data!.otp);
          SharedPreferenceUtil.putString(Constants.loginEmail, response.data!.emailId!);
          SharedPreferenceUtil.putString(Constants.loginPhone, response.data!.phone!);
          if (response.data!.phoneCode != null) {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, response.data!.phoneCode!);
          } else {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, '+91');
          }
          SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
          SharedPreferenceUtil.putString(Constants.headerToken, response.data!.token!);
          SharedPreferenceUtil.putString(Constants.loginUserImage, response.data!.image!);
          SharedPreferenceUtil.putString(Constants.loginUserName, response.data!.name!);

          response.data!.ifscCode == null
              ? SharedPreferenceUtil.putString(Constants.bankIFSC, '')
              : SharedPreferenceUtil.putString(Constants.bankIFSC, response.data!.ifscCode!);
          response.data!.micrCode == null
              ? SharedPreferenceUtil.putString(Constants.bankMICR, '')
              : SharedPreferenceUtil.putString(Constants.bankMICR, response.data!.micrCode!);
          response.data!.accountName == null
              ? SharedPreferenceUtil.putString(Constants.bankACCName, '')
              : SharedPreferenceUtil.putString(Constants.bankACCName, response.data!.accountName!);
          response.data!.accountNumber == null
              ? SharedPreferenceUtil.putString(Constants.bankACCNumber, '')
              : SharedPreferenceUtil.putString(
                  Constants.bankACCNumber, response.data!.accountNumber!);

          SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

          String languageCode = '';
          if (response.data!.language == 'english') {
            languageCode = 'en';
          } else if (response.data!.language == 'arabic') {
            languageCode = 'ar';
          } else {
            languageCode = 'en';
          }

          changeLanguage(context, languageCode);

          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: DashboardScreen(0),
            ),
          );
        } else {
          callSendOTP();
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'email_id': _textEmail.text,
        'where': 'register',
      };
      response = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        //Constants.toastMessage('OTP Sent');
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: true,
              emailForOTP: _textEmail.text,
            ),
          ),
        );
      } else {
        Constants.toastMessage(response.msg.toString());
      }
    } catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

/*  void callUserLogin() {


    Map<String, String> body = {
      'email_id': _textEmail.text,
      'password': _textPassword.text,
      'provider': 'LOCAL',
      'device_token': SharedPreferenceUtil.getString(Constants.appPushOneSingleToken),
    };
    RestClient(RetroApi().dioData()).userLogin(body).then((response) {
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(Languages.of(context)!.labelLoginSuccessfully);
        response.data!.otp == null
            ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0)
            : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data!.otp);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.data!.emailId!);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.data!.phone!);
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        SharedPreferenceUtil.putString(Constants.headerToken, response.data!.token!);
        SharedPreferenceUtil.putString(Constants.loginUserImage, response.data!.image!);
        SharedPreferenceUtil.putString(Constants.loginUserName, response.data!.name!);

        response.data!.ifscCode == null
            ? SharedPreferenceUtil.putString(Constants.bankIFSC, '')
            : SharedPreferenceUtil.putString(Constants.bankIFSC, response.data!.ifscCode!);
        response.data!.micrCode == null
            ? SharedPreferenceUtil.putString(Constants.bankMICR, '')
            : SharedPreferenceUtil.putString(Constants.bankMICR, response.data!.micrCode!);
        response.data!.accountName == null
            ? SharedPreferenceUtil.putString(Constants.bankACCName, '')
            : SharedPreferenceUtil.putString(Constants.bankACCName, response.data!.accountName!);
        response.data!.accountNumber == null
            ? SharedPreferenceUtil.putString(Constants.bankACCNumber, '')
            : SharedPreferenceUtil.putString(
                Constants.bankACCNumber, response.data!.accountNumber!);

        SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

        String languageCode = '';
        if (response.data!.language == 'english') {
          languageCode = 'en';
        } else {
          languageCode = 'es';
        }

        changeLanguage(context, languageCode);

        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: DashboardScreen(0),
          ),
        );
      } else {
        Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
      }
    }).catchError((Object obj) {
      Constants.hideDialog(context);
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage("code:$responsecode");
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(Languages.of(context)!.labelInternalServerError);
          }
          break;
        default:
      }
    });
  }*/
}
