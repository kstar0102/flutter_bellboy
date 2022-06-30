import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

// ignore: must_be_immutable
class CustomAppbar extends StatelessWidget with PreferredSizeWidget {
  final Function? onOfferTap,onSearchTap,onLocationTap,onFilterTap;
  bool? isFilter = false;

  String? strSelectedAddress = '';
  CustomAppbar({required this.onOfferTap,this.isFilter,required this.onSearchTap,required this.onLocationTap,this.onFilterTap,this.strSelectedAddress});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onLocationTap as void Function()?,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SvgPicture.asset(
                    'images/ic_map.svg',
                    width: 18,
                    height: 18,
                    color: Constants.colorTheme,
                  ),
                ),
                  Text(
                  strSelectedAddress!.isEmpty || strSelectedAddress == null
                      ? Languages.of(context)!.labelSelectAddress
                      : strSelectedAddress!.length > 20
                        ? strSelectedAddress!.substring(0, 20)+'...'
                        : strSelectedAddress!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0, fontFamily: Constants.appFont),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          Row(
            children: [
           /*   Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: onOfferTap,
                  child: SvgPicture.asset(
                    'images/offers.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),*/
              Visibility(
                visible: isFilter!,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: onFilterTap as void Function()?,
                    child: SvgPicture.asset(
                      'images/ic_filter.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: onSearchTap as void Function()?,
                  child: SvgPicture.asset(
                    'images/search.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
