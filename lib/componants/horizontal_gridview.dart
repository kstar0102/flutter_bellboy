import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/utils/constants.dart';

class HorizontalGridview extends StatelessWidget {
  
  
  
  final String? strRestaurantsImageUrl,
      strRestaurantName,
      strRestaurantsFood,
      strFarAway,
      strTotalRating;
  final double? rating;
  final Function onCardClick;



  HorizontalGridview(
      {this.strRestaurantsImageUrl,
      this.strRestaurantName,
      this.strRestaurantsFood,
      this.strFarAway,
      this.strTotalRating,
      this.rating,
      required this.onCardClick});

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

    return Container(
      height: ScreenUtil().setHeight(220),
      child:
      GridView.count(
        childAspectRatio:0.35,
        crossAxisCount: 2,
        scrollDirection: Axis.horizontal,
        mainAxisSpacing: ScreenUtil().setWidth(10),
        children: List.generate(50, (index) {
          return Container(
            width: ScreenUtil().setWidth(220),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                onTap: onCardClick as void Function()?,
                child: Card(
                  margin: EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child:
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.asset(
                          strRestaurantsImageUrl!,
                          width: ScreenUtil().setWidth(100),
                          height: ScreenUtil().setHeight(100),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(180),
                        child: Container(
                          width: ScreenUtil().setWidth(180),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 10,),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            strRestaurantName!,
                                            style: TextStyle(
                                                fontFamily: Constants.appFontBold,
                                                fontSize: ScreenUtil().setSp(16.0)),
                                          ),
                                          SvgPicture.asset(
                                            'images/ic_filled_heart.svg',
                                            color: Constants.colorLike,
                                            height: ScreenUtil().setHeight(20.0),
                                            width: ScreenUtil().setWidth(20.0),
                                          )
                                        ],
                                      ),
                                    ),

                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(
                                          strRestaurantsFood!,
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

                              Container(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: SvgPicture.asset(
                                                'images/ic_map.svg',
                                                width: 10,
                                                height: 10,
                                              ),
                                            ),
                                            Text(
                                              strFarAway!,
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
                                                    fontSize: ScreenUtil().setSp(12.0),
                                                    fontFamily: Constants.appFont,
                                                    color: Color(0xFF132229),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Row(
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
        }),
      ),
    );
  }
}
