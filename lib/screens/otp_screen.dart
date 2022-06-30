import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/check_opt_model.dart';
import 'package:mealup/model/check_otp_model_for_forgot_password.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';

import 'auth/change_password_1.dart';

class OTPScreen extends StatefulWidget {
  final bool isFromRegistration;
  final String? emailForOTP;

  const OTPScreen(
      {Key? key, required this.isFromRegistration, this.emailForOTP})
      : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  int _start = 60;
  late Timer _timer;

  int? getOTP;


  @override
  void initState() {
    super.initState();
    startTimer();
    _focusNode.addListener(() {
      print("Has focus: ${_focusNode.hasFocus}");
    });

    getOTP = SharedPreferenceUtil.getInt(Constants.registrationOTP);

  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: screenWidth,
            maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(appbarTitle: Languages.of(context)!.labelOTP),
        backgroundColor: Color(0xFFF9F9F9),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HeroImage(),
                      Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                        child: Image.asset(
                          'images/ic_otp.png',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            right: ScreenUtil().setWidth(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppLableWidget(
                                  title: Languages.of(context)!.labelEnterOTP,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: ScreenUtil().setWidth(30)),
                                  child: Text(
                                    '00 : $_start',
                                    style: TextStyle(
                                        fontFamily: Constants.appFont),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                OTPTextField(
                                  editingController: textEditingController1,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTPTextField(
                                  editingController: textEditingController2,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTPTextField(
                                  editingController: textEditingController3,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTPTextField(
                                  editingController: textEditingController4,
                                  textInputAction: TextInputAction.done,
                                  focus: (v) {
                                    FocusScope.of(context).dispose();
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(20),
                            ),
                            RoundedCornerAppButton(
                                btnLabel: Languages.of(context)!.labelVerifyNow,
                                onPressed: () {
                                  String one = textEditingController1.text +
                                      textEditingController2.text +
                                      textEditingController3.text +
                                      textEditingController4.text;
                                  //int enteredOTP = int.parse(one);
                                  print(one);
                                  if(one.length == 4) {
                                    if (widget.isFromRegistration) {
                                      // if(enteredOTP == getOTP){
                                      //if (one == '0000') {
                                      callVerifyOTP(one);
                                      // }
                                    } else {
                                      // if (one == '0000') {
                                      callForgotPasswordVerifyOTP(one);
                                      // }
                                    }
                                  }else{
                                    Constants.toastMessage('Enter OTP');
                                  }
                                }),
                            SizedBox(
                              height: ScreenUtil().setHeight(15),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Languages.of(context)!.labelDontReceiveCode,
                                  style:
                                      TextStyle(fontFamily: Constants.appFont),
                                ),
                                InkWell(
                                  onTap: () {
                                    callSendOTP();
                                  },
                                  child: Text(
                                    Languages.of(context)!.labelResendAgain,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.appFont),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(25)),
                        child: Text(
                          Languages.of(context)!.labelOTPBottomLine,
                          style: TextStyle(
                            color: Constants.colorGray,
                            fontSize: ScreenUtil().setSp(10),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try{
      Constants.onLoading(context);
      Map<String, String?> body ;
      if(widget.isFromRegistration){
        body = {
          'email_id': widget.emailForOTP,
          'where': 'register',
        };
      }else{
        body = {
          'email_id': widget.emailForOTP,
          'where': 'forgot_password',
        };
      }
      response  = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage('OTP Sent');

        SharedPreferenceUtil.putString(
            Constants.loginUserId, response.data!.id.toString());
      } else {
        Constants.toastMessage('Error while sending OTP.');
      }
    }catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CheckOTPModel>> callVerifyOTP(String enteredOTP) async {
    CheckOTPModel response;
    try{
      print('=======' + SharedPreferenceUtil.getString('userId'));
      print(enteredOTP);

      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.registrationUserId),
        'otp': enteredOTP,
        'where': 'register',
      };
      response  = await RestClient(RetroApi().dioData()).checkOtp(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.msg!);
        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: LoginScreen(),
          ),
        );
      } else {
        Constants.toastMessage(response.msg!);
      }
    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CheckOTPForForgotPasswordModel>> callForgotPasswordVerifyOTP(String enteredOTP) async {
    CheckOTPForForgotPasswordModel response;
    try{
      print('=======' + SharedPreferenceUtil.getString('userId'));
      print(enteredOTP);

      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
        'otp': enteredOTP,
        'where': 'change_password',
      };
      response  = await RestClient(RetroApi().dioData()).checkOtpForForgotPassword(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.msg!);

        Navigator.of(context).push(Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ChangePassword1()));
      } else {
        Constants.toastMessage(response.msg!);
      }
    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

}

// ignore: must_be_immutable
class OTPTextField extends StatelessWidget {
  TextEditingController editingController = TextEditingController();
  TextInputAction textInputAction;
  Function focus;

  OTPTextField(
      {required this.editingController,
      required this.textInputAction,
      required this.focus});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        width: ScreenUtil().setWidth(30),
        height: ScreenUtil().setHeight(70),
        margin: EdgeInsets.all(2.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2.0,
          child: Center(
            child: TextFormField(
              onFieldSubmitted: focus as void Function(String)?,
              controller: editingController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: textInputAction,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (str) {
                if (str.length == 1) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).previousFocus();
                }
              },
              style: TextStyle(
                  fontFamily: Constants.appFont,
                  fontSize: ScreenUtil().setSp(25),
                  color: Constants.colorGray),
              decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Constants.colorHint,
                  ),
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
    );
  }
}
