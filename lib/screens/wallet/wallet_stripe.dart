import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:dio/dio.dart';

class WalletPaymentStripe extends StatefulWidget {
  final orderAmount;

  const WalletPaymentStripe(
      {Key? key, this.orderAmount,})
      : super(key: key);
  @override
  _WalletPaymentStripeState createState() => _WalletPaymentStripeState();
}

class _WalletPaymentStripeState extends State<WalletPaymentStripe> {

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
    Constants.toastMessage(error.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
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
        addUserBalance();
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

  void addUserBalance() {
    Constants.onLoading(context);
   Map<String, String?> body = {
     'amount': widget.orderAmount,
     'payment_type': 'STRIPE',
     'payment_token': stripeToken,
   };
    RestClient(RetroApi().dioData()).addBalance(body).then((response) {
      setState(() {
        Constants.hideDialog(context);
        Constants.toastMessage(response.data!);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WalletScreen(),));
      });
    }).catchError((Object obj) {
      Constants.hideDialog(context);
         switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context)!.labelInternalServerError);
          }
          break;
        default:
      }
    });
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