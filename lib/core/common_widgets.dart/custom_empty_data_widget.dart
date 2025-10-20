import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomEmptyDataWidget extends StatelessWidget {
  const CustomEmptyDataWidget({
    super.key,
    this.title,
    this.subTitle,
    this.imageType = 0,
    this.showIcon = false,
    this.icon,
  });

  final String? title;
  final String? subTitle;
  final int imageType;
  final bool showIcon;
  final IconData? icon;

  String get getPlaceHolder {
    switch (imageType) {
      case 1:
        return 'assets/icons/comIcon.svg';
      case 2:
        return 'assets/icons/no_result_found.svg';
      case 3:
        return 'assets/icons/blockIcon.svg';
      case 4:
        return 'assets/icons/Nogift.svg';
      case 5:
        return 'assets/icons/Nolive.svg';
      case 6:
        return 'assets/icons/NoPosts.svg';
      case 7:
        return 'assets/icons/seek_search.svg';
      case 8:
        return 'assets/icons/NoMsg.svg';
      case 9:
        return 'assets/icons/NoNotification.svg';
      case 10:
        return 'assets/icons/followers.svg';
      case 11:
        return 'assets/icons/NoView.svg';
      default:
        return 'assets/icons/noList.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          getPlaceHolder,
          width: 130,
        ),
        const SizedBox(
          height: 20,
        ),
        if (title != null && title!.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showIcon && icon != null)
                const SizedBox(width: 8), // Add space if icon is shown
              if (showIcon && icon != null) Icon(icon, color: Colors.white),
            ],
          ),
        const SizedBox(
          height: 5,
        ),
        if (subTitle != null && subTitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subTitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
