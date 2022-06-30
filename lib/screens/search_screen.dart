import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/model/search_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<VendorListData> vendorList = [];
  List<CuisineListData> cuisineList = [];
  List<String?> restaurantsFood = [];

  TextEditingController searchController = new TextEditingController();
  List<String> searchHistoryList = [];

  @override
  void initState() {
    super.initState();
    if (SharedPreferenceUtil.getStringList(Constants.recentSearch).length != 0) {
      searchHistoryList = SharedPreferenceUtil.getStringList(Constants.recentSearch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 5),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 30,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: onSearchTextChanged,
                                    onEditingComplete: onEditCompleted,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10),
                                      suffixIcon: IconButton(
                                        onPressed: () => {},
                                        icon: SvgPicture.asset(
                                          'images/search.svg',
                                          width: 20,
                                          height: 20,
                                          color: Constants.colorGray,
                                        ),
                                      ),
                                      hintText: Languages.of(context)!.labelSearchSomething,
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontFamily: Constants.appFont,
                                        color: Constants.colorGray,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFFeeeeee),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              searchHistoryList.length != 0
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20, left: 15, right: 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)!.labelRecentlySearches,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: Constants.appFont,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    searchHistoryList.clear();
                                                  });
                                                },
                                                child: Text(
                                                  Languages.of(context)!.labelClear,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: Constants.appFont,
                                                      color: Constants.colorTheme),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: searchHistoryList.length,
                                          itemBuilder: (BuildContext context, int index) => InkWell(
                                            onTap: () {
                                              searchController.text = searchHistoryList[index];
                                              onSearchTextChanged(searchController.text);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15.0, top: 15),
                                              child: Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        WidgetSpan(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(right: 10),
                                                            child: SvgPicture.asset(
                                                              'images/ic_clock.svg',
                                                              width: 15,
                                                              height: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                            text: searchHistoryList[index],
                                                            style: TextStyle(
                                                                color: Constants.colorBlack,
                                                                fontFamily: Constants.appFont,
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  Languages.of(context)!.labelSearchByFood,
                                  style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                                ),
                              ),
                              cuisineList.length == 0
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
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SizedBox(
                                        height: ScreenUtil().setHeight(147),
                                        width: ScreenUtil().setWidth(114),
                                        child: ListView.builder(
                                          physics: ClampingScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: cuisineList.length,
                                          itemBuilder: (BuildContext context, int index) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(Transitions(
                                                    transitionType: TransitionType.none,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                    widget: SingleCuisineDetailsScreen(
                                                      cuisineId: vendorList[index].id,
                                                      strCuisineName: cuisineList[index].name,
                                                    )));
                                              },
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    child: CachedNetworkImage(
                                                      height: 110,
                                                      width: 110,
                                                      imageUrl: cuisineList[index].image!,
                                                      fit: BoxFit.cover,
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
                                                    child: Center(
                                                      child: Text(
                                                        cuisineList[index].name!,
                                                        style: TextStyle(
                                                          fontFamily: Constants.appFontBold,
                                                          fontSize: ScreenUtil().setSp(16.0),
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
                              Padding(
                                padding: const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  Languages.of(context)!.labelSearchByTopBrands,
                                  style: TextStyle(fontSize: 18.0, fontFamily: Constants.appFont),
                                ),
                              ),
                              Container(
                                height: ScreenUtil().setHeight(220),
                                child: (() {
                                  if (vendorList.length == 0) {
                                    return Container(
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
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: GridView.builder(
                                        scrollDirection: Axis.horizontal,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: ScreenUtil().screenWidth /
                                              1.1, // <== change the height to fit your needs
                                        ),
                                        itemCount: vendorList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: ScreenUtil().setWidth(220),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    Transitions(
                                                      transitionType: TransitionType.fade,
                                                      curve: Curves.bounceInOut,
                                                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                      widget: RestaurantsDetailsScreen(
                                                        restaurantId: vendorList[index].id,
                                                        isFav: false,
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
                                                          height: 100,
                                                          width: 100,
                                                          imageUrl: vendorList[index].image!,
                                                          fit: BoxFit.fill,
                                                          placeholder: (context, url) =>
                                                              SpinKitFadingCircle(
                                                                  color:
                                                                      Constants.colorTheme),
                                                          errorWidget: (context, url, error) =>
                                                              Container(
                                                            child: Center(
                                                                child: Image.asset(
                                                                    'images/noimage.png')),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: ScreenUtil().screenWidth / 1.7,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
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
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          vendorList[index].name!,
                                                                          style: TextStyle(
                                                                              fontFamily: Constants
                                                                                  .appFontBold,
                                                                              fontSize: ScreenUtil()
                                                                                  .setSp(16.0)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    alignment: Alignment.topLeft,
                                                                    child: Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                              left: 10),
                                                                      child: Text(
                                                                        getRestaurantsFood(index),
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.appFont,
                                                                            color: Constants
                                                                                .colorGray,
                                                                            fontSize: ScreenUtil()
                                                                                .setSp(12.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment: Alignment.topLeft,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.only(left: 10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child: Row(
                                                                        children: [
                                                                          RatingBar.builder(
                                                                            initialRating:
                                                                                vendorList[index]
                                                                                    .rate
                                                                                    .toDouble(),
                                                                            minRating: 1,
                                                                            ignoreGestures: true,
                                                                            direction:
                                                                                Axis.horizontal,
                                                                            itemSize: ScreenUtil()
                                                                                .setWidth(12),
                                                                            allowHalfRating: true,
                                                                            itemBuilder:
                                                                                (context, _) =>
                                                                                    Icon(
                                                                              Icons.star,
                                                                              color: Constants.colorTheme,
                                                                            ),
                                                                            onRatingUpdate:
                                                                                (double rating) {
                                                                              print(rating);
                                                                            },
                                                                          ),
                                                                          Text(
                                                                            '(${vendorList[index].review})',
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
                                                                                right: 0),
                                                                        child: vendorList[index]
                                                                                    .vendorType ==
                                                                                'veg'
                                                                            ? Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding:
                                                                                        const EdgeInsets
                                                                                                .only(
                                                                                            right:
                                                                                                2),
                                                                                    child:
                                                                                        SvgPicture
                                                                                            .asset(
                                                                                      'images/ic_veg.svg',
                                                                                      height: ScreenUtil()
                                                                                          .setHeight(
                                                                                              10.0),
                                                                                      width: ScreenUtil()
                                                                                          .setHeight(
                                                                                              10.0),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding:
                                                                                        const EdgeInsets
                                                                                                .only(
                                                                                            right:
                                                                                                2),
                                                                                    child:
                                                                                        SvgPicture
                                                                                            .asset(
                                                                                      'images/ic_veg.svg',
                                                                                      height: ScreenUtil()
                                                                                          .setHeight(
                                                                                              10.0),
                                                                                      width: ScreenUtil()
                                                                                          .setHeight(
                                                                                              10.0),
                                                                                    ),
                                                                                  ),
                                                                                  SvgPicture.asset(
                                                                                    'images/ic_non_veg.svg',
                                                                                    height: ScreenUtil()
                                                                                        .setHeight(
                                                                                            10.0),
                                                                                    width: ScreenUtil()
                                                                                        .setHeight(
                                                                                            10.0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (vendorList.isNotEmpty) {
      for (int j = 0; j < vendorList[index].cuisine!.length; j++) {
        restaurantsFood.add(vendorList[index].cuisine![j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" , ");
  }

  Future<BaseModel<SearchListModel>> onSearchTextChanged(String text) async {
    SearchListModel response;
    try {
      cuisineList.clear();
      vendorList.clear();
      // progressDialog.show();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
        'name': text,
      };
      response = await RestClient(RetroApi().dioData()).search(body);
      print(response.success);
      // Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          if (response.data!.vendor!.length != 0) {
            vendorList.clear();
            vendorList.addAll(response.data!.vendor!);
          } else {
            vendorList.clear();
          }

          if (response.data!.cuisine!.length != 0) {
            cuisineList.clear();
            cuisineList.addAll(response.data!.cuisine!);
          } else {
            cuisineList.clear();
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

  void onEditCompleted() {
    setState(() {
      if (searchHistoryList.length <= 2) {
        searchHistoryList.add(searchController.text);
      } else {
        searchHistoryList.removeAt(0);
        searchHistoryList.add(searchController.text);
      }
    });
    SharedPreferenceUtil.putStringList(Constants.recentSearch, searchHistoryList);
    print('=====================================HISTORY+++++++++++++++++' +
        searchHistoryList.toString());
  }
}
