import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/promoCode_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';


class OfferScreen extends StatefulWidget {
  final double? orderAmount;
  final int? restaurantId;

  const OfferScreen({Key? key, this.orderAmount, this.restaurantId})
      : super(key: key);

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {

  List<PromoCodeListData> _listPromoCode = [];
  List<PromoCodeListData> _searchListPromoCode = [];
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    Constants.checkNetwork()
        .whenComplete(() => callGetPromocodeListData(widget.restaurantId));
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
        appbarTitle: Languages.of(context)!.labelFoodOfferCoupons,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Container(
              color: Color(0xfff6f6f6),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                          suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: SvgPicture.asset(
                              'images/search.svg',
                              width: ScreenUtil().setWidth(20),
                              height: ScreenUtil().setHeight(20),
                              color: Constants.colorGray,
                            ),
                          ),
                          hintText:
                              Languages.of(context)!.labelSearchRestOrCoupon,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
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
                  Expanded(
                    flex: 10,
                    child: _listPromoCode.length != 0
                        ? GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            padding: EdgeInsets.all(10),
                            children: _searchListPromoCode.length != 0 || _searchController.text.isNotEmpty
                                ? List.generate(_searchListPromoCode.length,
                                    (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _searchListPromoCode[
                                                              index]
                                                          .image!,
                                                  fit: BoxFit.cover,
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
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                _searchListPromoCode[index]
                                                    .name!,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                _searchListPromoCode[index]
                                                    .promoCode!,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _searchListPromoCode[index]
                                                  .displayText!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Constants.colorTheme),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                '${Languages.of(context)!.labelValidUpTo} ${_searchListPromoCode[index].startEndDate!.substring(_searchListPromoCode[index].startEndDate!.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color:
                                                        Constants.colorGray,
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                : List.generate(_listPromoCode.length, (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _listPromoCode[index]
                                                          .image!,
                                                  fit: BoxFit.cover,
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
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                _listPromoCode[index].name!,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                _listPromoCode[index].promoCode!,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _listPromoCode[index].displayText!,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Constants.colorTheme),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                '${Languages.of(context)!.labelValidUpTo} ${_listPromoCode[index].startEndDate!.substring(_listPromoCode[index].startEndDate!.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color:
                                                        Constants.colorGray,
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                          )
                        : Container(
                            width: ScreenUtil().screenWidth,
                            height: ScreenUtil().screenHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  width: 150,
                                  height: 180,
                                  image: AssetImage('images/ic_no_offer.png'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10),
                                  child: Text(
                                    Languages.of(context)!.labelNoOffer,
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
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }

  Future<BaseModel<PromoCodeModel>> callGetPromocodeListData(int? restaurantId) async {
    PromoCodeModel response;
    try{
      Constants.onLoading(context);
      response  = await  RestClient(RetroApi().dioData()).promoCode(restaurantId);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _listPromoCode.addAll(response.data!);
        });
      } else {
        Constants.toastMessage('Error while remove address');
      }

    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }


  void calculateDiscount(String discountType, int discount, int flatDiscount,
      int isFlat, double orderAmount) {
    double tempDisc = 0;
    if (discountType == 'percentage') {
      tempDisc = orderAmount * discount / 100;
      print('Temp Discount $tempDisc');
      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
        print('after flat disc add $tempDisc');
      }

      print('Grand Total = ${orderAmount - tempDisc}');
    } else {
      tempDisc = tempDisc + discount;

      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
      }
   print('Grand Total = ${orderAmount - tempDisc}');
    }

    Navigator.pop(context);
  }

  onSearchTextChanged(String text) async {
    _searchListPromoCode.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _listPromoCode.length; i++) {
      var item = _listPromoCode[i];

      if (item.name!.toLowerCase().contains(text.toLowerCase())) {
        _searchListPromoCode.add(item);
        _searchListPromoCode.toSet();
      }
    }

    setState(() {});
  }
}