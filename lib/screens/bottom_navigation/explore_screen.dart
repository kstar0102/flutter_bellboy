import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/componants/custom_appbar.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/screens/search_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class ExploreScreen extends StatefulWidget {
  final String? strSortBy, strQuickFilter, strSelectedCousinesId;

  const ExploreScreen(
      {Key? key,
      this.strSortBy,
      this.strQuickFilter,
      this.strSelectedCousinesId})
      : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<ExploreRestaurantsListData> _exploreResListData = [];
  List<String?> exploreRestaurantsFood = [];

  bool _isSyncing = false;

  List<String> _listSortBy = [];
  List<String> _listQuickFilter = [];

  List<AllCuisineData> _allCuisineListData = [];

  List<String> selectedCuisineListId = [];


  int? radioindex;
  int? radioQuickFilter;
  int? radioCousines;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    getSortByList();
    getQuickFilterList();
    Constants.checkNetwork().whenComplete(() => callAllCuisine());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  Future<BaseModel<ExploreRestaurantListModel>> callExploreRestaurants() async {
    ExploreRestaurantListModel response;
    try{
      _exploreResListData.clear();
      setState(() {
        _isSyncing = true;
      });

      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };

      response  = await RestClient(RetroApi().dioData()).exploreRest(body);
      print(response.success);
      if (response.success!) {
        setState(() {
          _isSyncing = false;
          _exploreResListData.addAll(response.data!);
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


  Future<BaseModel<ExploreRestaurantListModel>> callGetFilteredDataList( String selectedCuisineId, String? sortBy, String? quick) async {
    ExploreRestaurantListModel response;
    try{
      _exploreResListData.clear();
      Constants.onLoading(context);
      Map<String, String?> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
        'cousins': selectedCuisineId,
        'quick_filter': quick,
        'sorting': sortBy,
      };

      response  = await RestClient(RetroApi().dioData()).filter(body);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _exploreResListData.addAll(response.data!);
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
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


  @override
  void initState() {
    super.initState();

    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());

    Constants.checkNetwork().whenComplete(() => callAllCuisine());
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

  void callSetState() {
    setState(() {});
  }

  void openFilterSheet() {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Scaffold(
                    bottomNavigationBar: Container(
                      height: ScreenUtil().setHeight(50),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Color(0xffeeeeee),
                                child: Center(
                                  child: Text(
                                    Languages.of(context)!.labelCancel,
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                String? sortBy, quickFilter;
                                if (radioindex == 0) {
                                  print('High To Low (Rating)');
                                  sortBy = 'high_to_low';
                                } else if (radioindex == 1) {
                                  print('Low To High(Rating)');
                                  sortBy = 'low_to_high';
                                }
                                if (radioQuickFilter == 0) {
                                  quickFilter = 'veg';
                                } else if (radioQuickFilter == 1) {
                                  quickFilter = 'non_veg';
                                } else if (radioQuickFilter == 2) {
                                  quickFilter = 'all';
                                }
                                selectedCuisineListId.clear();
                                for (int i = 0;
                                    i < _allCuisineListData.length;
                                    i++) {
                                  if (_allCuisineListData[i].isChecked) {
                                    selectedCuisineListId.add(
                                        _allCuisineListData[i].id.toString());
                                  }
                                }
                                String commaSeparated =
                                    selectedCuisineListId.join(',');
                                print('Selected cuisine Id : ---' +
                                    commaSeparated);
                                Navigator.pop(context);
                                callGetFilteredDataList(
                                    commaSeparated, sortBy, quickFilter);
                              },
                              child: Container(
                                color: Constants.colorTheme,
                                child: Center(
                                  child: Text(
                                    Languages.of(context)!.labelApplyFilter,
                                    style: TextStyle(
                                        color: Constants.colorWhite,
                                        fontFamily: Constants.appFont,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    appBar: ApplicationToolbarWithClrBtn(
                      appbarTitle: Languages.of(context)!.labelFilter,
                      strButtonTitle: Languages.of(context)!.labelClear,
                      btnColor: Constants.colorTheme,
                      onBtnPress: () {
                        Navigator.pop(context);

                          selectedCuisineListId.clear();
                          radioindex = null;
                          radioQuickFilter = null;
                          for (int i = 0; i < _allCuisineListData.length; i++) {
                            _allCuisineListData[i].isChecked = false;
                          }
                          Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
                        setState(() {});

                      },
                    ),
                    backgroundColor: Color(0xFFFAFAFA),
                    body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('images/ic_background_image.png'),
                        fit: BoxFit.cover,
                      )),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            right: ScreenUtil().setWidth(10)),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Languages.of(context)!.labelSortingBy,
                                style: TextStyle(
                                    fontFamily: Constants.appFont,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(15)),
                                child: Container(
                                  height: ScreenUtil().setHeight(60),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
                                    mainAxisSpacing: 5,
                                    children: List.generate(_listSortBy.length,
                                        (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // changeIndex(index);
                                          setState(() {
                                            radioindex = index;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            radioindex == index
                                                ? getChecked()
                                                : getunChecked(),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setWidth(10)),
                                              child: Text(
                                                _listSortBy[index],
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Text(
                                Languages.of(context)!.labelQuickFilters,
                                style: TextStyle(
                                    fontFamily: Constants.appFont,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(15)),
                                child: Container(
                                  height: ScreenUtil().setHeight(100),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 5,
                                    children: List.generate(
                                        _listQuickFilter.length, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            radioQuickFilter = index;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            radioQuickFilter == index
                                                ? getChecked()
                                                : getunChecked(),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  _listQuickFilter[index],
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.appFont,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Text(
                                Languages.of(context)!.labelCousines,
                                style: TextStyle(
                                    fontFamily: Constants.appFont,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(15)),
                                  child: Container(
                                    child: GridView.count(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      crossAxisCount: 2,
                                      childAspectRatio: 5,
                                      mainAxisSpacing: 10,
                                      children: List.generate(
                                          _allCuisineListData.length, (index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _allCuisineListData[index]
                                                      .isChecked =
                                                  !_allCuisineListData[index]
                                                      .isChecked;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              _allCuisineListData[index]
                                                      .isChecked
                                                  ? getChecked()
                                                  : getunChecked(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  _allCuisineListData[index]
                                                      .name!,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.appFont,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
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
              );
            },
          );
        });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecorationChecked(true, Constants.colorWhite),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }

  void changeCousinesIndex(int index) {
    setState(() {
      radioCousines = index;
    });
  }

  void getSortByList() {
    _listSortBy.clear();
    _listSortBy.add(Languages.of(context)!.labelHighToLow);
    _listSortBy.add(Languages.of(context)!.labelLowToHigh);
  }

  void getQuickFilterList() {
    _listQuickFilter.clear();
    _listQuickFilter.add(Languages.of(context)!.labelVegRestaurant);
    _listQuickFilter.add(Languages.of(context)!.labelNonVegRestaurant);
    _listQuickFilter.add(Languages.of(context)!.labelBothVegNonVeg);
  }

  Future<BaseModel<AllCuisinesModel>> callAllCuisine() async {
    AllCuisinesModel response;
    try{
      _allCuisineListData.clear();
      Constants.onLoading(context);
      response  = await RestClient(RetroApi().dioData()).allCuisine();
      print(response.success);
        Constants.hideDialog(context);
      if (response.success!) {
        _allCuisineListData.addAll(response.data!);

        callSetState();
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

  void changeIndex(int index) {
    setState(() {
      radioindex = index;
    });
  }

  void changeQuickFilterIndex(int index) {
    setState(() {
      radioQuickFilter = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    getSortByList();
    getQuickFilterList();


/*
    progressDialog.style(
      message: Languages.of(context).labelPleaseWait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Constants.colorTheme),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
      messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
    );*/

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          isFilter: true,
          onFilterTap: () {
            openFilterSheet();
          },
          onOfferTap: () {
            Navigator.of(context).push(
              Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: OfferScreen(),
              ),
            );
          },
          onSearchTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: SearchScreen()));
          },
          onLocationTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.none,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: SetLocationScreen()));
          },
          strSelectedAddress:
              SharedPreferenceUtil.getString(Constants.selectedAddress).isEmpty
                  ? ''
                  : SharedPreferenceUtil.getString(Constants.selectedAddress),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: MaterialClassicHeader(
            backgroundColor: Constants.colorTheme,
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
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 10, top: 10),
                  child: _exploreResListData.isNotEmpty
                      ? ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _exploreResListData.length,
                          itemBuilder:
                              (BuildContext context, int index) =>
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                              Curves.fastLinearToSlowEaseIn,
                                          widget: RestaurantsDetailsScreen(
                                            restaurantId:
                                                _exploreResListData[index].id,
                                            isFav: _exploreResListData[index].like,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: CachedNetworkImage(
                                              height:
                                                  ScreenUtil().setHeight(100),
                                              width:
                                                  ScreenUtil().setWidth(100),
                                              imageUrl:
                                                  _exploreResListData[index]
                                                      .image!,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) =>
                                                  SpinKitFadingCircle(
                                                      color: Constants.colorTheme),
                                              errorWidget:
                                                  (context, url, error) =>
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
                                                              Container(
                                                              width : ScreenUtil().setWidth(130),
                                                                child: Text(
                                                                  _exploreResListData[
                                                                          index]
                                                                      .name!,
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          Constants
                                                                              .appFontBold,
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(16.0)),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (SharedPreferenceUtil.getBool(
                                                                      Constants
                                                                          .isLoggedIn)) {
                                                                    Constants
                                                                            .checkNetwork()
                                                                        .whenComplete(() =>
                                                                            callAddRemoveFavorite(_exploreResListData[index].id));
                                                                  } else {
                                                                    Constants.toastMessage(
                                                                        Languages.of(context)!
                                                                            .labelPleaseLoginToAddFavorite);
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets.only(
                                                                      right: ScreenUtil().setWidth(5),
                                                                      top: ScreenUtil().setWidth(5)),
                                                                  child: _exploreResListData[index]
                                                                          .like!
                                                                      ? SvgPicture
                                                                          .asset(
                                                                          'images/ic_filled_heart.svg',
                                                                          color: Constants.colorLike,
                                                                          height: ScreenUtil().setHeight(20.0),
                                                                          width: ScreenUtil().setWidth(20.0),
                                                                        )
                                                                      : SvgPicture
                                                                          .asset(
                                                                          'images/ic_heart.svg',

                                                                          height:
                                                                              ScreenUtil().setHeight(20.0),
                                                                          width:
                                                                              ScreenUtil().setWidth(20.0),
                                                                        ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment: Alignment
                                                              .topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              getExploreRestaurantsFood(
                                                                  index),
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .appFont,
                                                                  color:
                                                                      Constants
                                                                          .colorGray,
                                                                  fontSize: ScreenUtil()
                                                                      .setSp(
                                                                          12.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil()
                                                            .setHeight(10)),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          3),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'images/ic_map.svg',
                                                                      width:
                                                                          10,
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _exploreResListData[index]
                                                                            .distance
                                                                            .toString() +
                                                                        Languages.of(context)!
                                                                            .labelKmFarAway,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil().setSp(12.0),
                                                                      fontFamily:
                                                                          Constants.appFont,
                                                                      color: Color(
                                                                          0xFF132229),
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
                                                                        initialRating:_exploreResListData[index].rate.toDouble(),
                                                                        minRating: 1,
                                                                        ignoreGestures: true,
                                                                        direction: Axis.horizontal,
                                                                        itemSize: ScreenUtil().setWidth(12),
                                                                        allowHalfRating: true,
                                                                        itemBuilder: (context, _) => Icon(
                                                                          Icons.star,
                                                                          color: Colors.amber,
                                                                        ), onRatingUpdate: (double rating) {
                                                                        print(rating);
                                                                      },
                                                                      ),
                                                                      Text(
                                                                        '(${_exploreResListData[index].review})',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              ScreenUtil().setSp(12.0),
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
                                                                  margin: EdgeInsets.only(
                                                                      right: ScreenUtil()
                                                                          .setWidth(
                                                                              5),
                                                                      bottom:
                                                                          ScreenUtil().setWidth(5)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        (() {
                                                                      if (_exploreResListData[index].vendorType ==
                                                                          'veg') {
                                                                        return Row(
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
                                                                        );
                                                                      } else if (_exploreResListData[index].vendorType ==
                                                                          'non_veg') {
                                                                        return Row(
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
                                                                        );
                                                                      } else if (_exploreResListData[index].vendorType ==
                                                                          'all') {
                                                                        return Row(
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))
                      : !_isSyncing
                          ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  width: 150,
                                  height:180,
                                  image: AssetImage('images/ic_no_rest.png'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10)),
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
                          : Container()),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CommenRes>> callAddRemoveFavorite(int? vegRestId) async {
    CommenRes response;
    try{
      Constants.onLoading(context);
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response  = await RestClient(RetroApi().dioData()).favorite(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Constants.checkNetwork().whenComplete(() => callExploreRestaurants());

        setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }

    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

}
