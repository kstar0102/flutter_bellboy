import 'package:flutter/material.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/preference_utils.dart';

import 'intro_screen3.dart';

class IntroScreen2 extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:  Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/ic_background_image.png'),
    fit: BoxFit.cover,)
    ),
    alignment: Alignment.center,
    child:
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Hero(
                    tag: 'App_logo',
                    child: Image.asset('images/ic_intro_logo.png',
                      width: 140.0,
                      height: 40,),
                  ),
                ),
                Image.asset('images/ic_intro2.png'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          Languages.of(context)!.labelScreenIntro2Line1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Constants.appFont,
                            color: Constants.colorBlack,
                            fontSize: 25.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            Languages.of(context)!.labelScreenIntro2Line2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Constants.colorGray,
                                fontFamily: Constants.appFont,
                                fontSize: 16.0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        color: Constants.colorTheme,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      onTap: (){
                        PreferenceUtils.setisIntroDone("isIntroDone", true);
                        Navigator.of(context).pushAndRemoveUntil(
                            Transitions(
                              transitionType: TransitionType.fade,
                              curve: Curves.bounceInOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                              widget: DashboardScreen(0),
                            ),
                                (Route<dynamic> route) => false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          Languages.of(context)!.labelSkip,
                          style: TextStyle(
                              letterSpacing: 3.0,
                              color: Constants.colorTheme,
                              fontFamily: Constants.appFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Constants.colorTheme,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            Transitions(
                                transitionType: TransitionType.slideUp,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: IntroScreen3())
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}


class SlideRightRoute extends PageRouteBuilder {
  final Widget? page;
  SlideRightRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page!,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}
