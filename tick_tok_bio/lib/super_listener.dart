/*
    A class with all static methods that can have references to active pages,
    can be used to switch between pages or get information from a different page.
 */

import 'package:flutter/material.dart';
import 'package:tick_tok_bio/gps_tracking.dart';
import 'user_page.dart';
import 'main.dart';

class SuperListener {
  static HomePageState homePage;
  static Widget mapPage;
  static UserPageState userPage;

  //Essentially a static constructor, can take any number of arguments
  static void setPages({
    HomePageState hPage,
    Widget mPage,
    UserPageState uPage,
  }) {
    homePage = hPage;
    mapPage = mPage;
    userPage = uPage;
  }

  //Navigates to the page as specified in the home index
  static void navigateTo(int page) {
    homePage.pageNavigator(page);
  }

  //Returns the active user, null if null
  static String getUser() {
    return userPage.getUser();
  }
}
