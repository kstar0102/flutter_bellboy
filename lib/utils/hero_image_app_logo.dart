import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Hero(
        tag: 'App_logo',
        child: Center(
            child: Image.asset('images/ic_intro_logo.png',height: ScreenUtil().setHeight(50),),
        ),
      ),
    );
  }
}
