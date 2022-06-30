import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/favorite_list_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class YourFavoritesScreen extends StatefulWidget {
  @override
  _YourFavoritesScreenState createState() => _YourFavoritesScreenState();
}

class _YourFavoritesScreenState extends State<YourFavoritesScreen> {
  List<FavoriteListData> _listFavoriteData = [];
  List<String?> favoriteRestaurantsFood = [];
  bool _isSyncing = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    Constants.checkNetwork().whenComplete(() => callGetFavoritesList());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callGetFavoritesList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context)!.labelYourFavorites),
        body: SmartRefresher(
          enablePullDown: true,
          header: MaterialClassicHeader(
            backgroundColor: Constants.colorTheme,
            color:Constants.colorWhite,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ModalProgressHUD(
            inAsyncCall: _isSyncing,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child:
                          _listFavoriteData.length == 0
                              ? !_isSyncing
                                  ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            width: ScreenUtil().setWidth(150),
                                            height:
                                                ScreenUtil().setHeight(180),
                                            image: AssetImage(
                                                'images/ic_no_rest.png'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              Languages.of(context)!
                                                  .labelNoData,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(18),
                                                fontFamily:
                                                    Constants.appFontBold,
                                                color:
                                                    Constants.colorTheme,
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
                                  itemCount: _listFavoriteData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                Transitions(
                                                  transitionType:
                                                      TransitionType.fade,
                                                  curve: Curves.bounceInOut,
                                                  reverseCurve: Curves
                                                      .fastLinearToSlowEaseIn,
                                                  widget:
                                                      RestaurantsDetailsScreen(
                                                    restaurantId:
                                                        _listFavoriteData[
                                                                index]
                                                            .id,
                                                    isFav: true,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              margin:
                                                  EdgeInsets.only(bottom: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.max,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: CachedNetworkImage(
                                                      height: ScreenUtil()
                                                          .setHeight(100),
                                                      width: ScreenUtil()
                                                          .setWidth(100),
                                                      imageUrl:
                                                          _listFavoriteData[
                                                                  index]
                                                              .image!,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitFadingCircle(
                                                              color: Constants.colorTheme),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        child: Center(
                                                            child: Image.asset('images/noimage.png')),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(
                                                                          _listFavoriteData[index]
                                                                              .name!,
                                                                          maxLines: 1,
                                                                          style: TextStyle(
                                                                              fontFamily: Constants.appFontBold,
                                                                              fontSize: ScreenUtil().setSp(16.0)),
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                                                            showdialog(_listFavoriteData[index].id);
                                                                          } else {
                                                                            Constants.toastMessage(Languages.of(context)!.labelPleaseLoginToAddFavorite);
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                            child: SvgPicture.asset(
                                                                          'images/ic_filled_heart.svg',
                                                                          color:
                                                                              Constants.colorLike,
                                                                          height:
                                                                              ScreenUtil().setHeight(20.0),
                                                                          width:
                                                                              ScreenUtil().setWidth(20.0),
                                                                        )),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        Text(
                                                                      getFavRestaurantsFood(
                                                                          index),
                                                                      maxLines: 2,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              Constants.appFont,
                                                                          color: Constants.colorGray,
                                                                          fontSize: ScreenUtil().setSp(12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                top: ScreenUtil()
                                                                    .setHeight(
                                                                        10)),
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(bottom: 3),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(right: 5),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_map.svg',
                                                                              width: 10,
                                                                              height: ScreenUtil().setHeight(10),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            _listFavoriteData[index].distance.toString() + Languages.of(context)!.labelKmFarAway,
                                                                            style: TextStyle(
                                                                              fontSize: ScreenUtil().setSp(12.0),
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
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              RatingBar.builder(
                                                                                initialRating: _listFavoriteData[index].rate.toDouble(),
                                                                                minRating: 1,
                                                                                direction: Axis.horizontal,
                                                                                itemSize: ScreenUtil().setWidth(15),
                                                                                allowHalfRating: true,
                                                                                itemBuilder: (context, _) => Icon(
                                                                                  Icons.star,
                                                                                  color: Colors.amber,
                                                                                ), onRatingUpdate: (double rating) {
                                                                                print(rating);
                                                                              },
                                                                              ),

                                                                              Text(
                                                                                '(${_listFavoriteData[index].review})',
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
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.only(right: 10),
                                                                            child: _listFavoriteData[index].vendorType == 'veg'
                                                                                ? Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 2),
                                                                                        child: SvgPicture.asset(
                                                                                          'images/ic_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                : _listFavoriteData[index].vendorType == 'non_veg' ? Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 2),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/ic_non_veg.svg',
                                                                                    height: ScreenUtil().setHeight(10.0),
                                                                                    width: ScreenUtil().setHeight(10.0),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ): Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 2),
                                                                                        child: SvgPicture.asset(
                                                                                          'images/ic_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        ),
                                                                                      ),
                                                                                      SvgPicture.asset(
                                                                                        'images/ic_non_veg.svg',
                                                                                        height: ScreenUtil().setHeight(10.0),
                                                                                        width: ScreenUtil().setHeight(10.0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                          ),
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
                                          )),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  showdialog(int? id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 20),
              child: Container(
                height: ScreenUtil().setHeight(180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelRemoveFromTheList,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: Constants.appFontBold,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(10),
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Text(
                          Languages.of(context)!.labelAreYouSureToRemove,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: Constants.appFont,
                              color: Constants.colorBlack),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  Languages.of(context)!.labelNoGoBack,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.appFontBold,
                                      color: Constants.colorGray),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    callAddRemoveFavorite(id);
                                  },
                                  child: Text(
                                    Languages.of(context)!.labelYesRemoveIt,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.appFontBold,
                                        color: Constants.colorBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<BaseModel<CommenRes>> callAddRemoveFavorite(int? vegRestId) async {
    CommenRes response;
    try{
      setState(() {
        _isSyncing = true;
      });
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response  = await RestClient(RetroApi().dioData()).favorite(body);
      setState(() {
        _isSyncing = false;
      });
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetFavoritesList();
        setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }

    }catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  String getFavRestaurantsFood(int index) {
    favoriteRestaurantsFood.clear();
    if (_listFavoriteData.isNotEmpty) {
      for (int j = 0; j < _listFavoriteData[index].cuisine!.length; j++) {
        favoriteRestaurantsFood.add(_listFavoriteData[index].cuisine![j].name);
      }
    }
    print(favoriteRestaurantsFood.toString());

    return favoriteRestaurantsFood.join(" , ");
  }

  Future<BaseModel<FavoriteListModel>> callGetFavoritesList() async {
    FavoriteListModel response;
    try{
      _listFavoriteData.clear();
      setState(() {
        _isSyncing = true;
      });
      response  = await  RestClient(RetroApi().dioData()).restFavorite();
      print(response.success);
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        setState(() {
          _listFavoriteData.addAll(response.data!);
          // _listFavoriteData.clear();
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    }catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
