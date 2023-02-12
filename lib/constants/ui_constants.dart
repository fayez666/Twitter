import 'package:flutter/material.dart';
import 'package:twitter/features/explore/view/explore_view.dart';
import 'package:twitter/features/tweet/widgets/tweet_list.dart';
import 'package:twitter/theme/theme.dart';

import '../features/notificaions/views/notification_view.dart';
import 'assets_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        color: Pallete.blueColor,
      ),
      centerTitle: true,
    );
  }

  static List<Widget> bottomTabBarPages = [
    const TweetList(),
    const ExploreView(),
    const NotificationView(),
  ];
}
