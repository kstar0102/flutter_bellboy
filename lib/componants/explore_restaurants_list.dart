import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/utils/constants.dart';


class ExploreRestaurantsList extends StatelessWidget {

  final Function onSaveItem;
  ExploreRestaurantsList({required this.onSaveItem});


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
   // ScreenUtil.init(context,designSize: Size(defaultScreenWidth, defaultScreenHeight) ,allowFontScaling: true);

    return ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 15,
        itemBuilder: (BuildContext context, int index) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(10), right: ScreenUtil().setWidth(5), bottom: ScreenUtil().setHeight(5)),
          child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  'images/ic_pizza.jpg',
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setHeight(100),
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10), top: ScreenUtil().setHeight(10)),
                              child: Text(
                                'Veg Explorer',
                                style: TextStyle(
                                    fontFamily:
                                    Constants.appFontBold,
                                    fontSize: ScreenUtil().setSp(16)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(10), top: ScreenUtil().setHeight(10)),
                              child: GestureDetector(
                                onTap: onSaveItem as void Function()?,
                                child: SvgPicture.asset(
                                  'images/ic_filled_heart.svg',
                                  color: Constants.colorLike,
                                  height: ScreenUtil().setHeight(20),
                                  width: ScreenUtil().setWidth(20),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(10),right: ScreenUtil().setWidth(40)),
                        child: Text(
                          'Chinese, North Indian',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: Constants.appFont,
                              color: Constants.colorGray,
                              fontSize: ScreenUtil().setSp(12)),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),

                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 3),
                                  child: SvgPicture.asset(
                                    'images/ic_map.svg',
                                    width: ScreenUtil().setWidth(10),
                                    height: ScreenUtil().setHeight(10),
                                  ),
                                ),
                                Text(
                                  '3.2km far away',
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(12),
                                    fontFamily: Constants.appFont,
                                    color: Color(0xFF132229),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8,top: 3),
                                  child: Row(
                                    children: [
                                      RatingBar.builder(
                                        initialRating: 3.5,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        itemSize: ScreenUtil().setWidth(12),
                                        allowHalfRating: true,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Constants.colorTheme,
                                        ), onRatingUpdate: (double rating) {
                                        print(rating);
                                      },
                                      ),
                                      Text(
                                        '(998)',
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(12),
                                          fontFamily: Constants.appFont,
                                          color: Color(0xFF132229),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: ScreenUtil().setWidth(15)),
                            child: Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(2)),
                                    child: SvgPicture.asset(
                                      'images/ic_veg.svg',
                                      height: ScreenUtil().setHeight(10),
                                      width: ScreenUtil().setWidth(10),
                                    ),
                                  ),
                                  Visibility(
                                    visible: true,
                                    child: SvgPicture.asset(
                                      'images/ic_non_veg.svg',
                                      height: ScreenUtil().setHeight(10),
                                      width: ScreenUtil().setWidth(10),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }


}