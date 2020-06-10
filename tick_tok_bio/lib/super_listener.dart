import 'package:flutter/material.dart';
import 'package:tick_tok_bio/gps_tracking.dart';
import 'user_page.dart';
import 'main.dart';

class SuperListener {
  static HomePageState homePage;
  static Widget mapPage;
  static UserPageState userPage;

  static void setPages({
    HomePageState hPage,
    Widget mPage,
    UserPageState uPage,
  }) {
    homePage = hPage;
    mapPage = mPage;
    userPage = uPage;
  }

  static void navigateTo(int page) {
    homePage.pageNavigator(page);
  }

  static String getUser() {
    return userPage.getUser();
  }
}
