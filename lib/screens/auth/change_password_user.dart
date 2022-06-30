import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';


class ChangePasswordUser extends StatefulWidget {
  @override
  _ChangePasswordUserState createState() => _ChangePasswordUserState();
}

class _ChangePasswordUserState extends State<ChangePasswordUser> {
  bool _oldPasswordVisible = true;
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  final _oldTextPassword = TextEditingController();
  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
 // bool _autoValidate = false;



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
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context)!.labelChangePassword),
        backgroundColor: Color(0xFFFAFAFA),
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                          child: Image.asset(
                            'images/ic_lock.png',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right : 20,bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppLableWidget(
                                title: Languages.of(context)!.labelOldPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _oldTextPassword,
                                  validator: oValidatePassword,
                                  hintText: Languages.of(context)!.labelEnterOldPassword,
                                  isPasswordVisible: _oldPasswordVisible),
                              AppLableWidget(
                                title: Languages.of(context)!.labelNewPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _textPassword,
                                  validator: kValidatePassword,
                                  hintText: Languages.of(context)!
                                      .labelEnterNewPassword,
                                  isPasswordVisible: _passwordVisible),
                              AppLableWidget(
                                title:
                                    Languages.of(context)!.labelConfirmPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _textConfPassword,
                                  validator: validateConfPassword,
                                  hintText: Languages.of(context)!.labelReEnterNewPassword,
                                  isPasswordVisible: _confirmPasswordVisible),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: RoundedCornerAppButton(
                                  btnLabel:
                                      Languages.of(context)!.labelChangePassword,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      Constants.checkNetwork().whenComplete(
                                          () => callChangePassword());
                                    } else {
                                      setState(() {
                                        // validation error
                                       // _autoValidate = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? oValidatePassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelPasswordValidation;
    else
      return null;
  }

  String? kValidatePassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelPasswordValidation;
    else
      return null;
  }

  String? validateConfPassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (_textPassword.text != _textConfPassword.text)
      return Languages.of(context)!.labelPasswordConfPassNotMatch;
    else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelPasswordValidation;
    else
      return null;
  }

  Future<BaseModel<CommenRes>> callChangePassword() async {
    CommenRes response;
    try{
      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
        'old_password': _oldTextPassword.text,
        'password': _textPassword.text,
        'password_confirmation': _textConfPassword.text,
      };
      response  = await RestClient(RetroApi().dioData()).changePassword(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Navigator.pop(context);
        /*   Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
            (Route<dynamic> route) => false);*/
      } else {
        Constants.toastMessage(response.data!);
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
}
