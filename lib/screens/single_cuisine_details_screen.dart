import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/cuisine_vendor_details_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SingleCuisineDetailsScreen extends StatefulWidget {
  final cuisineId, strCuisineName;

  const SingleCuisineDetailsScreen({Key? key, this.cuisineId, this.strCuisineName})
      : super(key: key);

  @override
  _SingleCuisineDetailsScreenState createState() => _SingleCuisineDetailsScreenState();
}

class _SingleCuisineDetailsScreenState extends State<SingleCuisineDetailsScreen> {
  List<CuisineVendorDetailsListData> _listCuisineVendorRestaurants = [];
  List<String?> exploreRestaurantsFood = [];

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: ApplicationToolbar(
        appbarTitle: widget.strCuisineName,
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
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
            child: _listCuisineVendorRestaurants.length == 0
                ? !_isSyncing
                    ? Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              width: ScreenUtil().setWidth(150),
                              height: ScreenUtil().setHeight(180),
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
                    : Container()
                : ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _listCuisineVendorRestaurants.length,
                    itemBuilder: (BuildContext context, int index) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions(
                            transitionType: TransitionType.fade,
                            curve: Curves.bounceInOut,
                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                            widget: RestaurantsDetailsScreen(
                              restaurantId: _listCuisineVendorRestaurants[index].id,
                              isFav: null,
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
                                height: ScreenUtil().setHeight(100),
                                width: ScreenUtil().setWidth(100),
                                imageUrl: _listCuisineVendorRestaurants[index].image!,
                                fit: BoxFit.fill,
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(color: Constants.colorTheme),
                                errorWidget: (context, url, error) => Container(
                                  child: Center(child: Image.asset('images/noimage.png')),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  _listCuisineVendorRestaurants[index].name!,
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: ScreenUtil().setSp(16.0)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(
                                                getExploreRestaurantsFood(index),
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    color: Constants.colorGray,
                                                    fontSize: ScreenUtil().setSp(12.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        RatingBar.builder(
                                                          initialRating:
                                                              _listCuisineVendorRestaurants[index]
                                                                  .rate
                                                                  .toDouble(),
                                                          minRating: 1,
                                                          ignoreGestures: true,
                                                          direction: Axis.horizontal,
                                                          itemSize: ScreenUtil().setWidth(12),
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
                                                          '(${_listCuisineVendorRestaurants[index].review})',
                                                          style: TextStyle(
                                                            fontSize: ScreenUtil().setSp(12.0),
                                                            fontFamily: Constants.appFont,
                                                            color: Color(0xFF132229),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(10)),
                                                    child: (() {
                                                      if (_listCuisineVendorRestaurants[index]
                                                              .vendorType ==
                                                          'veg') {
                                                        return Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(right: 2),
                                                              child: SvgPicture.asset(
                                                                'images/ic_veg.svg',
                                                                height:
                                                                    ScreenUtil().setHeight(10.0),
                                                                width: ScreenUtil().setHeight(10.0),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } else if (_listCuisineVendorRestaurants[
                                                                  index]
                                                              .vendorType ==
                                                          'non_veg') {
                                                        return Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(right: 2),
                                                              child: SvgPicture.asset(
                                                                'images/ic_non_veg.svg',
                                                                height:
                                                                    ScreenUtil().setHeight(10.0),
                                                                width: ScreenUtil().setHeight(10.0),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } else if (_listCuisineVendorRestaurants[
                                                                  index]
                                                              .vendorType ==
                                                          'all') {
                                                        return Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  right: ScreenUtil().setWidth(5)),
                                                              child: SvgPicture.asset(
                                                                'images/ic_veg.svg',
                                                                height:
                                                                    ScreenUtil().setHeight(10.0),
                                                                width: ScreenUtil().setHeight(10.0),
                                                              ),
                                                            ),
                                                            SvgPicture.asset(
                                                              'images/ic_non_veg.svg',
                                                              height: ScreenUtil().setHeight(10.0),
                                                              width: ScreenUtil().setHeight(10.0),
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
        ),
      ),
    ));
  }

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_listCuisineVendorRestaurants.isNotEmpty) {
      for (int j = 0; j < _listCuisineVendorRestaurants[index].cuisine!.length; j++) {
        exploreRestaurantsFood.add(_listCuisineVendorRestaurants[index].cuisine![j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" , ");
  }

  Future<BaseModel<CuisineVendorDetailsModel>> getCallSingleCuisineDetails(cuisineId) async {
    CuisineVendorDetailsModel response;
    try {
      _listCuisineVendorRestaurants.clear();
      setState(() {
        _isSyncing = true;
      });
      response = await RestClient(RetroApi().dioData()).cuisineVendor(cuisineId);
      setState(() {
        _isSyncing = false;
        _listCuisineVendorRestaurants.addAll(response.data!);
      });
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
