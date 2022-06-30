import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mealup/model/TrackingModel.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/order_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/timeline.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackYourOrderScreen extends StatefulWidget {
  final int? orderId;
  final String? orderDate, orderTime, vendorName, vendorNumber, vendorImage;
  final double? shopLat, shopLong, currentLat, currentLong;

  const TrackYourOrderScreen({
    Key? key,
    this.orderId,
    this.orderDate,
    this.orderTime,
    this.shopLat,
    this.shopLong,
    this.currentLat,
    this.currentLong,
    this.vendorName,
    this.vendorNumber,
    this.vendorImage,
  }) : super(key: key);

  @override
  _TrackYourOrderScreenState createState() => _TrackYourOrderScreenState();
}

class _TrackYourOrderScreenState extends State<TrackYourOrderScreen> {
  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  late LatLng _initialCameraPosition;
  LatLng? destinationPosition;
  LatLng? driverPosition;
  late GoogleMapController _controller;
  Location _location = Location();

  late LocationData currentLocation;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  double? _currentLatitude;
  double? _currentLongitude;

  // double _shopLatitude;
  //double _shopLongitude;
  Timer? timer;
  int counter = 0;
  double? currentLat = 0;
  double? currentLang = 0;

  @override
  void initState() {
    // _center = LatLng(widget.currentLat, widget.currentLong);
    super.initState();
    getUserLocation().whenComplete(() {
      _add(
          widget.currentLat, widget.currentLong, 'images/ic_green_marker.svg', MarkerId('current'));
      _add(widget.shopLat, widget.shopLong, 'images/ic_marker.svg', MarkerId('shop'));
      _add(widget.shopLat, widget.shopLong, 'images/ic_driver_icon.svg', MarkerId('driver'));
      _createPolylines(widget.currentLat!, widget.currentLong!, widget.shopLat!, widget.shopLong!);
    });
    if (widget.currentLat != null && widget.currentLong != null) {
      _initialCameraPosition = LatLng(widget.currentLat!, widget.currentLong!);
      destinationPosition = LatLng(widget.shopLat!, widget.shopLong!);
      driverPosition = LatLng(22.30389, 70.80216);
    } else {
      _initialCameraPosition = LatLng(51.499020, -0.116410);
      getUserLocation();
    }

    if (mounted) {
      setState(() {
        timer = Timer.periodic(
            Duration(seconds: SharedPreferenceUtil.getInt(Constants.appSettingDriverAutoRefresh)),
            (t) {
          if (mounted) {
            setState(() {
              counter++;
              print("counter++:$counter");

              currentLat = _currentLatitude;
              currentLang = _currentLongitude;

              callStartTracking(widget.orderId);
            });
          } else {
            counter++;
            print("counter++:$counter");

            currentLat = _currentLatitude;
            currentLang = _currentLongitude;

            callStartTracking(widget.orderId);
          }
        });
      });
    } else {
      timer = Timer.periodic(
          Duration(seconds: SharedPreferenceUtil.getInt(Constants.appSettingDriverAutoRefresh)),
          (t) {
        setState(() {
          counter++;
          print("counter++:$counter");

          currentLat = _currentLatitude;
          currentLang = _currentLongitude;

          callStartTracking(widget.orderId);
        });
      });
    }
  }

  void _add(lat, long, icon, markerId) async {
    BitmapDescriptor bitmapDescriptor = await _bitmapDescriptorFromSvgAsset(context, '$icon');
    setState(() {});
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long,
      ),
      icon: bitmapDescriptor,
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // Create the polylines for showing the route between two places

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.androidKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black87,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 13),
        ),
      );
    });
  }

  Future getUserLocation() async {
    currentLocation = await _location.getLocation();
    _initialCameraPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    print('selectedLat $_currentLatitude');
    print('selectedLng $_currentLongitude');
    //_shopLatitude = widget.shopLat;
    // _shopLongitude = widget.shopLong;
  }

  Future<BaseModel<TrackingModel>> callStartTracking(int? orderId) async {
    TrackingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).tracking(orderId);
      print('stattracking fun inside');
      if (mounted) {
        setState(() {
          setMarker(counter, double.parse(response.data!.driverLat!),
              double.parse(response.data!.driverLang!));
        });
      } else {
        setMarker(counter, double.parse(response.data!.driverLat!),
            double.parse(response.data!.driverLang!));
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  setMarker(int counter, double lat, double lang) async {
    print("New counter:$counter // $lat , $lang");


      BitmapDescriptor bitmapDescriptorDriver =
          await _bitmapDescriptorFromSvgAsset(context, 'images/ic_driver_icon.svg');
      final marker =
          markers.values.toList().firstWhere((item) => item.markerId == MarkerId('driver'));

      Marker _marker = Marker(
        markerId: marker.markerId,
        position: LatLng(lat, lang),
        icon: bitmapDescriptorDriver,
      );

      if(mounted) {
        setState(() {
          //the marker is identified by the markerId and not with the index of the list
          markers[MarkerId('driver')] = _marker;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ApplicationToolbarWithClrBtn(
          appbarTitle: '',
          strButtonTitle: Languages.of(context)!.labelViewOrderDetails,
          btnColor: Constants.colorTheme,
          onBtnPress: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.fade,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: OrderDetailsScreen(
                  orderId: widget.orderId,
                  orderDate: widget.orderDate,
                  orderTime: widget.orderTime,
                )));
          },
        ),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _initialCameraPosition),
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                // markers: _createMarker(),
                // markers: _markers,
                markers: Set<Marker>.of(markers.values),
                // markers: Set<Marker>.of(_markers),
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Timeline(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          Languages.of(context)!.labelFoodBeingPrepared,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constants.appFont,
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        margin: EdgeInsets.only(left: 15, top: 15, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                Languages.of(context)!.labelFoodReadyPickup,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: Constants.appFont,
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                height: 70,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: CachedNetworkImage(
                                        height: ScreenUtil().setHeight(70),
                                        width: ScreenUtil().setWidth(70),
                                        imageUrl: widget.vendorImage!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            SpinKitFadingCircle(color: Constants.colorTheme),
                                        errorWidget: (context, url, error) => Container(
                                          child: Center(child: Image.asset('images/noimage.png')),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${widget.vendorName}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: Constants.appFontBold,
                                                        fontWeight: FontWeight.w900),
                                                  ),
                                                  Text(
                                                    '${widget.vendorNumber}',
                                                    style: TextStyle(
                                                        color: Constants.colorGray,
                                                        fontFamily: Constants.appFont),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                launch("tel://${widget.vendorNumber}");
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(
                                                    Icons.call,
                                                    color: Constants.colorWhite,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Constants.colorTheme),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          'Successfully Delivered',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constants.appFont,
                          ),
                        ),
                      ),
                    ],
                    indicators: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Constants.colorTheme),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Constants.colorTheme),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Constants.colorTheme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
