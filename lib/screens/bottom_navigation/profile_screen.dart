import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:share/share.dart';
import '../setting_screen.dart';
import '../your_favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
      Future.delayed(
        Duration(seconds: 0),
        () => Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
            (Route<dynamic> route) => false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Constants.colorBlack),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(Languages.of(context)!.labelProfile,
                style: TextStyle(
                  color: Constants.colorBlack,
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                    fontFamily: Constants.appFontBold)),
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
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              // loginUserImage
                              ClipOval(
                                child: CachedNetworkImage(
                                  width: 100,
                                  height: 100,
                                  imageUrl: SharedPreferenceUtil.getString(
                                      Constants.loginUserImage),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  SharedPreferenceUtil.getString(
                                      Constants.loginUserName),
                                  style: TextStyle(
                                      fontFamily: Constants.appFontBold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                    fontFamily: Constants.appFont,
                                    fontSize: 12,
                                    color: Constants.colorGray),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            child: Column(
                              children: [
                                Visibility(
                                  visible: SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1'? true :true,
                                  child: ProfileMenuWidget(
                                    strImagePath: 'images/wallet.svg',
                                    strMenuName: Languages.of(context)!.walletSetting,
                                    onClick: () {
                                      Navigator.of(context).push(Transitions(
                                          transitionType: TransitionType.slideUp,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                          widget: WalletScreen()));
                                    },
                                  ),
                                ),
                                ProfileMenuWidget(
                                  strImagePath: 'images/ic_settings.svg',
                                  strMenuName:
                                      Languages.of(context)!.screenSetting,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: SettingScreen()));
                                  },
                                ),
                                ProfileMenuWidget(
                                  strImagePath: 'images/ic_heart.svg',
                                  strMenuName:
                                      Languages.of(context)!.labelYourFavorites,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: YourFavoritesScreen()));
                                  },
                                ),
                                ProfileMenuWidget(
                                  strImagePath: 'images/ic_clock.svg',
                                  strMenuName:
                                      Languages.of(context)!.labelOrderHistory,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: OrderHistoryScreen(
                                          isFromProfile: true,
                                        )));
                                  },
                                ),
                                ProfileMenuWidget(
                                  strImagePath: 'images/ic_share.svg',
                                  strMenuName: Languages.of(context)!.labelShareWithFriends,
                                  onClick: () async{
                                    //TODO : Dynamic remaining
                                    if (Platform.isAndroid) {
                                      Share.share('https://play.google.com/store/apps/details?id=app.juanmyfood');
                                    } else if (Platform.isIOS) {
                                      Share.share('https://play.google.com/store/apps/details?id=app.juanmyfood');
                                    }
                                  },
                                ),
                                ProfileMenuWidget(
                                  strImagePath: 'images/logout.svg',
                                  strMenuName: Languages.of(context)!.labelLogout,
                                  onClick: () {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(Languages.of(context)!.labelConfirmLogout),
                                            content: Text(Languages.of(context)!.labelAreYouSureLogout),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(Languages.of(context)!.labelYES, style: TextStyle(color: Constants.colorBlack),),
                                                onPressed: () {
                                                  SharedPreferenceUtil.putBool(Constants.isLoggedIn, false);
                                                  SharedPreferenceUtil.clear();
                                                  Navigator.of(context).pushAndRemoveUntil(Transitions(
                                                    transitionType: TransitionType.fade,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                    widget: LoginScreen(),
                                                  ), (Route<dynamic> route) => false);
                                                },
                                              ),
                                              TextButton(
                                                child: Text(Languages.of(context)!.labelNO, style: TextStyle(color: Constants.colorBlack),),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });

                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

// ignore: must_be_immutable
class ProfileMenuWidget extends StatelessWidget {
  Function onClick;
  String strImagePath, strMenuName;

  ProfileMenuWidget(
      {required this.onClick,
      required this.strImagePath,
      required this.strMenuName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick as void Function()?,
      child: Container(
        height: 60,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: SvgPicture.asset(
                strImagePath,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Text(
                        strMenuName,
                        style: TextStyle(
                            fontSize: 16, fontFamily: Constants.appFont),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: DottedLine(
                        direction: Axis.horizontal,
                        dashColor: Color(0xff969696),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
