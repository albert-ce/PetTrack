import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const AppBarWidget({super.key, required this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      title: Row(
        children: [
          Text("PetTr", style: AppTextStyles.logoText(context)),
          SvgPicture.asset(
            "assets/images/icon_bold.svg",
            height: AppTextStyles.logoText(context).fontSize,
          ),
          Text("ck", style: AppTextStyles.logoText(context)),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.gradient),
      ),
    );
  }
}
