import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/address/add_address_screen.dart';
import 'package:mealup/screens/address/edit_address_screen.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManageYourLocation extends StatefulWidget {
  @override
  _ManageYourLocationState createState() => _ManageYourLocationState();
}

class _ManageYourLocationState extends State<ManageYourLocation> {
  List<UserAddressListData> _userAddressList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isSyncing = false;
  late Position currentLocation;
  double _currentLatitude = 0.0;

  double _currentLongitude = 0.0;
  BitmapDescriptor? _markerIcon;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
    getUserLocation();
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor =
          await _bitmapDescriptorFromSvgAsset(context, 'images/ic_marker.svg');
      //  _updateBitmap(bitmapDescriptor);
      setState(() {
        _markerIcon = bitmapDescriptor;
      });
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width =
        32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    print('selectedLat $_currentLatitude');
    print('selectedLng $_currentLongitude');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbarWithClrBtn(
          appbarTitle: Languages.of(context)!.labelManageYourLocation,
          strButtonTitle: '+ ${Languages.of(context)!.labelAddAddress}',
          btnColor: Constants.colorTheme,
          onBtnPress: () {
            if (_currentLongitude != 0.0) {
              Navigator.pop(context);
              Navigator.of(context).push(Transitions(
                  transitionType: TransitionType.fade,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  // widget: HereMapDemo())
                  widget: AddAddressScreen(
                    isFromAddAddress: true,
                    currentLat: _currentLatitude,
                    currentLong: _currentLongitude,
                    marker: _markerIcon,
                  )));
            }
          },
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
                      padding:
                          const EdgeInsets.only(top: 10, left: 15, right: 10),
                      child: _userAddressList.length == 0
                          ? !_isSyncing
                              ? Container(
                                  width: ScreenUtil().screenWidth,
                                  height: ScreenUtil().screenHeight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        width: ScreenUtil().setWidth(100),
                                        height: ScreenUtil().setHeight(100),
                                        image:
                                            AssetImage('images/ic_no_rest.png'),
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
                              : Container()
                          : SingleChildScrollView(
                              child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _userAddressList.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Column(
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
                                                  fontFamily: Constants.appFont,
                                                  color: Constants.colorBlack),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 10),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(Transitions(
                                                transitionType:
                                                    TransitionType.fade,
                                                curve: Curves.bounceInOut,
                                                reverseCurve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                // widget: HereMapDemo())
                                                widget: EditAddressScreen(
                                                  addressId:
                                                      _userAddressList[index]
                                                          .id,
                                                  latitude:
                                                      _userAddressList[index]
                                                          .lat,
                                                  longitude:
                                                      _userAddressList[index]
                                                          .lang,
                                                  strAddress:
                                                      _userAddressList[index]
                                                          .address,
                                                  strAddressType:
                                                      _userAddressList[index]
                                                          .type,
                                                  userId:
                                                      _userAddressList[index]
                                                          .userId,
                                                  marker: _markerIcon,
                                                ),
                                              ));
                                            },
                                            child: Text(
                                              Languages.of(context)!
                                                  .labelEditAddress,
                                              style: TextStyle(
                                                  color: Constants.colorBlue,
                                                  fontFamily: Constants.appFont,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 50),
                                            child: GestureDetector(
                                              onTap: () {
                                                showRemoveAddressdialog(
                                                    _userAddressList[index].id,
                                                    _userAddressList[index]
                                                        .address,
                                                    _userAddressList[index]
                                                        .type);
                                              },
                                              child: Text(
                                                Languages.of(context)!
                                                    .labelRemoveThisAddress,
                                                style: TextStyle(
                                                    color: Constants.colorLike,
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

  showRemoveAddressdialog(int? id, String? address, String? type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 20),
              child: Container(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelRemoveAddress,
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
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 30, bottom: 8),
                          child: Text(
                            type ?? '',
                            style: TextStyle(
                                fontFamily: Constants.appFontBold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'images/ic_map.svg',
                              width: 18,
                              height: 18,
                              color: Constants.colorTheme,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 2),
                                child: Text(
                                  address!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: Constants.appFont,
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
                                    callRemoveAddress(id);
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

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try {
      _userAddressList.clear();
      setState(() {
        _isSyncing = true;
      });

      response = await RestClient(RetroApi().dioData()).userAddress();
      print(response.success);
      setState(() {
        _isSyncing = false;
      });

      if (response.success!) {
        setState(() {
          _userAddressList.addAll(response.data!);
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

  Future<BaseModel<CommenRes>> callRemoveAddress(int? id) async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).removeAddress(id);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        Navigator.pop(context);
        callGetUserAddresses();
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
