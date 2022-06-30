import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:mealup/utils/constants.dart';

class GooglePlacePicker extends StatefulWidget {
  const GooglePlacePicker({Key? key}) : super(key: key);

  @override
  _GooglePlacePickerState createState() => _GooglePlacePickerState();
}

class _GooglePlacePickerState extends State<GooglePlacePicker> {
  String mapKey = '';
  late Position currentLocation;
  late LatLng _center;

  @override
  void initState() {
    _center = LatLng(22.3039, 70.8022);
    getUserLocation();
    if (Platform.isIOS) {
      mapKey = Constants.iosKey;
    } else {
      mapKey = Constants.androidKey;
    }
   // showPlacePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Text('123'),
      body: PlacePicker(
        apiKey: mapKey,
        initialPosition: _center,
        hintText: "Find a place ...",
        searchingText: "Please wait ...",
        // selectText: "Select place",
        // outsideOfPickAreaText: "Place not in area",
        useCurrentLocation: true,
        selectInitialPosition: true,
        usePinPointingSearch: true,
        usePlaceDetailSearch: true,
        forceSearchOnZoomChanged: true,
        onPlacePicked: (result) {
          print('the result is ${result.formattedAddress}');
          // This will change the text displayed in the TextField
          if (result.formattedAddress!.isNotEmpty) {
            Map<String, dynamic> sendData = {
              'address': result.formattedAddress,
              'lat': result.geometry!.location.lat,
              'long': result.geometry!.location.lng,
            };
            setState(() {
              Navigator.pop(context, sendData);
            });
          }
        },
      ),
    );
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (mounted) {
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

}
