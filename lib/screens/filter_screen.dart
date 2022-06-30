import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';


class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> _listSortBy = [];
  List<String> _listQuickFilter = [];


  List<AllCuisineData> _allCuisineListData = [];

  List<String> selectedCuisineListId = [];

  int? radioindex;
  int? radioQuickFilter;
  int? radioCousines;

  @override
  void initState() {
    super.initState();


/*
    progressDialog.style(
      message: Languages.of(context).labelPleaseWait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Color(Constants.colorTheme)),
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

    getSortByList();
    getQuickFilterList();
    Constants.checkNetwork().whenComplete(() => callAllCuisine());
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
    // ScreenUtil.init(context,designSize: Size(defaultScreenWidth, defaultScreenHeight) ,allowFontScaling: true);


    return SafeArea(
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
                        'Cancel',
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
                    if (radioindex == 0) {
                      print('High To Low');
                    } else if (radioindex == 1) {
                      print('Low To High');
                    }
                    if (radioQuickFilter == 0) {
                      print('Veg re');
                    } else if (radioQuickFilter == 1) {
                      print('Non Veg re');
                    } else if (radioQuickFilter == 2) {
                      print('Both Non Veg re');
                    }
                    selectedCuisineListId.clear();
                    for (int i = 0; i < _allCuisineListData.length; i++) {
                      if (_allCuisineListData[i].isChecked) {
                        selectedCuisineListId
                            .add(_allCuisineListData[i].id.toString());
                      }
                    }
                    String commaSeparated = selectedCuisineListId.join(', ');
                    print('Selected cuisine Id : ---' + commaSeparated);
                  },
                  child: Container(
                    color: Constants.colorTheme,
                    child: Center(
                      child: Text(
                        'Apply Filter',
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
          appbarTitle: 'Filter',
          strButtonTitle: 'Clear',
          btnColor: Constants.colorTheme,
          onBtnPress: () {
            selectedCuisineListId.clear();
            radioindex = null;
            radioQuickFilter = null;
            Constants.checkNetwork().whenComplete(() => callAllCuisine());
          },
        ),
        backgroundColor: Color(0xFFFAFAFA),
        body: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(20),
              right: ScreenUtil().setWidth(10)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sorting By',
                  style: TextStyle(
                      fontFamily: Constants.appFont,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                  child: Container(
                    height: ScreenUtil().setHeight(60),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 5,
                      mainAxisSpacing: 5,
                      children: List.generate(_listSortBy.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            changeIndex(index);
                          },
                          child: Row(
                            children: [
                              radioindex == index
                                  ? getChecked()
                                  : getunChecked(),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10)),
                                child: Text(
                                  _listSortBy[index],
                                  style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      fontSize: ScreenUtil().setSp(14)),
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
                  'Quick Filters',
                  style: TextStyle(
                      fontFamily: Constants.appFont,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                  child: Container(
                    height: ScreenUtil().setHeight(100),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 5,
                      children: List.generate(_listQuickFilter.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            changeQuickFilterIndex(index);
                          },
                          child: Row(
                            children: [
                              radioQuickFilter == index
                                  ? getChecked()
                                  : getunChecked(),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(10)),
                                  child: Text(
                                    _listQuickFilter[index],
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        fontSize: ScreenUtil().setSp(14)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                  'Cousines',
                  style: TextStyle(
                      fontFamily: Constants.appFont,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                    child: Container(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 5,
                        mainAxisSpacing: 10,
                        children:
                            List.generate(_allCuisineListData.length, (index) {
                          return InkWell(
                            onTap: () {
                              // changeCousinesIndex(index);
                              setState(() {
                                _allCuisineListData[index].isChecked =
                                    !_allCuisineListData[index].isChecked;
                              });
                            },
                            child: Row(
                              children: [
                                _allCuisineListData[index].isChecked
                                    ? getChecked()
                                    : getunChecked(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(10)),
                                  child: Text(
                                    _allCuisineListData[index].name!,
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        fontSize: ScreenUtil().setSp(14)),
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
    );
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: ScreenUtil().setHeight(25),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: ScreenUtil().setHeight(15),
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: ScreenUtil().setHeight(25),
      decoration: myBoxDecorationChecked(true, Constants.colorWhite),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(
          Radius.circular(8.0) //                 <--- border radius here
          ),
    );
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

  void changeCousinesIndex(int index) {
    setState(() {
      radioCousines = index;
    });
  }

  void getSortByList() {
    _listSortBy.clear();
    _listSortBy.add('High To Low');
    _listSortBy.add('Low To High');
  }

  void getQuickFilterList() {
    _listQuickFilter.clear();
    _listQuickFilter.add('Veg. Restaurant');
    _listQuickFilter.add('Non Veg. Restaurant');
    _listQuickFilter.add('Both Veg. & Non Veg.');
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
        setState(() {
          _allCuisineListData.addAll(response.data!);
        });
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

}
