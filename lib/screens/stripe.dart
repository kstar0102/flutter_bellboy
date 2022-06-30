import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:scoped_model/scoped_model.dart';

class PaymentStripe extends StatefulWidget {
  final int? venderId,
      orderAmount,
      addressId,
      vendorDiscountAmount,
      vendorDiscountId;
  final String? orderDate,
      orderTime,
      orderStatus,
      orderCustomization,
      ordrePromoCode,
      orderDeliveryType,
      // strTaxAmount,
      orderDeliveryCharge;
  // final double orderItem;
  final List<Map<String, dynamic>>? orderItem;
  final List<Map<String, dynamic>>? allTax;

  const PaymentStripe(
      {Key? key,
      this.venderId,
      this.orderDeliveryCharge,
      this.orderAmount,
      this.addressId,
      this.orderDate,
      this.orderTime,
      this.orderStatus,
      this.orderCustomization,
      this.ordrePromoCode,
      this.orderDeliveryType,
      this.orderItem,
      this.vendorDiscountAmount,
      this.vendorDiscountId,
      this.allTax})
      : super(key: key);
  @override
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final dbHelper = DatabaseHelper.instance;
  String? expDate;
  String? cvv;

  String? stripePublicKey;
  String? stripeSecretKey;
  String? stripeToken;
  int? paymentTokenKnow;
  int? paymentStatus;
  String? paymentType;
  ScrollController _controller = ScrollController();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int? selectedIndex;
  CardFieldInputDetails? _card;
  TokenData? tokenData;



  @override
  initState() {
    super.initState();
    // getStripePublishKey();
    stripeSecretKey = SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey = SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    Stripe.publishableKey = stripePublicKey!;
  }

  Future<void> getStripePublishKey() async {
    stripeSecretKey =
        SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey =
        SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    Stripe.publishableKey = stripePublicKey!;
  }

   setError(dynamic error) {
    showSpinner = false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Constants.colorWhite,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Stripe Payment",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardField(
              autofocus: false,
              onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              },
            ),
            LoadingButton(
                onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
                text: "Continue"
            ),
          ],
        ),
      ),
    );
  }

  Future _handleCreateTokenPress() async {
    setState(() {
      // _loading = true;
    });
    if (_card == null) {
      return;
    }

    try {
      final tokenData = await Stripe.instance
          .createToken(
        CreateTokenParams(type: TokenType.Card),
      )
          .onError((error, stackTrace) => setError(error));
      setState(() {
        this.tokenData = tokenData;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Completed')));
      if (tokenData.id.isNotEmpty) {
        stripeToken = tokenData.id;
        showSpinner = false;
        SharedPreferenceUtil.putString(Constants.stripePaymentToken, stripeToken!);
        placeOrder();
        setState(() {
          // _loading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }


  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  Future<BaseModel<CommenRes>> placeOrder() async {
    CommenRes response;
    try{
      Constants.onLoading(context);

      print('without ${json.encode(widget.orderItem.toString())}');
      String item1 = json.encode(widget.orderItem).toString();
      print('with ${item1.toString()}');
      // var json = jsonEncode(widget.orderItem, toEncodable: (e) => e.toString());
      Map<String, dynamic> item = {"id": 11, "price": 200, "qty": 1};

      item = {"id": 10, "price": 195, "qty": 3};

      List<Map<String, dynamic>> temp = [];
      temp.add({'id': 10, 'price': 195, 'qty': 3});
      temp.add({'id': 11, 'price': 200, 'qty': 1});

      print('with $item');
      print('temp without ${json.encode(temp.toString())}');
      print('temp with' + json.encode(temp).toString());

      print('item with' + jsonEncode(item));
      // item.addEntries({"id": 2, "price": 200, "qty": 2});
      Map<String, String?> body = {
        'vendor_id': widget.venderId.toString(),
        'date': widget.orderDate,
        'time': widget.orderTime,
        //change
        // 'item': widget.orderItem.toString(),
        'item': json.encode(widget.orderItem).toString(),
        // 'item': '[{\'id\':\'11\',\'price\':\'200\',\'qty\':\'1\'},{\'id\':\'10\',\'price\':\'195\',\'qty\':\'3\'}]',
        'amount': widget.orderAmount.toString(),
        'delivery_type': widget.orderDeliveryType,
        'address_id':
        widget.orderDeliveryType == 'SHOP' ? '' : widget.addressId.toString(),
        'delivery_charge': widget.orderDeliveryCharge,
        'payment_type': 'STRIPE',
        'payment_status': '1',
        'order_status': widget.orderStatus,
        'custimization': json.encode(widget.orderCustomization).toString(),
        'promocode_id': widget.ordrePromoCode,
        'payment_token': stripeToken,
        'vendor_discount_price': widget.vendorDiscountAmount != 0
            ? widget.vendorDiscountAmount.toString()
            : '',
        'vendor_discount_id': widget.vendorDiscountId != 0
            ? widget.vendorDiscountId.toString()
            : '',
        // 'tax': widget.strTaxAmount
        'tax': json.encode(widget.allTax).toString(),
      };

      response  = await RestClient(RetroApi().dioData()).bookOrder(body);
      Constants.hideDialog(context);
      print(response);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        _deleteTable();
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OrderHistoryScreen(
                isFromProfile: false,
              ),
            ),
                (Route<dynamic> route) => true);
      } else {
       if(response.data != null) {
          Constants.toastMessage(response.data!);
        }else{
          Constants.toastMessage('Error while place order.');
        }
      }

    }catch (error, stacktrace) {
     Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

}

//new
class LoadingButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String text;

  const LoadingButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: MaterialButton(
            height: kBottomNavigationBarHeight,
            color: Constants.colorTheme,
            textColor: Colors.white,
            splashColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            onPressed:
            (_isLoading || widget.onPressed == null) ? null : _loadFuture,
            child: _isLoading
                ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ))
                : Text(widget.text,style:
            TextStyle(fontFamily: Constants.appFont, fontSize: 16),),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error $e')));
      rethrow;
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}