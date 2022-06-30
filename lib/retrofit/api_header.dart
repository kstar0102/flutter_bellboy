import 'package:dio/dio.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/preference_utils.dart';

class RetroApi {

  Dio dioData()
  {
    final dio = Dio();
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.headers["Authorization"] = "Bearer" + " " + PreferenceUtils.getString(Constants.headerToken); // config your dio headers globally
    dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 3000;
    return dio;
  }
}