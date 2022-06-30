import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/model/user_details_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileInformation extends StatefulWidget {
  @override
  _EditProfileInformationState createState() => _EditProfileInformationState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _EditProfileInformationState extends State<EditProfileInformation>
    with SingleTickerProviderStateMixin {
  final _textFullName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textContactNo = TextEditingController();
  final _textContactCode = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  final _formKeyForBankDetails = new GlobalKey<FormState>();

  //bool _autoValidate = false;

  TextEditingController _ifscCodeController = TextEditingController();
  TextEditingController _micrCodeController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();

  bool isValid = false;

  File? _image;
  final picker = ImagePicker();
  String? strImgbash64Profile, strCountryCode = '+91', _userPhoto = '';

  Item? selectedUser;
  TabController? _controller;
  int tabIndex = 0;

  List<String> _listLanguages = [];

  int? radioIndex;

  String strLanguage = '';

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getUnChecked() {
    return Container(
      width: 25,
      height: 25,
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

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    _listLanguages.add('Spanish');
    _listLanguages.add('Arabic');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioIndex = 0;
      } else if (languageCode == 'es') {
        radioIndex = 1;
      } else if (languageCode == 'ar') {
        radioIndex = 2;
      } else {
        radioIndex = 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textContactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);
    _textContactCode.text =
        SharedPreferenceUtil.getString(Constants.loginPhoneCode);
    _textEmail.text = SharedPreferenceUtil.getString(Constants.loginEmail);
    _textFullName.text =
        SharedPreferenceUtil.getString(Constants.loginUserName);
    _userPhoto = SharedPreferenceUtil.getString(Constants.loginUserImage);

    _controller =
        new TabController(length: 2, vsync: this, initialIndex: tabIndex);

    _ifscCodeController.text =
        SharedPreferenceUtil.getString(Constants.bankIFSC);
    _micrCodeController.text =
        SharedPreferenceUtil.getString(Constants.bankMICR);
    _accountNameController.text =
        SharedPreferenceUtil.getString(Constants.bankACCName);
    _accountNumberController.text =
        SharedPreferenceUtil.getString(Constants.bankACCNumber);
    getLanguageList();
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        strImgbash64Profile = base64Encode(imageBytes);
        callUpdateImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        strImgbash64Profile = base64Encode(imageBytes);
        callUpdateImage();
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      'Photo Library',
                      style: TextStyle(fontFamily: Constants.appFont),
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'Camera',
                    style: TextStyle(fontFamily: Constants.appFont),
                  ),
                  onTap: () {
                    getImage();
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(
                    'Cancel',
                    style: TextStyle(fontFamily: Constants.appFont),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Constants.colorBlack),
          backgroundColor: Constants.colorWhite,
          title: Text(
            Languages.of(context)!.labelEditPersonalInfo,
            style: TextStyle(
                color: Constants.colorBlack,
                fontWeight: FontWeight.w900,
                fontSize: 20.0,
                fontFamily: Constants.appFontBold),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 5,
            controller: _controller,
            isScrollable: false,
            physics: NeverScrollableScrollPhysics(),
            indicatorColor: Constants.colorTheme,
            labelColor: Constants.colorTheme,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontFamily: Constants.appFontBold,
            ),
            tabs: <Widget>[
              Tab(
                text: Languages.of(context)!.labelPersonalDetails,
              ),
              Tab(
                text: Languages.of(context)!.labelFinancialDetails,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(height: ScreenUtil().setHeight(30)),
                              Row(
                                children: [
                                  Container(
                                      margin:
                                          EdgeInsets.only(left: 30, right: 10),
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      width: ScreenUtil().setWidth(100),
                                      height: ScreenUtil().setHeight(100),
                                      child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomEnd,
                                        children: [
                                          ClipOval(
                                            child: _image != null
                                                ? Image.file(
                                                    _image!,
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: _userPhoto!,
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                    placeholder: (context,
                                                            url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                          ),
                                          /*Stack(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 30,
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    _showPicker(context);
                                                  },
                                                  elevation: 2.0,
                                                  fillColor: Colors.white,
                                                  child: SvgPicture.asset(
                                                    'images/ic_camera.svg',
                                                    height: ScreenUtil().setHeight(20),
                                                    width: ScreenUtil().setWidth(20),
                                                  ),
                                                  padding: EdgeInsets.all(5.0),
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors.black, width: 1.5)),
                                                ),
                                              )
                                            ],
                                          ),*/
                                        ],
                                      )),
                                  GestureDetector(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          Languages.of(context)!
                                              .changeProfilePicture,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontFamily: Constants.appFont),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      _showPicker(context);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(10),
                                    left: ScreenUtil().setWidth(20),
                                    right: ScreenUtil().setWidth(20)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppLableWidget(
                                      title:
                                          Languages.of(context)!.labelFullName,
                                    ),
                                    CardTextFieldWidget(
                                      focus: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      textInputAction: TextInputAction.next,
                                      hintText: Languages.of(context)!
                                          .labelEnterYourFullName,
                                      textInputType: TextInputType.text,
                                      textEditingController: _textFullName,
                                      validator: kvalidateFullName,
                                    ),
                                    AppLableWidget(
                                      title: Languages.of(context)!.labelEmail,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: TextFormField(
                                        controller: _textEmail,
                                        validator: kvalidateEmail,
                                        textInputAction: TextInputAction.next,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onFieldSubmitted: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Constants.colorWhite,
                                          contentPadding: const EdgeInsets.only(
                                              left: 14.0,
                                              bottom: 6.0,
                                              top: 8.0,
                                              right: 14),
                                          errorMaxLines: 2,
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 0.5, color: Colors.grey),
                                          ),
                                          enabledBorder: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 0.5, color: Colors.grey),
                                          ),
                                          disabledBorder:
                                              new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 0.5, color: Colors.grey),
                                          ),
                                          focusedBorder: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 0.5, color: Colors.grey),
                                          ),
                                          errorBorder: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 0.5, color: Colors.red),
                                          ),
                                          focusedErrorBorder:
                                              new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.red),
                                          ),
                                          enabled: false,
                                          errorStyle: TextStyle(
                                              fontFamily: Constants.appFontBold,
                                              color: Colors.red),
                                          hintText: Languages.of(context)!
                                              .labelEnterYourEmailID,
                                          hintStyle: TextStyle(
                                              color: Constants.colorHint),
                                        ),
                                      ),
                                    ),
                                    AppLableWidget(
                                      title: Languages.of(context)!
                                          .labelContactNumber,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: ScreenUtil().setWidth(70),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      15.0),
                                              color: Constants.colorWhite,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                            height: ScreenUtil().setHeight(48),
                                            child: CountryCodePicker(
                                              enabled: false,
                                              padding: EdgeInsets.zero,
                                              onChanged: (c) {
                                                setState(() {
                                                  strCountryCode = c.dialCode;
                                                });
                                              },
                                              // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                              initialSelection: _textContactCode
                                                  .text
                                                  .toString(),
                                              favorite: [
                                                _textContactCode.text
                                                    .toString(),
                                                ''
                                              ],
                                              hideMainText: true,
                                              alignLeft: true,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.6,
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              controller: _textContactNo,
                                              validator: kvalidateCotactNum,
                                              maxLength: 10,
                                              buildCounter: (context,
                                                      {required currentLength,
                                                      required isFocused,
                                                      maxLength}) =>
                                                  null,
                                              keyboardType:
                                                  TextInputType.number,
                                              onFieldSubmitted: (v) {
                                                FocusScope.of(context)
                                                    .nextFocus();
                                              },
                                              decoration: InputDecoration(
                                                enabled: false,
                                                prefixIcon: Padding(
                                                    padding: EdgeInsets.all(15),
                                                    child: Text(
                                                        '${_textContactCode.text.toString()} ')),
                                                hintStyle: TextStyle(
                                                    color: Constants.colorHint),
                                                errorStyle: TextStyle(
                                                    fontFamily:
                                                        Constants.appFontBold,
                                                    color: Colors.red),
                                                filled: true,
                                                fillColor: Constants.colorWhite,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 6.0,
                                                        top: 8.0,
                                                        right: 14),
                                                errorMaxLines: 2,
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey),
                                                ),
                                                enabledBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey),
                                                ),
                                                disabledBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey),
                                                ),
                                                errorBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.red),
                                                ),
                                                focusedErrorBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.red),
                                                ),
                                                hintText: '000 000 0000',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppLableWidget(
                                      title:
                                          Languages.of(context)!.labelLanguage,
                                    ),
                                    ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: _listLanguages.length,
                                        itemBuilder: (BuildContext context,
                                                int index) =>
                                            InkWell(
                                              onTap: () {
                                                changeIndex(index);
                                                String languageCode = '';
                                                if (index == 0) {
                                                  languageCode = 'en';
                                                } else if (index == 1) {
                                                  languageCode = 'es';
                                                } else {
                                                  languageCode = 'ar';
                                                }
                                                changeLanguage(
                                                    context, languageCode);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(20),
                                                    bottom: ScreenUtil()
                                                        .setHeight(10),
                                                    top: ScreenUtil()
                                                        .setHeight(10)),
                                                child: Row(
                                                  children: [
                                                    radioIndex == index
                                                        ? getChecked()
                                                        : getUnChecked(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: ScreenUtil()
                                                              .setWidth(10)),
                                                      child: Text(
                                                        _listLanguages[index],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .appFont,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(14)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        ScreenUtil().setWidth(20)),
                                    child: RoundedCornerAppButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (radioIndex == 0) {
                                            strLanguage = 'english';
                                          } else if (radioIndex == 1) {
                                            strLanguage = 'spanish';
                                          } else {
                                            strLanguage = 'arabic';
                                          }
                                          print('selected Language' +
                                              strLanguage);
                                          callUpdateUsername(strLanguage);
                                        } else {
                                          setState(() {
                                            // validation error
                                            // _autoValidate = true;
                                          });
                                        }
                                      },
                                      btnLabel: Languages.of(context)!
                                          .labelSavePersonalInfo,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight),
                        child: Form(
                          key: _formKeyForBankDetails,
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AppLableWidget(
                                        title: Languages.of(context)!.iFSCCode,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            Languages.of(context)!.iFSCCode1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _ifscCodeController,
                                        validator: validateIFSC,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context)!.mICRCode,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            Languages.of(context)!.mICRCode1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _micrCodeController,
                                        validator: validateMICRCode,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context)!
                                            .bankAccountName,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText: Languages.of(context)!
                                            .bankAccountName1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _accountNameController,
                                        validator: validateAccountname,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context)!
                                            .bankAccountNumber,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.done,
                                        hintText: Languages.of(context)!
                                            .bankAccountNumber1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _accountNumberController,
                                        validator: validateAccountNumber,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 20, right: 20),
                                        child: RoundedCornerAppButton(
                                          onPressed: () {
                                            if (_formKeyForBankDetails
                                                .currentState!
                                                .validate()) {
                                              submitBankDetails();
                                            } else {
                                              setState(() {
                                                // validation error
                                                //_autoValidate = true;
                                              });
                                            }
                                          },
                                          btnLabel: Languages.of(context)!
                                              .labelSubmit,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateAccountNumber(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.bankAccountNumber2;
    }
    return null;
  }

  String? validateAccountname(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.bankAccountName2;
    }
    return null;
  }

  String? validateIFSC(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.iFSCCode2;
    }
    return null;
  }

  String? validateMICRCode(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.mICRCode2;
    } else
      return null;
  }

  String? kvalidateFullName(String? value) {
    if (value!.trim().length == 0) {
      return Languages.of(context)!.labelFullNameRequired;
    } else
      return null;
  }

  String? kvalidateCotactNum(String? value) {
    if (value!.trim().length == 0) {
      return Languages.of(context)!.labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context)!.labelContactNumberNotValid;
    } else
      return null;
  }

  String? kvalidateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.trim().length == 0) {
      return Languages.of(context)!.labelEmailRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context)!.labelEnterValidEmail;
    else
      return null;
  }

  Future<BaseModel<UserDetailsModel>> callGetUserDetails() async {
    UserDetailsModel response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).user();
      Constants.hideDialog(context);
      print(response);
      setState(() {
        _textFullName.text = response.name!;
        _textEmail.text = response.emailId!;
        _textContactNo.text = response.phone!;
        _userPhoto = response.image;
        SharedPreferenceUtil.putString(Constants.loginUserName, response.name!);
        SharedPreferenceUtil.putString(
            Constants.loginUserImage, response.image!);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.emailId!);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.phone!);
      });

      Navigator.of(context).pushReplacement(
        Transitions(
          transitionType: TransitionType.slideUp,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
          widget: DashboardScreen(3),
        ),
      );
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callUpdateImage() async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body = {
        'image': strImgbash64Profile,
      };
      response = await RestClient(RetroApi().dioData()).updateImage(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetUserDetails();
      } else {
        Constants.toastMessage('Error while updating image.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> callUpdateUsername(String strLanguage) async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'name': _textFullName.text,
        'language': strLanguage,
      };
      response = await RestClient(RetroApi().dioData()).updateUser(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetUserDetails();
      } else {
        Constants.toastMessage('Error while update image.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommenRes>> submitBankDetails() async {
    CommenRes response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'ifsc_code': _ifscCodeController.text,
        'micr_code': _micrCodeController.text,
        'account_name': _accountNameController.text,
        'account_number': _accountNumberController.text,
      };
      response = await RestClient(RetroApi().dioData()).bankDetails(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);

        SharedPreferenceUtil.putString(
            Constants.bankIFSC, _ifscCodeController.text);
        SharedPreferenceUtil.putString(
            Constants.bankMICR, _micrCodeController.text);
        SharedPreferenceUtil.putString(
            Constants.bankACCName, _accountNameController.text);
        SharedPreferenceUtil.putString(
            Constants.bankACCNumber, _accountNumberController.text);

        setState(() {
          _ifscCodeController.text =
              SharedPreferenceUtil.getString(Constants.bankIFSC);
          _micrCodeController.text =
              SharedPreferenceUtil.getString(Constants.bankMICR);
          _accountNameController.text =
              SharedPreferenceUtil.getString(Constants.bankACCName);
          _accountNumberController.text =
              SharedPreferenceUtil.getString(Constants.bankACCNumber);
        });
      } else {
        Constants.toastMessage('Error while submit bank details.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
