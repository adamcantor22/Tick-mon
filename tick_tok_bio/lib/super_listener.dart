import 'package:flutter/material.dart';
import 'package:tick_tok_bio/gps_tracking.dart';

import 'main.dart';

class SuperListener {
  static HomePageState homePage;
  static Widget mapPage;

  static void setPages({
    HomePageState hPage,
    Widget mPage,
  }) {
    homePage = hPage;
    mapPage = mPage;
  }

  static void navigateTo(int page) {
    homePage.pageNavigator(page);
  }
}
