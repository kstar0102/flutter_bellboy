import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/model/balance.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/wallet/wallet_add_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

TextEditingController searchController = new TextEditingController();

class _WalletScreenState extends State<WalletScreen> {
  bool _isSyncing = false;
  List<Data> _searchResult = [];
  List<Data> dataList = [];
  List<Data> filterList = [];
  String? balance = '';
  DateTime? _selectedDate;
  DateTime? _date;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);
    _date = today;
    Constants.checkNetwork().whenComplete(() => getUserBalanceHistory());
    Constants.checkNetwork().whenComplete(() => getWalletBalance());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => getUserBalanceHistory());
    Constants.checkNetwork().whenComplete(() => getWalletBalance());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context)!.walletSetting,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: SmartRefresher(
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
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                    margin: EdgeInsets.only(top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Constants.colorWhite,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Languages.of(context)!.walletBalance,
                                                  style: TextStyle(
                                                      color: Constants.colorBlack,
                                                      fontFamily: Constants.appFont,
                                                      fontSize: 14),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)}$balance",
                                                  style: TextStyle(
                                                      color: Constants.colorBlack,
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: 26),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.add_circle,
                                                    size: 30,
                                                    color: Colors.green,
                                                  )),
                                              onTap: () async {
                                                Map? results = await Navigator.of(context).push(
                                                    Transitions(
                                                        transitionType: TransitionType.none,
                                                        curve: Curves.bounceInOut,
                                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                        widget: WalletAddScreen()));
                                                if (results != null &&
                                                    results.containsKey('selection')) {
                                                  setState(() {
                                                    _onRefresh();
                                                  });
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.02),
                                              borderRadius: BorderRadius.all(Radius.circular(20))),
                                          child: TextField(
                                            style: TextStyle(color: Colors.black, fontSize: 14),
                                            controller: searchController,
                                            onChanged: onSearchTextChanged,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              fillColor:
                                                  Constants.colorGray.withOpacity(0.3),
                                              filled: true,
                                              hintText: 'Search here',
                                              hintStyle: TextStyle(
                                                  color: Constants.colorBlack,
                                                  fontSize: 14,
                                                  fontFamily: Constants.appFont),
                                              suffixIcon: Icon(Icons.search,
                                                  color: Constants.colorBlack),
                                              // suffixIcon: IconButton(
                                              //   onPressed: () => this._clearSearch(),
                                              //   icon: Icon(Icons.clear, color: Palette.bonjour),
                                              // ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Languages.of(context)!.transactionHistory,
                                              style: TextStyle(
                                                  color: Constants.colorBlack,
                                                  fontFamily: Constants.appFontBold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              _selectedDate != null ? 'Showing data of : ' + _selectedDate!.year.toString() + '-' + _selectedDate!.month.toString() + '-' + _selectedDate!.day.toString() : '',
                                              style: TextStyle(
                                                  color: Constants.colorGray,
                                                  fontFamily: Constants.appFont,
                                                  fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: MaterialButton(
                                          onPressed: showPicker,
                                          child: Text(
                                            'Filter',
                                            style: TextStyle(
                                                color:Constants.colorWhite,
                                                fontFamily: Constants.appFontBold,
                                                fontSize: 16),
                                          ),
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  filterList.length == 0 ?
                                  Flexible(child: _searchResult.length != 0 ||
                                      searchController.text.isNotEmpty
                                      ? _searchResult.isNotEmpty
                                      ? ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    itemCount: _searchResult.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  _searchResult[index].type ==
                                                      'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: _searchResult[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _searchResult[index]
                                                          .vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : _searchResult[index]
                                                          .vendorName!,
                                                      style: TextStyle(
                                                          color: Constants.colorBlack,
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      _searchResult[index].order ==
                                                          null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${_searchResult[index].order!.orderId}',
                                                      style: TextStyle(
                                                          color:
                                                              Constants.colorGray,
                                                          fontFamily:
                                                          Constants.appFont,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${_searchResult[index].type == 'deposit' ? 0x2B : 0x2D} ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)}${_searchResult[index].amount}",
                                                style: TextStyle(
                                                    color:
                                                    _searchResult[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.appFontBold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _searchResult[index].date!,
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorGray,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${_searchResult[index].paymentDetails != null ? _searchResult[index].paymentDetails!.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorBlack,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                      : Container(
                                      margin: EdgeInsets.only(top: 30),
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        child: Text('Not Found'),
                                      ))
                                      : dataList.isNotEmpty
                                      ? ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    itemCount: dataList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  dataList[index].type == 'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: dataList[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      dataList[index].vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : dataList[index]
                                                          .vendorName!,
                                                      style: TextStyle(
                                                          color: Constants.colorBlack,
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      dataList[index].order == null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${dataList[index].order!.orderId}',
                                                      style: TextStyle(
                                                          color:
                                                              Constants.colorGray,
                                                          fontFamily:
                                                          Constants.appFont,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${dataList[index].type == 'deposit' ? '\uFF0B' : '\u2212'} ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)}${dataList[index].amount}",
                                                style: TextStyle(
                                                    color: dataList[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.appFontBold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                dataList[index].date!,
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorGray,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${dataList[index].paymentDetails != null ? dataList[index].paymentDetails!.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorBlack,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                      : Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.topCenter,
                                    child: Text('It seems you have no Transactions'),
                                  )
                                  ) :
                                  Flexible(
                                      child: ListView.separated(
                                    separatorBuilder: (BuildContext context, int index) =>
                                    const Divider(color: Colors.grey,),
                                    itemCount: filterList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  filterList[index].type == 'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: filterList[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      filterList[index].vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : filterList[index].vendorName!,
                                                      style: TextStyle(
                                                          color: Constants.colorBlack,
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      filterList[index].order == null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${filterList[index].order!.orderId}',
                                                      style: TextStyle(
                                                          color:
                                                              Constants.colorGray,
                                                          fontFamily:
                                                          Constants.appFont,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${filterList[index].type == 'deposit' ? '\uFF0B' : '\u2212'} ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)}${filterList[index].amount}",
                                                style: TextStyle(
                                                    color: filterList[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.appFontBold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filterList[index].date!,
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorGray,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${filterList[index].paymentDetails != null ? filterList[index].paymentDetails!.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Constants.colorBlack,
                                                    fontFamily: Constants.appFont,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    dataList.forEach((v) {
      if (v.date!.contains(text)  || v.amount!.contains(text))
        _searchResult.add(v);
      if(v.vendorName != null){
        if(v.vendorName!.contains(text)){
          _searchResult.add(v);
        }
      }
    });
    filterList.clear();
    setState(() {});
  }

  /* getDataList(BuildContext context) {
    return _searchResult.length != 0 || searchController.text.isNotEmpty
        ?ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
      const Divider(
        color: Colors.grey,
      ),
      itemCount: _searchResult.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "OID: ",
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                    Text(
                      _searchResult[index].orderId,
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "\u0024${_searchResult[index].amount}",
                  style: TextStyle(
                      color: Palette.green,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              _searchResult[index].name,
              style: TextStyle(
                  color: Palette.switchs,
                  fontFamily: "ProximaBold",
                  fontSize: 16),
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Text(
                  _searchResult[index].date,
                  style: TextStyle(
                      color: Palette.switchs,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },)
        :ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
      const Divider(
        color: Colors.grey,
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "OID: ",
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                    Text(
                      dataList[index].orderId,
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "\u0024${dataList[index].amount}",
                  style: TextStyle(
                      color: Palette.green,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              dataList[index].name,
              style: TextStyle(
                  color: Palette.switchs,
                  fontFamily: "ProximaBold",
                  fontSize: 16),
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Text(
                  dataList[index].date,
                  style: TextStyle(
                      color: Palette.switchs,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },);
  }*/

  Future<BaseModel<Balance>> getUserBalanceHistory() async {
    Balance response;
    try{
      dataList.clear();
      setState(() {
        _isSyncing = true;
      });
      response  = await RestClient(RetroApi().dioData()).getBalanceHistory();
      setState(() {
        _isSyncing = false;
        dataList.addAll(response.data!);
      });
    }catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> getWalletBalance() async {
    CommenRes response;
    try{
      dataList.clear();
      setState(() {
        _isSyncing = true;
      });
      response  = await RestClient(RetroApi().dioData()).getWalletBalance();
      setState(() {
        _isSyncing = false;
        balance = response.data;
      });
    }catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }


  showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        setState(() {
                          _date = _selectedDate;
                          filterList.clear();
                          for(int i=0; i <dataList.length; i++){
                            String month, day, year;
                            if(_selectedDate!.month.toString().length == 1){
                              month = '0${_selectedDate!.month.toString()}';
                            }else{
                              month = _selectedDate!.month.toString();
                            }
                            if(_selectedDate!.day.toString().length == 1){
                              day = '0${_selectedDate!.day.toString()}';
                            }else{
                              day = _selectedDate!.day.toString();
                            }
                            year = _selectedDate!.year.toString();
                            String s = year + '-' + month + '-' + day;
                            if(s  == dataList[i].date)
                              filterList.add(dataList[i]);
                          }

                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Container(
                    height: 200.0,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Flexible(
                          flex: 8,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: _date,

                            onDateTimeChanged: (DateTime dateTime) {
                              _selectedDate = dateTime;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }
}
