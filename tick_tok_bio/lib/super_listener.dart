/*
    A class with all static methods that can have references to active pages,
    can be used to switch between pages or get information from a different page.
 */

import 'package:flutter/material.dart';
import 'package:tick_tok_bio/gps_tracking.dart';
import 'user_page.dart';
import 'main.dart';
import 'metadata_page.dart';

class SuperListener {
  static HomePageState homePage;
  static MapsState mapPage;
  static UserPageState userPage;
  static MetadataSectionState dataPage;

  //Essentially a static constructor, can take any number of arguments
  static void setPages({
    HomePageState hPage,
    MapsState mPage,
    UserPageState uPage,
    MetadataSectionState dPage,
  }) {
    if (hPage != null) homePage = hPage;
    if (mPage != null) mapPage = mPage;
    if (uPage != null) userPage = uPage;
    if (dPage != null) dataPage = dPage;
  }

  //Navigates to the page as specified in the home index
  static void navigateTo(int page) {
    homePage.pageNavigator(page);
  }

  //Returns the active user, null if null
  static String getUser() {
    return userPage.getUser();
  }

  static void moveAndCreateDrag(String filename) {
    print('***SUPERLISTENER MAKING NEW DRAG***');
    navigateTo(2);
    dataPage.createNewDrag(filename);
  }

  static int emptyRef() {
    if (userPage == null) return 0;
    if (mapPage == null) return 1;
    if (dataPage == null) return 2;
    return -1;
  }
}
