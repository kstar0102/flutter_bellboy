import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';


class SetLocationScreen extends StatefulWidget {
  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
 // final _controller = TextEditingController();

  // String _streetNumber = '';
  // String _street = '';
  // String _city = '';
  // String _zipCode = '';


  List<UserAddressListData> _userAddressList = [];

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
  }

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try{
      Constants.onLoading(context);
      _userAddressList.clear();
      response  = await  RestClient(RetroApi().dioData()).userAddress();
      print(response.success);
        Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _userAddressList.addAll(response.data!);
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }

    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
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
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context)!.labelSetLocation,
        ),
        body: Container(
          margin: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(30),
                            top: ScreenUtil().setHeight(5),
                            bottom: ScreenUtil().setHeight(5)),
                        child: Text(
                          Languages.of(context)!.labelSavedAddress,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(14),
                              fontFamily: Constants.appFontBold),
                        ),
                      ),
                      _userAddressList.length == 0
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setHeight(100),
                                    image: AssetImage('images/ic_no_rest.png'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(10)),
                                    child: Text(
                                      'No Data Available. \n Please Add Address.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(18),
                                        fontFamily: Constants.appFontBold,
                                        color: Constants.colorTheme,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _userAddressList.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  SharedPreferenceUtil.putString('selectedLat',
                                      _userAddressList[index].lat!);
                                  SharedPreferenceUtil.putString('selectedLng',
                                      _userAddressList[index].lang!);
                                  SharedPreferenceUtil.putString(
                                      Constants.selectedAddress,
                                      _userAddressList[index].address!);
                                  SharedPreferenceUtil.putInt(
                                      Constants.selectedAddressId,
                                      _userAddressList[index].id);
                                  Navigator.of(context).push(Transitions(
                                      transitionType: TransitionType.slideUp,
                                      curve: Curves.bounceInOut,
                                      reverseCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                      widget: DashboardScreen(0)));
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 30, bottom: 8),
                                      child: Text(
                                        _userAddressList[index].type != null
                                            ? _userAddressList[index].type!
                                            : '',
                                        style: TextStyle(
                                            fontFamily: Constants.appFontBold,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'images/ic_map.svg',
                                          width: 18,
                                          height: 18,
                                          color: Constants.colorTheme,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, top: 2),
                                            child: Text(
                                              _userAddressList[index].address!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily:
                                                      Constants.appFont,
                                                  color: Constants.colorBlack),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Color(0xffcccccc),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
