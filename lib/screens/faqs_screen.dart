import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/model/faq_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class FAQsScreen extends StatefulWidget {
  @override
  _FAQsScreenState createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  List<FAQListData> _faqListData = [];
  // RefreshController _refreshController =
  // RefreshController(initialRefresh: false);
  bool _isSyncing = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callFAQListData());
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/ic_background_image.png'),
              fit: BoxFit.cover,
            )),
        child: Scaffold(
          key: _scaffoldKey ,
          appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context)!.labelFactAQuestions,
          ),
          body: ModalProgressHUD(
            inAsyncCall: _isSyncing,
            child: _faqListData.length == 0
                ? Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    image: AssetImage('images/ic_nodata.png'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(10)),
                    child: Text(
                      'No Data Available.',
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
                : ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _faqListData.length,
              itemBuilder: (context, i) {
                return new ExpansionTile(
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  trailing: Container(
                    child:
                    SvgPicture.asset('images/ic_bottom_arrow.svg'),
                  ),
                  title: new Text(
                    _faqListData[i].question!,
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w100,
                      fontFamily: Constants.appFontBold,
                    ),
                  ),
                  children: <Widget>[
                    new Column(
                      children: _buildExpandableContent(new FoodItem(
                        _faqListData[i].question,
                        [_faqListData[i].answer],
                      )),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<FAQListModel>> callFAQListData() async {
    FAQListModel response;
    try{
      setState(() {
        _isSyncing = true;
      });
      response  = await RestClient(RetroApi().dioData()).faq();
      setState(() {
        _isSyncing = false;
      });
      print(response.success);
      if (response.success!) {
        setState(() {
          _faqListData.addAll(response.data!);
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

_buildExpandableContent(FoodItem vehicle) {
  List<Widget> columnContent = [];

  for (String? content in vehicle.contents)
    columnContent.add(
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 5, bottom: 20),
        child: Text(
          content!,
          style: new TextStyle(
              fontSize: 14.0,
              color: Constants.colorGray,
              fontFamily: Constants.appFont),
        ),
      ),
    );

  return columnContent;
}

class FoodItem {
  final String? title;
  List<String?> contents = [];

  FoodItem(this.title, this.contents);
}
