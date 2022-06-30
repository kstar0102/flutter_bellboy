import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/order_status.dart';
import 'package:mealup/model/single_order_details_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';


class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final String? orderDate, orderTime;

  const OrderDetailsScreen({Key? key, this.orderId, this.orderDate, this.orderTime})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {


  String? strOrderDate = '',
      strVendorName = '',
      strVendorAddress = '',
      strUserAddress = '',
      strUserName = '',
      strOrderStatus = 'PENDING',
      strOrderInvoiceId = '',
      strDeliveryPerson = '',
      strDeliveryPersonImage = '',
      strDeliveryCharge = '',
      strVendorDiscount;

  List<OrderItems> orderItemList = [];
  int subTotal = 0, couponPrice = 0, grandTotalAmount = 0;
  int? promocodeId;
  double taxAmount = 0;

  bool isAppliedCoupon = false,
      isPending = false,
      isTaxApplied = false,
      isVendorDiscount = false,
      isCanCancel = false;

  late Timer timer;
  int counter = 0;

  TextEditingController _textOrderCancelReason = new TextEditingController();
  TextEditingController _textRaiseRefundRequest = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();


    Constants.checkNetwork().whenComplete(() => callGetSingleOrderDetails(widget.orderId));

    timer = Timer.periodic(
        Duration(seconds: SharedPreferenceUtil.getInt(Constants.appSettingDriverAutoRefresh)), (t) {
      setState(() {
        counter++;
        print("counter++:$counter");

        Constants.checkNetwork().whenComplete(() => callGetOrderStatus());
      });
    });
  }

  showCancelOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    bottom: 0,
                    top: ScreenUtil().setHeight(20)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context)!.labelCancelOrder,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
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
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Text(
                        Languages.of(context)!.labelOrderCancelReason,
                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textOrderCancelReason,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: Languages.of(context)!.labelTypeOrderCancelReason,
                                border: InputBorder.none),
                            maxLines: 5,
                            style: TextStyle(
                                fontFamily: Constants.appFont,
                                fontSize: 16,
                                color:
                                  Constants.colorGray,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
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
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.appFontBold,
                                    color: Constants.colorGray),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                              child: GestureDetector(
                                onTap: () {
                                  if (_textOrderCancelReason.text.isNotEmpty) {
                                    Navigator.pop(context);
                                    Constants.checkNetwork().whenComplete(() => callCancelOrder(
                                        widget.orderId, _textOrderCancelReason.text));
                                  } else {
                                    Constants.toastMessage(
                                        Languages.of(context)!.labelPleaseEnterCancelReason);
                                  }
                                },
                                child: Text(
                                  Languages.of(context)!.labelYesCancelIt,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  showRaiseRefundRequest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    bottom: 0,
                    top: ScreenUtil().setHeight(20)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context)!.labelRaiseRefundRequest,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
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
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Text(
                        Languages.of(context)!.labelRaiseRefundRequestReason,
                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textRaiseRefundRequest,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: Languages.of(context)!.labelRaiseRefundRequestReason1,
                                border: InputBorder.none),
                            maxLines: 5,
                            style: TextStyle(
                                fontFamily: Constants.appFont,
                                fontSize: 16,
                                color:
                                  Constants.colorGray,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
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
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.appFontBold,
                                    color: Constants.colorGray),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                              child: GestureDetector(
                                onTap: () {
                                  if (_textRaiseRefundRequest.text.isNotEmpty) {
                                    Constants.checkNetwork().whenComplete(() => callRefundRequest(
                                        widget.orderId, _textRaiseRefundRequest.text));
                                  } else {
                                    Constants.toastMessage(
                                        Languages.of(context)!.labelPleaseEnterRaiseRefundReq);
                                  }
                                },
                                child: Text(
                                  Languages.of(context)!.labelYesRaiseIt,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbarWithClrBtn(
          appbarTitle: Languages.of(context)!.labelOrderDetails,
          strButtonTitle: isCanCancel ? Languages.of(context)!.labelCancelOrder : '',
          btnColor: Constants.colorLike,
          onBtnPress: () {
            showCancelOrderDialog();
            /*Constants.checkNetwork()
                .whenComplete(() => callCancelOrder(widget.orderId));*/
          },
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 20),
                            child: Text(
                              strOrderInvoiceId!,
                              style: TextStyle(fontFamily: Constants.appFont, fontSize: 25),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              (() {
                                    if (strUserAddress != null) {
                                      if (strOrderStatus == 'PENDING') {
                                        return '${Languages.of(context)!.labelOrderedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'APPROVE') {
                                        return '${Languages.of(context)!.labelAcceptedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'ACCEPT') {
                                        return '${Languages.of(context)!.labelOrderAccepted} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'REJECT') {
                                        return '${Languages.of(context)!.labelRejectedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'PICKUP') {
                                        return '${Languages.of(context)!.labelPickedUpOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'DELIVERED') {
                                        return '${Languages.of(context)!.labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}}';
                                      } else if (strOrderStatus == 'CANCEL') {
                                        return '${Languages.of(context)!.labelCanceledOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'COMPLETE') {
                                        return '${Languages.of(context)!.labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}';
                                      }
                                    } else {
                                      if (strOrderStatus == 'PENDING') {
                                        return '${Languages.of(context)!.labelOrderedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'APPROVE') {
                                        return '${Languages.of(context)!.labelAcceptedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'ACCEPT') {
                                        return '${Languages.of(context)!.labelOrderAccepted} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'REJECT') {
                                        return '${Languages.of(context)!.labelRejectedOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'PREPARE_FOR_ORDER') {
                                        return '${Languages.of(context)!.labelPREPAREFORORDER} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'READY_FOR_ORDER') {
                                        return '${Languages.of(context)!.labelREADYFORORDER} ${widget.orderDate}, ${widget.orderTime}}';
                                      } else if (strOrderStatus == 'CANCEL') {
                                        return '${Languages.of(context)!.labelCanceledOn} ${widget.orderDate}, ${widget.orderTime}';
                                      } else if (strOrderStatus == 'COMPLETE') {
                                        return '${Languages.of(context)!.labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}';
                                      }
                                    }
                                  }()) ??
                                  '',
                              style: TextStyle(
                                  color: Constants.colorGray,
                                  fontFamily: Constants.appFont,
                                  fontSize: 12),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: strUserAddress != null
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 15, right: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'images/ic_map.svg',
                                                    width: 18,
                                                    height: 18,
                                                    color: Constants.colorTheme,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Container(
                                                      height: 60,
                                                      child: DottedLine(
                                                        direction: Axis.vertical,
                                                        dashColor: Constants.colorBlack,
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                    'images/ic_home.svg',
                                                    width: 18,
                                                    height: 18,
                                                    color: Constants.colorTheme,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(top: 20),
                                                height: 130,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 65,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.stretch,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(left: 10),
                                                            child: Text(
                                                              strVendorName!,
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFontBold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                top: 3, left: 10, right: 5),
                                                            child: Text(
                                                              strVendorAddress!,
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFont,
                                                                  color: Constants.colorGray,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 65,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.stretch,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(left: 10),
                                                            child: Text(
                                                              strUserName!,
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFontBold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                top: 3, left: 10, right: 5),
                                                            child: Text(
                                                              strUserAddress!,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily: Constants.appFont,
                                                                  color: Constants.colorGray,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(10),
                                          bottom: ScreenUtil().setHeight(10),
                                          left: ScreenUtil().setWidth(10)),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'images/ic_map.svg',
                                            width: 18,
                                            height: 18,
                                            color: Constants.colorTheme,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: Text(
                                                  strVendorName!,
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFontBold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3, left: 10, right: 5),
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width * 0.80,
                                                  child: Text(
                                                    strVendorAddress!,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontFamily: Constants.appFont,
                                                        color: Constants.colorGray,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SvgPicture.asset(
                                        (() {
                                              if (strUserAddress != null) {
                                                if (strOrderStatus == 'PENDING') {
                                                  return 'images/ic_pending.svg';
                                                } else if (strOrderStatus == 'APPROVE') {
                                                  return 'images/ic_accept.svg';
                                                } else if (strOrderStatus == 'ACCEPT') {
                                                  return 'images/ic_accept.svg';
                                                } else if (strOrderStatus == 'REJECT') {
                                                  return 'images/ic_cancel.svg';
                                                } else if (strOrderStatus == 'PICKUP') {
                                                  return 'images/ic_pickup.svg';
                                                } else if (strOrderStatus == 'DELIVERED') {
                                                  return 'images/ic_completed.svg';
                                                } else if (strOrderStatus == 'CANCEL') {
                                                  return 'images/ic_cancel.svg';
                                                } else if (strOrderStatus == 'COMPLETE') {
                                                  return 'images/ic_completed.svg';
                                                }
                                              } else {
                                                if (strOrderStatus == 'PENDING') {
                                                  return 'images/ic_pending.svg';
                                                } else if (strOrderStatus == 'APPROVE') {
                                                  return 'images/ic_accept.svg';
                                                } else if (strOrderStatus == 'ACCEPT') {
                                                  return 'images/ic_accept.svg';
                                                } else if (strOrderStatus == 'REJECT') {
                                                  return 'images/ic_cancel.svg';
                                                } else if (strOrderStatus == 'PREPARE_FOR_ORDER') {
                                                  return 'images/ic_pickup.svg';
                                                } else if (strOrderStatus == 'READY_FOR_ORDER') {
                                                  return 'images/ic_completed.svg';
                                                } else if (strOrderStatus == 'CANCEL') {
                                                  return 'images/ic_cancel.svg';
                                                } else if (strOrderStatus == 'COMPLETE') {
                                                  return 'images/ic_completed.svg';
                                                }
                                              }
                                            }()) ??
                                            '',
                                        color: (() {
                                          // your code here
                                          // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                          if (strOrderStatus == 'PENDING') {
                                            return Constants.colorOrderPending;
                                          } else if (strOrderStatus == 'ACCEPT') {
                                            return Constants.colorBlack;
                                          } else if (strOrderStatus == 'PICKUP') {
                                            return Constants.colorOrderPickup;
                                          }
                                        }()),
                                        width: 15,
                                        height: ScreenUtil().setHeight(15),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                      text: (() {
                                        // your code here
                                        // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                        if (strUserAddress != null) {
                                          if (strOrderStatus == 'PENDING') {
                                            return Languages.of(context)!.labelOrderPending;
                                          } else if (strOrderStatus == 'APPROVE') {
                                            return Languages.of(context)!.labelOrderAccepted;
                                          } else if (strOrderStatus == 'ACCEPT') {
                                            return Languages.of(context)!.labelOrderAccepted;
                                          } else if (strOrderStatus == 'REJECT') {
                                            return Languages.of(context)!.labelOrderRejected;
                                          } else if (strOrderStatus == 'PICKUP') {
                                            return Languages.of(context)!.labelOrderPickedUp;
                                          } else if (strOrderStatus == 'DELIVERED') {
                                            return Languages.of(context)!.labelDeliveredSuccess;
                                          } else if (strOrderStatus == 'CANCEL') {
                                            return Languages.of(context)!.labelOrderCanceled;
                                          } else if (strOrderStatus == 'COMPLETE') {
                                            return Languages.of(context)!.labelOrderCompleted;
                                          }
                                        } else {
                                          if (strOrderStatus == 'PENDING') {
                                            return Languages.of(context)!.labelOrderPending;
                                          } else if (strOrderStatus == 'APPROVE') {
                                            return Languages.of(context)!.labelOrderAccepted;
                                          } else if (strOrderStatus == 'ACCEPT') {
                                            return Languages.of(context)!.labelOrderAccepted;
                                          } else if (strOrderStatus == 'REJECT') {
                                            return Languages.of(context)!.labelOrderRejected;
                                          } else if (strOrderStatus == 'PREPARE_FOR_ORDER') {
                                            return Languages.of(context)!.labelPREPAREFORORDER;
                                          } else if (strOrderStatus == 'READY_FOR_ORDER') {
                                            return Languages.of(context)!.labelREADYFORORDER;
                                          } else if (strOrderStatus == 'CANCEL') {
                                            return Languages.of(context)!.labelOrderCanceled;
                                          } else if (strOrderStatus == 'COMPLETE') {
                                            return Languages.of(context)!.labelOrderCompleted;
                                          }
                                        }
                                      }()),
                                      style: TextStyle(
                                          color: (() {
                                            // your code here
                                            if (strUserAddress != null) {
                                              if (strOrderStatus == 'PENDING') {
                                                return Constants.colorOrderPending;
                                              } else if (strOrderStatus == 'APPROVE') {
                                                return Constants.colorBlack;
                                              } else if (strOrderStatus == 'ACCEPT') {
                                                return Constants.colorBlack;
                                              } else if (strOrderStatus == 'REJECT') {
                                                return Constants.colorLike;
                                              } else if (strOrderStatus == 'DELIVERED') {
                                                return Constants.colorTheme;
                                              } else if (strOrderStatus == 'PICKUP') {
                                                return Constants.colorOrderPickup;
                                              } else if (strOrderStatus == 'CANCEL') {
                                                return Constants.colorLike;
                                              } else if (strOrderStatus == 'COMPLETE') {
                                                return Constants.colorTheme;
                                              }
                                            } else {
                                              if (strOrderStatus == 'PENDING') {
                                                return Constants.colorOrderPending;
                                              } else if (strOrderStatus == 'APPROVE') {
                                                return Constants.colorBlack;
                                              } else if (strOrderStatus == 'ACCEPT') {
                                                return Constants.colorBlack;
                                              } else if (strOrderStatus == 'REJECT') {
                                                return Constants.colorLike;
                                              } else if (strOrderStatus == 'PREPARE_FOR_ORDER') {
                                                return Constants.colorTheme;
                                              } else if (strOrderStatus == 'READY_FOR_ORDER') {
                                                return Constants.colorOrderPickup;
                                              } else if (strOrderStatus == 'CANCEL') {
                                                return Constants.colorLike;
                                              } else if (strOrderStatus == 'COMPLETE') {
                                                return Constants.colorTheme;
                                              }
                                            }
                                          }()),
                                          fontFamily: Constants.appFont,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          isPending
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Languages.of(context)!.labelDeliveredBy,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: Constants.appFontBold,
                                                      fontWeight: FontWeight.w900),
                                                ),
                                                Text(
                                                  strDeliveryPerson!,
                                                  style: TextStyle(
                                                      color: Constants.colorGray,
                                                      fontFamily: Constants.appFont),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: ScreenUtil().setWidth(15),
                                                  bottom: ScreenUtil().setHeight(15)),
                                              child: Container(
                                                alignment: Alignment.bottomRight,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                  child: CachedNetworkImage(
                                                    height: ScreenUtil().setHeight(50),
                                                    width: ScreenUtil().setWidth(50),
                                                    imageUrl: strDeliveryPersonImage!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        SpinKitFadingCircle(
                                                            color: Constants.colorTheme),
                                                    errorWidget: (context, url, error) => Container(
                                                      child: Center(
                                                          child: Image.asset('images/noimage.png')),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListView.builder(
                                  itemCount: orderItemList.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, position) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    orderItemList[position].itemName!,
                                                    style: TextStyle(
                                                        fontFamily: Constants.appFont,
                                                        fontSize: ScreenUtil().setSp(16)),
                                                  ),
                                                  Text(
                                                    ' X ' + orderItemList[position].qty.toString(),
                                                    style: TextStyle(
                                                        fontFamily: Constants.appFont,
                                                        color: Constants.colorTheme,
                                                        fontSize: ScreenUtil().setSp(14)),
                                                  ),
                                                ],
                                              ),
                                              orderItemList[position].custimization != null &&
                                                      orderItemList[position]
                                                              .custimization!
                                                              .length >
                                                          0
                                                  ? Container(
                                                      child: Text(
                                                        Languages.of(context)!.labelCustomizable,
                                                        style: TextStyle(
                                                            color: Constants.colorTheme,
                                                            fontFamily: Constants.appFont),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(
                                                SharedPreferenceUtil.getString(
                                                        Constants.appSettingCurrencySymbol) +
                                                    orderItemList[position].price.toString(),
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont, fontSize: 14)),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Constants.colorGray,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context)!.labelSubtotal,
                                      style: TextStyle(fontFamily: Constants.appFont, fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        SharedPreferenceUtil.getString(
                                                Constants.appSettingCurrencySymbol) +
                                            subTotal.toString(),
                                        style:
                                            TextStyle(fontFamily: Constants.appFont, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Constants.colorGray,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context)!.labelDeliveryCharge,
                                      style: TextStyle(fontFamily: Constants.appFont, fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        '+ ' +
                                            SharedPreferenceUtil.getString(
                                                Constants.appSettingCurrencySymbol) +
                                            strDeliveryCharge!,
                                        style:
                                            TextStyle(fontFamily: Constants.appFont, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Constants.colorGray,
                                  ),
                                ),
                                isAppliedCoupon
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    Languages.of(context)!.labelAppliedCoupon,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontFamily: Constants.appFont,
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontFamily: Constants.appFont,
                                                        color: Constants.colorTheme,
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Text(
                                                  '- ' +
                                                      SharedPreferenceUtil.getString(
                                                          Constants.appSettingCurrencySymbol) +
                                                      ' ' +
                                                      couponPrice.toString(),
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont,
                                                      color: Constants.colorLike,
                                                      fontSize: 14),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor: Constants.colorGray,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                isTaxApplied
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)!.labelTax,
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    fontSize: ScreenUtil().setSp(16)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil().setWidth(10)),
                                                child: Text(
                                                  "+ ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                      taxAmount.toInt().toString(),
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont,
                                                      fontSize: ScreenUtil().setSp(14)),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(20),
                                                bottom: ScreenUtil().setHeight(20)),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor: Constants.colorGray,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                isVendorDiscount
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)!.labelVendorDiscount,
                                                style: TextStyle(
                                                    fontFamily: Constants.appFont,
                                                    fontSize: ScreenUtil().setSp(16)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil().setWidth(10)),
                                                child: Text(
                                                  "- ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                      strVendorDiscount!,
                                                  style: TextStyle(
                                                      fontFamily: Constants.appFont,
                                                      fontSize: ScreenUtil().setSp(14)),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(20),
                                                bottom: ScreenUtil().setHeight(20)),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor: Constants.colorGray,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context)!.labelGrandTotal,
                                        style: TextStyle(
                                            fontFamily: Constants.appFont,
                                            color: Constants.colorTheme,
                                            fontSize: 16),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(
                                          SharedPreferenceUtil.getString(
                                                  Constants.appSettingCurrencySymbol) +
                                              grandTotalAmount.toString(),
                                          style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              color: Constants.colorTheme,
                                              fontSize: 14),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // || strOrderStatus == 'COMPLETE'
                      strOrderStatus == 'CANCEL'
                          ? Padding(
                              padding: EdgeInsets.all(15.0),
                              child: RoundedCornerAppButton(
                                onPressed: () {
                                  showRaiseRefundRequest();
                                },
                                btnLabel: Languages.of(context)!.labelRaiseRefundRequest,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<BaseModel<OrderStatus>> callGetOrderStatus() async {
    OrderStatus response;
    try{
      response  = await  RestClient(RetroApi().dioData()).userOrderStatus();
      print(response.success);
      if (response.success!) {
        if (response.data!.length > 0) {
          setState(() {
            for (int i = 0; i < response.data!.length; i++) {
              if (widget.orderId == response.data![i].id) {
                setState(() {
                  strOrderStatus = response.data![i].orderStatus;
                });
              }
            }
          });
        } else {
          if (timer.isActive) {
            timer.cancel();
          }
        }
      }

    }catch (error, stacktrace) {

      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SingleOrderDetailsModel>> callGetSingleOrderDetails(int? orderId) async {
    SingleOrderDetailsModel response;
    try{
      Constants.onLoading(context);
      response  = await RestClient(RetroApi().dioData()).singleOrder(orderId);
      print('single order ${response.success}');
      Constants.hideDialog(context);
      setState(() {
        if (response.data!.userAddress != null) {
          strUserAddress = response.data!.userAddress!.address;
        } else {
          strUserAddress = null;
        }

        strUserName = response.data!.user!.name;
        strOrderInvoiceId = response.data!.orderId;

        strVendorName = response.data!.vendor!.name;
        strVendorAddress = response.data!.vendor!.mapAddress ?? '';
        strOrderStatus = response.data!.orderStatus;

        orderItemList.addAll(response.data!.orderItems!);
        if(response.data!.promoCodeId != null){
          promocodeId = response.data!.promoCodeId;
        }else{
          promocodeId = 0;
        }

        strDeliveryCharge = response.data!.deliveryCharge.toString();

        if (response.data!.vendorDiscountPrice != null) {
          strVendorDiscount = response.data!.vendorDiscountPrice.toString();
          isVendorDiscount = true;
        } else {
          strVendorDiscount = '0.0';
        }

        for (int i = 0; i < orderItemList.length; i++) {
          subTotal += orderItemList[i].price!;
        }

        if (response.data!.vendor!.tax != null &&response.data!.vendor!.tax!.isNotEmpty ) {
          if (subTotal != 0) {
            taxAmount = double.parse(response.data!.tax.toString());
            isTaxApplied = true;
          }
        }

        if (response.data!.deliveryCharge == null) {
          strDeliveryCharge = '0';
        } else {
          strDeliveryCharge = response.data!.deliveryCharge.toString();
        }

        grandTotalAmount = response.data!.amount!;
        if (promocodeId != null) {
          isAppliedCoupon = true;
          couponPrice = response.data!.promoCodePrice!;
        } else {
          isAppliedCoupon = false;
        }

        // if (strOrderStatus == 'CANCEL' ||
        //     strOrderStatus == 'COMPLETE' ||
        //     strOrderStatus == 'DELIVERED') {
        //   isCanCancel = false;
        // } else {
        //   isCanCancel = true;
        // }
        if (strOrderStatus == 'PENDING') {
          isCanCancel = true;
        } else {
          isCanCancel = false;
        }


        if (response.data!.deliveryPerson != null) {
          isPending = false;
          strDeliveryPerson = response.data!.deliveryPerson!.firstName! +
              ' ' +
              response.data!.deliveryPerson!.lastName!;
          strDeliveryPersonImage = response.data!.deliveryPerson!.image;
        } else {
          isPending = true;
        }
      });

    }catch (error, stacktrace) {
    Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callRefundRequest(int? orderId, String refundRequestReason) async {
    CommenRes response;
    try{
      Constants.onLoading(context);
      Map<String, String> body = {
        'order_id': orderId.toString(),
        'refund_reason': refundRequestReason,
      };
      response  = await RestClient(RetroApi().dioData()).refund(body);
      Constants.hideDialog(context);
      if (response.success!) {
        Navigator.pop(context);
        Constants.toastMessage(response.data!);
        Constants.checkNetwork().whenComplete(() => callGetSingleOrderDetails(widget.orderId));
      } else {
        Navigator.pop(context);
        Constants.toastMessage(response.data!);
      }

    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callCancelOrder(int? orderId, String cancelReason) async {
    CommenRes response;
    try{
        Constants.onLoading(context);
      Map<String, String> body = {
        'id': orderId.toString(),
        'cancel_reason': cancelReason,
      };
      response  = await  RestClient(RetroApi().dioData()).cancelOrder(body);
      Constants.hideDialog(context);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Constants.checkNetwork().whenComplete(() => callGetSingleOrderDetails(widget.orderId));
      } else {
        Constants.toastMessage(response.data!);
      }
    }catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }


}
