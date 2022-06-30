import 'package:flutter/material.dart';

import 'constants.dart';

class AppLableWidget extends StatelessWidget {
  AppLableWidget({required this.title});
  final title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 30.0, vertical: 10.0),
      child: Text(
        title,
        style: Constants.kAppLabelWidget,
      ),
    );
  }
}