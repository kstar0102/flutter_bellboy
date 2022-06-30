import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

class AboutApp extends StatefulWidget {
  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context)!.labelAboutApp,
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
                  ),
                  Image.asset(
                    'images/ic_intro_logo.png',
                    width: ScreenUtil().setWidth(140),
                    height: ScreenUtil().setHeight(50),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(15)),
                    child: Text(
                      '${Languages.of(context)!.labelVersion} ' +
                          SharedPreferenceUtil.getString(
                              Constants.appSettingAndroidCustomerVersion),
                      style: TextStyle(
                        color: Constants.colorGray,
                        fontFamily: Constants.appFont,
                        fontSize: ScreenUtil().setSp(12.0),
                      ),
                    ),
                  ),
                  Text(
                    '\u00a9 2020-2021 Mealup',
                    style: TextStyle(
                      color: Constants.colorGray,
                      fontFamily: Constants.appFont,
                      fontSize: ScreenUtil().setSp(16.0),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
