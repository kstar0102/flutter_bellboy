import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/utils/constants.dart';

class LoginScreen1 extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen1> {
  bool isRememberMe = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: LayoutBuilder(
          builder:  (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Hero(
                    tag: 'App_logo',
                    child: Center(child: Image.asset('images/ic_intro_logo.png')),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            'Email',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                fontFamily: Constants.appFont),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  hintText: 'Enter Your Email ID',
                                  hintStyle:
                                  TextStyle(color: Constants.colorHint),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Text(
                                'Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    fontFamily: Constants.appFont),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Text(
                                'Forgot Password ?',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: Constants.appFont),
                              ),
                            )
                          ],
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15.0,
                            ),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintStyle:
                                  TextStyle(color: Constants.colorHint),
                                  hintText: 'Enter Your Password',
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Constants.colorTheme,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      }),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ClipRRect(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                child: SizedBox(
                                  width: 40.0,
                                  height: ScreenUtil().setHeight(40),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Container(
                                      child: Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor: Colors.transparent,
                                        ),
                                        child: Checkbox(
                                          value: isRememberMe,
                                          onChanged: (state) => setState(
                                                  () => isRememberMe = !isRememberMe),
                                          activeColor: Colors.transparent,
                                          checkColor: Constants.colorTheme,
                                          materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                  fontSize: 14.0, fontFamily: Constants.appFont),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.colorTheme,
                              onPrimary: Constants.colorWhite,
                              shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.fromLTRB(0.0, 15.0, 0, 15.0),
                              child: Text("Login",style: TextStyle(
                                  fontFamily: Constants.appFont,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.0
                              ),),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(10),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account ? ',
                              style: TextStyle(
                                  fontFamily: Constants.appFont
                              ),),
                            Text('Create Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.appFont
                              ),),
                          ],
                        ),

                      ],

                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('images/ic_login_page.png',
                      fit: BoxFit.cover,
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
