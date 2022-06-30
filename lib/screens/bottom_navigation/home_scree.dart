import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/componants/custom_appbar.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/banner_response.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';
import 'package:mealup/model/nonVegRestaurantsModel.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/vegRestaurantsModel.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../auth/login_screen.dart';
import '../restaurants_details_screen.dart';
import '../search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AllCuisineData> _allCuisineListData = [];
  List<NearByRestaurantListData> _nearbyListData = [];
  List<VegRestaurantListData> _vegListData = [];
  List<TopRestaurantsListData> _topListData = [];
  List<NonVegRestaurantListData> _nonvegListData = [];
  List<ExploreRestaurantsListData> _exploreResListData = [];
  List<Data> banenrList = [];
  List<String?> restaurantsFood = [];
  List<String?> vegRestaurantsFood = [];
  List<String?> nonVegRestaurantsFood = [];
  List<String?> topRestaurantsFood = [];
  List<String?> exploreRestaurantsFood = [];

  late LatLng _center;
  bool _isSyncing = false;
  late Position currentLocation;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool isBusinessAvailable = false;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1) {
      getUserLocation();

      Constants.checkNetwork().whenComplete(() => callAllCuisine());
      Constants.checkNetwork().whenComplete(() => callVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callTopRestaurants());
      Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    } else {
      Constants.toastMessage('This is a testing app');
    }
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  var aspectRatio = 0.0;
  int _current = 0;

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getOneSingleToken(String appId) async {
    String? userId = '';
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
    var status = await OneSignal.shared.getDeviceState();
    // var pushtoken = await status.subscriptionStatus.pushToken;
    userId = status != null && status.userId != null ? status.userId : '';
    print("pushtoken1:$userId");
    userId != null ?SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId):SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, "");
    /* if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (mounted)
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    SharedPreferenceUtil.putString('selectedLat', _center.latitude.toString());
    SharedPreferenceUtil.putString('selectedLng', _center.longitude.toString());
    Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
    print('selectedLat ${_center.latitude}');
    print('selectedLng ${_center.longitude}');
  }

  @override
  void initState() {
    super.initState();
    SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1
        ? isBusinessAvailable = false
        : isBusinessAvailable = true;
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }

    if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1) {
      getUserLocation();

      Constants.checkNetwork().whenComplete(() => callAllCuisine());

      Constants.checkNetwork().whenComplete(() => callVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callTopRestaurants());
      Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
      Constants.checkNetwork().whenComplete(() => getBanners());
    } else {
      Constants.toastMessage('This is a testing app');
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690), orientation: Orientation.portrait);
    return SafeArea(
      child: Container(
        child: Scaffold(
          appBar: CustomAppbar(
            isFilter: false,
            onOfferTap: () {
              Navigator.of(context).push(Transitions(
                  transitionType: TransitionType.slideUp,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  widget: OfferScreen()));
            },
            onSearchTap: () {
              Navigator.of(context).push(Transitions(
                  transitionType: TransitionType.slideUp,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  widget: SearchScreen()));
            },
            onLocationTap: () {
              if (SharedPreferenceUtil.getBool(Constants.isLoggedIn) == true) {
                Navigator.of(context).push(Transitions(
                    transitionType: TransitionType.none,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                    widget: SetLocationScreen()));
              } else {
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
            },
            strSelectedAddress: SharedPreferenceUtil.getString(Constants.selectedAddress).isEmpty
                ? ''
                : SharedPreferenceUtil.getString(Constants.selectedAddress),
          ),
          body: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              backgroundColor: Constants.colorTheme,
              color: Constants.colorWhite,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ModalProgressHUD(
              inAsyncCall: _isSyncing,
              child: Container(
                decoration: BoxDecoration(
                    color: Constants.colorBackground,
                    image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Visibility(
                          visible: isBusinessAvailable,
                          child: Container(
                            margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                            decoration: new BoxDecoration(color: Constants.colorLikeLight),
                            child: ListTile(
                              leading: SvgPicture.asset(
                                'images/ic_information.svg',
                                width: ScreenUtil().setWidth(25),
                                height: ScreenUtil().setHeight(25),
                                color: Constants.colorLike,
                              ),
                              title: Transform(
                                transform: Matrix4.translationValues(-20, 0.0, 0.0),
                                child: Text(
                                  SharedPreferenceUtil.getString(
                                      Constants.appSettingBusinessMessage),
                                  style: TextStyle(
                                      color: Constants.colorLike,
                                      fontSize: ScreenUtil().setSp(14),
                                      fontFamily: Constants.appFontBold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            Languages.of(context)!.labelExploreTheBestCuisines,
                            style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                          ),
                        ),
                        _allCuisineListData.length == 0
                            ? !_isSyncing
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
                                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                          child: Text(
                                            Languages.of(context)!.labelNoData,
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
                                : Container(
                                    height: ScreenUtil().setHeight(147),
                                  )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                  height: ScreenUtil().setHeight(147),
                                  width: ScreenUtil().setWidth(114),
                                  child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _allCuisineListData.length,
                                    itemBuilder: (BuildContext context, int index) => Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(Transitions(
                                              transitionType: TransitionType.none,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: SingleCuisineDetailsScreen(
                                                cuisineId: _allCuisineListData[index].id,
                                                strCuisineName: _allCuisineListData[index].name,
                                              )));
                                        },
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15.0),
                                              child: CachedNetworkImage(
                                                height: 110,
                                                width: 110,
                                                imageUrl: _allCuisineListData[index].image!,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) => SpinKitFadingCircle(
                                                    color: Constants.colorTheme),
                                                errorWidget: (context, url, error) => Container(
                                                  child: Center(
                                                      child: Image.asset('images/noimage.png')),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(5),
                                                    right: ScreenUtil().setWidth(5),
                                                  ),
                                                  child: Text(
                                                    _allCuisineListData[index].name!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: ScreenUtil().setSp(16.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: banenrList.length > 0 ? true : false,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 0.8,
                              autoPlayAnimationDuration: const Duration(milliseconds: 200),
                              autoPlay: true,
                              enlargeCenterPage: true,
                              height: 150,
                              onPageChanged: (index, index1) {
                                setState(() {
                                  _current = index;
                                  print(_current);
                                });
                              },
                            ),
                            items: banenrList.map((it) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  it.image ?? '',
                                  fit: BoxFit.fill,
                                  height: 180,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                Languages.of(context)!.labelTopRestaurantsNear,
                                style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Constants.colorTheme,
                                ))
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: ScreenUtil().setHeight(220),
                          child: (() {
                            if (_nearbyListData.length == 0) {
                              return !_isSyncing
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
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context)!.labelNoRestNear,
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
                                  : Container();
                            } else {
                              return GridView.builder(
                                scrollDirection: Axis.horizontal,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: ScreenUtil().screenWidth / 1.1, // <== change the height to fit your needs
                                ),
                                itemCount: _nearbyListData.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    // height: ScreenUtil().setHeight(147),
                                    // width: ScreenUtil().setWidth(114),
                                    padding: EdgeInsets.only(left: 15, right: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          Transitions(
                                            transitionType: TransitionType.fade,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: RestaurantsDetailsScreen(
                                              restaurantId: _nearbyListData[index].id,
                                              isFav: _nearbyListData[index].like,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        margin: EdgeInsets.only(bottom: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  width: 100,
                                                  imageUrl: _nearbyListData[index].image!,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Constants.colorTheme),
                                                  errorWidget: (context, url, error) => Container(
                                                    child: Center(
                                                        child: Image.asset('images/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                                  width: ScreenUtil().screenWidth / 2,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.only(
                                                                left: 10, right: 10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    _nearbyListData[index].name!,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants.appFontBold,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil
                                                                        .getBool(
                                                                            Constants.isLoggedIn)) {
                                                                      Constants.checkNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(
                                                                                  _nearbyListData[
                                                                                          index]
                                                                                      .id));
                                                                    } else {
                                                                      Constants.toastMessage(Languages
                                                                              .of(context)!
                                                                          .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child: _nearbyListData[index]
                                                                          .like!
                                                                      ? SvgPicture.asset(
                                                                          'images/ic_filled_heart.svg',
                                                                          color:
                                                                              Constants.colorLike,
                                                                          width: 20,
                                                                        )
                                                                      : SvgPicture.asset(
                                                                          'images/ic_heart.svg',
                                                                          width: 20,
                                                                        ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(left: 10),
                                                              child: Text(
                                                                getRestaurantsFood(index),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontFamily: Constants.appFont,
                                                                    color: Constants.colorGray,
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.only(left: 8),
                                                            child: Row(
                                                              children: [
                                                                RatingBar.builder(
                                                                  initialRating:
                                                                      _nearbyListData[index]
                                                                          .rate
                                                                          .toDouble(),
                                                                  ignoreGestures: true,
                                                                  minRating: 1,
                                                                  direction: Axis.horizontal,
                                                                  itemSize:
                                                                      ScreenUtil().setWidth(12),
                                                                  allowHalfRating: true,
                                                                  itemBuilder: (context, _) => Icon(
                                                                    Icons.star,
                                                                    color: Colors.amber,
                                                                  ),
                                                                  onRatingUpdate: (double rating) {
                                                                    print(rating);
                                                                  },
                                                                ),
                                                                Text(
                                                                  '(${_nearbyListData[index].review})',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0),
                                                                    fontFamily: Constants.appFont,
                                                                    color: Color(0xFF132229),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.only(right: 10),
                                                            child: (() {
                                                              if (_nearbyListData[index]
                                                                      .vendorType ==
                                                                  'veg') {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                              right: 2),
                                                                      child: SvgPicture.asset(
                                                                        'images/ic_veg.svg',
                                                                        height: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                        width: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              } else if (_nearbyListData[index]
                                                                      .vendorType ==
                                                                  'non_veg') {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                              right: 2),
                                                                      child: SvgPicture.asset(
                                                                        'images/ic_non_veg.svg',
                                                                        height: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                        width: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              } else if (_nearbyListData[index]
                                                                      .vendorType ==
                                                                  'all') {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                              right: 2),
                                                                      child: SvgPicture.asset(
                                                                        'images/ic_veg.svg',
                                                                        height: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                        width: ScreenUtil()
                                                                            .setHeight(10.0),
                                                                      ),
                                                                    ),
                                                                    SvgPicture.asset(
                                                                      'images/ic_non_veg.svg',
                                                                      height: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                      width: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                    )
                                                                  ],
                                                                );
                                                              }
                                                            }()),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                Languages.of(context)!.labelTopRest,
                                style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Constants.colorTheme,
                                ))
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: ScreenUtil().setHeight(220),
                          child: _topListData.length == 0
                              ? !_isSyncing
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
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context)!.labelNoData,
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
                                  : Container()
                              : GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: ScreenUtil().screenWidth / 1.1,

                                  ),
                                  itemCount: _topListData.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              Transitions(
                                                transitionType: TransitionType.fade,
                                                curve: Curves.bounceInOut,
                                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                widget: RestaurantsDetailsScreen(
                                                  restaurantId: _topListData[index].id,
                                                  isFav: _topListData[index].like,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            margin: EdgeInsets.only(bottom: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    child: CachedNetworkImage(
                                                      width: 100,
                                                      height: 200,
                                                      imageUrl: _topListData[index].image!,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context, url) =>
                                                          SpinKitFadingCircle(
                                                              color: Constants.colorTheme),
                                                      errorWidget: (context, url, error) =>
                                                          Container(
                                                        child: Center(
                                                            child:
                                                                Image.asset('images/noimage.png')),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      width: ScreenUtil().screenWidth / 2,
                                                      child: Wrap(
                                                        alignment: WrapAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        _topListData[index].name!,
                                                                        maxLines: 1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.appFontBold,
                                                                            fontSize: ScreenUtil()
                                                                                .setSp(16.0)),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        if (SharedPreferenceUtil
                                                                            .getBool(Constants
                                                                                .isLoggedIn)) {
                                                                          Constants.checkNetwork()
                                                                              .whenComplete(() =>
                                                                                  callAddRemoveFavorite(
                                                                                      _topListData[
                                                                                              index]
                                                                                          .id));
                                                                        } else {
                                                                          Constants.toastMessage(
                                                                              Languages.of(context)!
                                                                                  .labelPleaseLoginToAddFavorite);
                                                                        }
                                                                      },
                                                                      child: Container(
                                                                        child: _topListData[index]
                                                                                .like!
                                                                            ? SvgPicture.asset(
                                                                                'images/ic_filled_heart.svg',
                                                                                color: Constants
                                                                                    .colorLike,
                                                                                height: ScreenUtil()
                                                                                    .setHeight(
                                                                                        20.0),
                                                                                width: ScreenUtil()
                                                                                    .setWidth(20.0),
                                                                              )
                                                                            : SvgPicture.asset(
                                                                                'images/ic_heart.svg',
                                                                                height: ScreenUtil()
                                                                                    .setHeight(
                                                                                        20.0),
                                                                                width: ScreenUtil()
                                                                                    .setWidth(20.0),
                                                                              ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Container(
                                                                  alignment: Alignment.topLeft,
                                                                  child: Text(
                                                                    getTopRestaurantsFood(index),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants.appFont,
                                                                        color: Constants.colorGray,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(12.0)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      bottom: 3),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(
                                                                                right: 5),
                                                                        child: SvgPicture.asset(
                                                                          'images/ic_map.svg',
                                                                          width: 10,
                                                                          height: 10,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        _topListData[index]
                                                                                .distance
                                                                                .toString() +
                                                                            Languages.of(context)!
                                                                                .labelKmFarAway,
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
                                                                          fontFamily:
                                                                              Constants.appFont,
                                                                          color: Color(0xFF132229),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child: Row(
                                                                        children: [
                                                                          RatingBar.builder(
                                                                            initialRating:
                                                                                _topListData[index]
                                                                                    .rate
                                                                                    .toDouble(),
                                                                            ignoreGestures: true,
                                                                            minRating: 1,
                                                                            direction:
                                                                                Axis.horizontal,
                                                                            itemSize: ScreenUtil()
                                                                                .setWidth(12),
                                                                            allowHalfRating: true,
                                                                            itemBuilder:
                                                                                (context, _) =>
                                                                                    Icon(
                                                                              Icons.star,
                                                                              color: Colors.amber,
                                                                            ),
                                                                            onRatingUpdate:
                                                                                (double rating) {
                                                                              print(rating);
                                                                            },
                                                                          ),
                                                                          Text(
                                                                            '(${_topListData[index].review})',
                                                                            style: TextStyle(
                                                                              fontSize: ScreenUtil()
                                                                                  .setSp(12.0),
                                                                              fontFamily:
                                                                                  Constants.appFont,
                                                                              color:
                                                                                  Color(0xFF132229),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(
                                                                          bottom: 5,
                                                                        ),
                                                                        child: (() {
                                                                          if (_topListData[index]
                                                                                  .vendorType ==
                                                                              'veg') {
                                                                            return Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding:
                                                                                      const EdgeInsets
                                                                                              .only(
                                                                                          right: 2),
                                                                                  child: SvgPicture
                                                                                      .asset(
                                                                                    'images/ic_veg.svg',
                                                                                    height: 10,
                                                                                    width: 10,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          } else if (_topListData[
                                                                                      index]
                                                                                  .vendorType ==
                                                                              'non_veg') {
                                                                            return Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding:
                                                                                      const EdgeInsets
                                                                                              .only(
                                                                                          right: 2),
                                                                                  child: SvgPicture
                                                                                      .asset(
                                                                                    'images/ic_non_veg.svg',
                                                                                    height: 10,
                                                                                    width: 10,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          } else if (_topListData[
                                                                                      index]
                                                                                  .vendorType ==
                                                                              'all') {
                                                                            return Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding:
                                                                                      const EdgeInsets
                                                                                              .only(
                                                                                          right: 2),
                                                                                  child: SvgPicture
                                                                                      .asset(
                                                                                    'images/ic_veg.svg',
                                                                                    height: 10,
                                                                                    width: 10,
                                                                                  ),
                                                                                ),
                                                                                SvgPicture.asset(
                                                                                  'images/ic_non_veg.svg',
                                                                                  height: 10,
                                                                                  width: 10,
                                                                                )
                                                                              ],
                                                                            );
                                                                          }
                                                                        }()),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                Languages.of(context)!.labelPureVegRest,
                                style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Constants.colorTheme,
                                ))
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: ScreenUtil().setHeight(220),
                          child: _vegListData.length == 0
                              ? !_isSyncing
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
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context)!.labelNoData,
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
                                  : Container()
                              : GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: ScreenUtil().screenWidth / 1.1,
                                  ),
                                  itemCount: _vegListData.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.only(left: 15, right: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: RestaurantsDetailsScreen(
                                                restaurantId: _vegListData[index].id,
                                                isFav: _vegListData[index].like,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: IntrinsicHeight(
                                            child: Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    child: CachedNetworkImage(
                                                      width: 100,
                                                      imageUrl: _vegListData[index].image!,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context, url) =>
                                                          SpinKitFadingCircle(
                                                              color: Constants.colorTheme),
                                                      errorWidget: (context, url, error) =>
                                                          Container(
                                                        child: Center(
                                                            child:
                                                                Image.asset('images/noimage.png')),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      width: ScreenUtil().screenWidth / 2,
                                                      child: Wrap(
                                                        alignment: WrapAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        _vegListData[index].name!,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines: 1,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.appFontBold,
                                                                            fontSize: ScreenUtil()
                                                                                .setSp(16.0)),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        if (SharedPreferenceUtil
                                                                            .getBool(Constants
                                                                                .isLoggedIn)) {
                                                                          Constants.checkNetwork()
                                                                              .whenComplete(() =>
                                                                                  callAddRemoveFavorite(
                                                                                      _vegListData[
                                                                                              index]
                                                                                          .id));
                                                                        } else {
                                                                          Constants.toastMessage(
                                                                              Languages.of(context)!
                                                                                  .labelPleaseLoginToAddFavorite);
                                                                        }
                                                                      },
                                                                      child: Container(
                                                                        child: _vegListData[index]
                                                                                .like!
                                                                            ? SvgPicture.asset(
                                                                                'images/ic_filled_heart.svg',
                                                                                color: Constants
                                                                                    .colorLike,
                                                                                height: 20,
                                                                                width: 20,
                                                                              )
                                                                            : SvgPicture.asset(
                                                                                'images/ic_heart.svg',
                                                                                width: 20,
                                                                              ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Container(
                                                                  alignment: Alignment.topLeft,
                                                                  child: Text(
                                                                    getVegRestaurantsFood(index),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants.appFont,
                                                                        color: Constants.colorGray,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(12.0)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      bottom: 3),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(
                                                                                right: 5),
                                                                        child: SvgPicture.asset(
                                                                          'images/ic_map.svg',
                                                                          width: 10,
                                                                          height: 10,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        _vegListData[index]
                                                                                .distance
                                                                                .toString() +
                                                                            Languages.of(context)!
                                                                                .labelKmFarAway,
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
                                                                          fontFamily:
                                                                              Constants.appFont,
                                                                          color: Color(0xFF132229),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child: Row(
                                                                        children: [
                                                                          RatingBar.builder(
                                                                            initialRating:
                                                                                _vegListData[index]
                                                                                    .rate
                                                                                    .toDouble(),
                                                                            ignoreGestures: true,
                                                                            minRating: 1,
                                                                            direction:
                                                                                Axis.horizontal,
                                                                            itemSize: ScreenUtil()
                                                                                .setWidth(12),
                                                                            allowHalfRating: true,
                                                                            itemBuilder:
                                                                                (context, _) =>
                                                                                    Icon(
                                                                              Icons.star,
                                                                              color: Colors.amber,
                                                                            ),
                                                                            onRatingUpdate:
                                                                                (double rating) {
                                                                              print(rating);
                                                                            },
                                                                          ),
                                                                          Text(
                                                                            '(${_vegListData[index].review})',
                                                                            style: TextStyle(
                                                                              fontSize: ScreenUtil()
                                                                                  .setSp(12.0),
                                                                              fontFamily:
                                                                                  Constants.appFont,
                                                                              color:
                                                                                  Color(0xFF132229),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: (() {
                                                                        if (_vegListData[index]
                                                                                .vendorType ==
                                                                            'veg') {
                                                                          return Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets
                                                                                            .only(
                                                                                        right: 2),
                                                                                child: SvgPicture
                                                                                    .asset(
                                                                                  'images/ic_veg.svg',
                                                                                  height: 10,
                                                                                  width: 10,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        } else if (_vegListData[
                                                                                    index]
                                                                                .vendorType ==
                                                                            'non_veg') {
                                                                          return Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets
                                                                                            .only(
                                                                                        right: 2),
                                                                                child: SvgPicture
                                                                                    .asset(
                                                                                  'images/ic_non_veg.svg',
                                                                                  height: 10,
                                                                                  width: 10,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        } else if (_vegListData[
                                                                                    index]
                                                                                .vendorType ==
                                                                            'all') {
                                                                          return Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets
                                                                                            .only(
                                                                                        right: 2),
                                                                                child: SvgPicture
                                                                                    .asset(
                                                                                  'images/ic_veg.svg',
                                                                                  height: 10,
                                                                                  width: 10,
                                                                                ),
                                                                              ),
                                                                              SvgPicture.asset(
                                                                                'images/ic_non_veg.svg',
                                                                                height: 10,
                                                                                width: 10,
                                                                              )
                                                                            ],
                                                                          );
                                                                        }
                                                                      }()),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                Languages.of(context)!.labelNonPureVegRest,
                                style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Constants.colorTheme,
                                ))
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: ScreenUtil().setHeight(220),
                          child: _nonvegListData.length == 0
                              ? !_isSyncing
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
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context)!.labelNoData,
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
                                  : Container()
                              : GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: ScreenUtil().screenWidth / 1.1,
                                  ),
                                  itemCount: _nonvegListData.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.only(left: 15, right: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: RestaurantsDetailsScreen(
                                                restaurantId: _nonvegListData[index].id,
                                                isFav: _nonvegListData[index].like,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  width: 100,
                                                  imageUrl: _nonvegListData[index].image!,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Constants.colorTheme),
                                                  errorWidget: (context, url, error) => Container(
                                                    child: Center(
                                                        child: Image.asset('images/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(10),
                                                  width: ScreenUtil().screenWidth / 2,
                                                  child: Wrap(
                                                    alignment: WrapAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    _nonvegListData[index].name!,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants.appFontBold,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil
                                                                        .getBool(
                                                                            Constants.isLoggedIn)) {
                                                                      Constants.checkNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(
                                                                                  _nonvegListData[
                                                                                          index]
                                                                                      .id));
                                                                    } else {
                                                                      Constants.toastMessage(Languages
                                                                              .of(context)!
                                                                          .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    child: _nonvegListData[index]
                                                                            .like!
                                                                        ? SvgPicture.asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color:
                                                                                Constants.colorLike,
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          )
                                                                        : SvgPicture.asset(
                                                                            'images/ic_heart.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Container(
                                                              alignment: Alignment.topLeft,
                                                              child: Text(
                                                                getNonVegRestaurantsFood(index),
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontFamily: Constants.appFont,
                                                                    color: Constants.colorGray,
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment.topLeft,
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(bottom: 3),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        right: 5),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_map.svg',
                                                                      width: 10,
                                                                      height: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _nonvegListData[index]
                                                                            .distance
                                                                            .toString() +
                                                                        Languages.of(context)!
                                                                            .labelKmFarAway,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil().setSp(12.0),
                                                                      fontFamily: Constants.appFont,
                                                                      color: Color(0xFF132229),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar.builder(
                                                                        initialRating:
                                                                            _nonvegListData[index]
                                                                                .rate
                                                                                .toDouble(),
                                                                        ignoreGestures: true,
                                                                        minRating: 1,
                                                                        direction: Axis.horizontal,
                                                                        itemSize: ScreenUtil()
                                                                            .setWidth(12),
                                                                        allowHalfRating: true,
                                                                        itemBuilder: (context, _) =>
                                                                            Icon(
                                                                          Icons.star,
                                                                          color: Colors.amber,
                                                                        ),
                                                                        onRatingUpdate:
                                                                            (double rating) {
                                                                          print(rating);
                                                                        },
                                                                      ),
                                                                      Text(
                                                                        '(${_nonvegListData[index].review})',
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
                                                                          fontFamily:
                                                                              Constants.appFont,
                                                                          color: Color(0xFF132229),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  child: (() {
                                                                    if (_nonvegListData[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_nonvegListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_nonvegListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                          SvgPicture.asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                            width: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                  }()),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
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
                                ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            Languages.of(context)!.labelExploreRest,
                            style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                          child: _exploreResListData.length == 0
                              ? !_isSyncing
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
                                            padding:
                                                EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context)!.labelNoData,
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
                                  : Container()
                              : ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: _exploreResListData.length,
                                  itemBuilder: (BuildContext context, int index) => GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                          widget: RestaurantsDetailsScreen(
                                            restaurantId: _exploreResListData[index].id,
                                            isFav: _exploreResListData[index].like,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: CachedNetworkImage(
                                              width: ScreenUtil().setWidth(100),
                                              imageUrl: _exploreResListData[index].image!,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => SpinKitFadingCircle(
                                                  color: Constants.colorTheme),
                                              errorWidget: (context, url, error) => Container(
                                                child: Center(
                                                    child: Image.asset('images/noimage.png')),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                _exploreResListData[index].name!,
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontFamily: Constants.appFontBold,
                                                                    fontSize:
                                                                        ScreenUtil().setSp(16.0)),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (SharedPreferenceUtil.getBool(
                                                                    Constants.isLoggedIn)) {
                                                                  Constants.checkNetwork()
                                                                      .whenComplete(() =>
                                                                          callAddRemoveFavorite(
                                                                              _exploreResListData[
                                                                                      index]
                                                                                  .id));
                                                                } else {
                                                                  Constants.toastMessage(Languages
                                                                          .of(context)!
                                                                      .labelPleaseLoginToAddFavorite);
                                                                }
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.only(
                                                                    right: ScreenUtil().setWidth(5),
                                                                    top: ScreenUtil().setWidth(5)),
                                                                child: _exploreResListData[index]
                                                                        .like!
                                                                    ? SvgPicture.asset(
                                                                        'images/ic_filled_heart.svg',
                                                                        color: Constants.colorLike,
                                                                        height: 20,
                                                                        width: 20,
                                                                      )
                                                                    : SvgPicture.asset(
                                                                        'images/ic_heart.svg',
                                                                        height: 20,
                                                                        width: 20,
                                                                      ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Container(
                                                          alignment: Alignment.topLeft,
                                                          child: Text(
                                                            getExploreRestaurantsFood(index),
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                fontFamily: Constants.appFont,
                                                                color: Constants.colorGray,
                                                                fontSize: ScreenUtil().setSp(12.0)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(10)),
                                                    child: Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(bottom: 3),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      right: 5),
                                                                  child: SvgPicture.asset(
                                                                    'images/ic_map.svg',
                                                                    width: 10,
                                                                    height: 10,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _exploreResListData[index]
                                                                          .distance
                                                                          .toString() +
                                                                      Languages.of(context)!
                                                                          .labelKmFarAway,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0),
                                                                    fontFamily: Constants.appFont,
                                                                    color: Color(0xFF132229),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    RatingBar.builder(
                                                                      initialRating:
                                                                          _exploreResListData[index]
                                                                              .rate
                                                                              .toDouble(),
                                                                      ignoreGestures: true,
                                                                      minRating: 1,
                                                                      direction: Axis.horizontal,
                                                                      itemSize:
                                                                          ScreenUtil().setWidth(12),
                                                                      allowHalfRating: true,
                                                                      itemBuilder: (context, _) =>
                                                                          Icon(
                                                                        Icons.star,
                                                                        color: Colors.amber,
                                                                      ),
                                                                      onRatingUpdate:
                                                                          (double rating) {
                                                                        print(rating);
                                                                      },
                                                                    ),
                                                                    Text(
                                                                      '(${_exploreResListData[index].review})',
                                                                      style: TextStyle(
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(12.0),
                                                                        fontFamily:
                                                                            Constants.appFont,
                                                                        color: Color(0xFF132229),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    right: ScreenUtil().setWidth(5),
                                                                    bottom:
                                                                        ScreenUtil().setWidth(5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      right: 10),
                                                                  child: (() {
                                                                    if (_exploreResListData[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: 10,
                                                                              width: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_exploreResListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: 10,
                                                                              width: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_exploreResListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: 10,
                                                                              width: 10,
                                                                            ),
                                                                          ),
                                                                          SvgPicture.asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height: 10,
                                                                            width: 10,
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                  }()),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<AllCuisinesModel>> callAllCuisine() async {
    AllCuisinesModel response;
    if (mounted)
      setState(() {
        _isSyncing = true;
      });
    try {
      _allCuisineListData.clear();
      response = await RestClient(RetroApi().dioData()).allCuisine();
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            _isSyncing = false;
            if (0 < response.data!.length) {
              _allCuisineListData.addAll(response.data!);
            } else {
              _allCuisineListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<NearByRestaurantModel>> callNearByRestaurants() async {
    NearByRestaurantModel response;
    try {
      _nearbyListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).nearBy(body);
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            if (0 < response.data!.length) {
              _nearbyListData.addAll(response.data!);
            } else {
              _nearbyListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }

    return BaseModel()..data = response;
  }

  Future<BaseModel<TopRestaurantsListModel>> callTopRestaurants() async {
    TopRestaurantsListModel response;
    try {
      _topListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).topRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            if (0 < response.data!.length) {
              _topListData.addAll(response.data!);
            } else {
              _topListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<VegRestaurantModel>> callVegRestaurants() async {
    VegRestaurantModel response;
    try {
      _vegListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).vegRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            if (0 < response.data!.length) {
              _vegListData.addAll(response.data!);
            } else {
              _vegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<NonVegRestaurantModel>> callNonVegRestaurants() async {
    NonVegRestaurantModel response;
    try {
      _nonvegListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).nonVegRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            if (0 < response.data!.length) {
              _nonvegListData.addAll(response.data!);
            } else {
              _nonvegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ExploreRestaurantListModel>> callExploreRestaurants() async {
    ExploreRestaurantListModel response;
    try {
      _exploreResListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).exploreRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted)
          setState(() {
            if (0 < response.data!.length) {
              _exploreResListData.addAll(response.data!);
            } else {
              _exploreResListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callAddRemoveFavorite(int? vegRestId) async {
    CommenRes response;
    try {
      if (mounted)
        setState(() {
          _isSyncing = true;
        });
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response = await RestClient(RetroApi().dioData()).favorite(body);
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Constants.checkNetwork().whenComplete(() => callVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
        Constants.checkNetwork().whenComplete(() => callTopRestaurants());
        Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
        if (mounted) setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BannerResponse>> getBanners() async {
    BannerResponse response;
    try {
      response = await RestClient(RetroApi().dioData()).getBanner();
      if (response.data != null) {
        setState(() {
          print("check bannwe lwngrh ${response.data!.length}");
          banenrList = response.data!;
        });
      } else {
        banenrList = [];
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (_nearbyListData.isNotEmpty) {
      for (int j = 0; j < _nearbyListData[index].cuisine!.length; j++) {
        restaurantsFood.add(_nearbyListData[index].cuisine![j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" , ");
  }

  String getVegRestaurantsFood(int index) {
    vegRestaurantsFood.clear();
    if (_vegListData.isNotEmpty) {
      for (int j = 0; j < _vegListData[index].cuisine!.length; j++) {
        vegRestaurantsFood.add(_vegListData[index].cuisine![j].name);
      }
    }
    print(vegRestaurantsFood.toString());

    return vegRestaurantsFood.join(" , ");
  }

  String getNonVegRestaurantsFood(int index) {
    nonVegRestaurantsFood.clear();
    if (_nonvegListData.isNotEmpty) {
      for (int j = 0; j < _nonvegListData[index].cuisine!.length; j++) {
        nonVegRestaurantsFood.add(_nonvegListData[index].cuisine![j].name);
      }
    }
    print(nonVegRestaurantsFood.toString());

    return nonVegRestaurantsFood.join(" , ");
  }

  String getTopRestaurantsFood(int index) {
    topRestaurantsFood.clear();
    if (_topListData.isNotEmpty) {
      for (int j = 0; j < _topListData[index].cuisine!.length; j++) {
        topRestaurantsFood.add(_topListData[index].cuisine![j].name);
      }
    }
    print(topRestaurantsFood.toString());

    return topRestaurantsFood.join(" , ");
  }

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_exploreResListData.isNotEmpty) {
      for (int j = 0; j < _exploreResListData[index].cuisine!.length; j++) {
        exploreRestaurantsFood.add(_exploreResListData[index].cuisine![j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" , ");
  }
}
