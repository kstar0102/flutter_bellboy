import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/screens/bottom_navigation/explore_screen.dart';
import 'package:mealup/screens/bottom_navigation/home_scree.dart';
import 'package:mealup/screens/bottom_navigation/my_cart_screen.dart';
import 'package:mealup/screens/bottom_navigation/profile_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

// ignore: must_be_immutable
class DashboardScreen extends StatefulWidget {
  int? _currentIndex;
  int? savePrevIndex;

  DashboardScreen(_currentIndex) {
    this._currentIndex = _currentIndex;
  }

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _children = [HomeScreen(), ExploreScreen(), MyCartScreen(), ProfileScreen()];

  // ignore: missing_return
  Future<bool> _onWillPop() {
    Future<bool> value  = Future.value(false);
    setState(() {
      if (widget._currentIndex != 0) {
        /*if (widget._currentIndex == widget.savePrevIndex) {
          value  = Future.value(false);
          widget._currentIndex =  widget._currentIndex! - 1;
          setState(() {});
        } else if (widget.savePrevIndex != null) {
          value  = Future.value(false);
          widget._currentIndex = widget.savePrevIndex;
          setState(() {});
        } else {*/
          value  = Future.value(false);
          widget._currentIndex = 0;
          setState(() {});
       // }
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text(Languages.of(context)!.labelConfirmExit),
                content: Text(Languages.of(context)!.labelAreYouSureExit),
                actions: <Widget>[
                  TextButton(
                    child: Text(Languages.of(context)!.labelYES, style: TextStyle(color: Colors.black),),
                    onPressed: () {
                      value  = Future.value(false);
                      SystemNavigator.pop();
                    },
                  ),
                  TextButton(
                    child: Text(Languages.of(context)!.labelNO, style: TextStyle(color: Colors.black),),
                    onPressed: () {
                      Navigator.of(context).pop();
                      value  = Future.value(true);
                    },
                  )
                ],
              );
            });
      }
    });
    return value;
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690), orientation: Orientation.portrait);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _children[widget._currentIndex!],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Constants.colorTheme,
            selectedItemColor: Colors.black,
            unselectedItemColor: Constants.colorWhite,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: widget._currentIndex!,
            onTap: (value) {
              print(value);
              setState(() {
                widget.savePrevIndex = widget._currentIndex;
                widget._currentIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_home.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Constants.colorWhite,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_home.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                label: Languages.of(context)!.labelHome,

              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_explore.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Constants.colorWhite,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_explore.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                label: Languages.of(context)!.labelExplore
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_cart.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Constants.colorWhite,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_cart.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                label: Languages.of(context)!.labelCart
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: ScreenUtil().setHeight(25),
                  height: ScreenUtil().setHeight(25),
                  decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: new NetworkImage(
                          SharedPreferenceUtil.getString(Constants.loginUserImage)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                    border: new Border.all(
                      color: Constants.colorWhite,
                      width: 2.0,
                    ),
                  ),
                ),
                activeIcon: Container(
                  width: ScreenUtil().setHeight(25),
                  height: ScreenUtil().setHeight(25),
                  decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: new NetworkImage(
                          SharedPreferenceUtil.getString(Constants.loginUserImage)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                  ),
                ),
                label:Languages.of(context)!.labelProfile
              ),
            ]),
      ),
    );
  }
}
