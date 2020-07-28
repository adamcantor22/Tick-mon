/*
    A class with all static methods that can have references to active pages,
    can be used to switch between pages or get information from a different page.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tick_tok_bio/gps_tracking.dart';
import 'package:tick_tok_bio/logged_in_screen.dart';
import 'user_page.dart';
import 'main.dart';
import 'metadata_page.dart';
import 'settings_page.dart';

class SuperListener {
  static HomePageState homePage;
  static MapsState mapPage;
  //static UserPageState userPage;
  static MetadataSectionState dataPage;
  static LoggedInScreenState logPage;
  static SettingsState settings;

  //Essentially a static constructor, can take any number of arguments
  static void setPages({
    HomePageState hPage,
    MapsState mPage,
    //UserPageState uPage,
    MetadataSectionState dPage,
    LoggedInScreenState lPage,
    SettingsState sPage,
  }) {
    if (hPage != null) homePage = hPage;
    if (mPage != null) mapPage = mPage;
    //if (uPage != null) userPage = uPage;
    if (dPage != null) dataPage = dPage;
    if (lPage != null) logPage = lPage;
    if (sPage != null) settings = sPage;
  }

  static void logInSwitch() {
    access = true;
  }

  //Navigates to the page as specified in the home index
  static void navigateTo(int page) {
    homePage.pageNavigator(page);
  }

  //Returns the active user, null if null
  static String getUser() {
    //return userPage.getUser();
    return logPage.getUser();
  }

  static void moveAndCreateDrag(String filename) {
    navigateTo(2);
    dataPage.createNewDrag(filename);
  }

  static void sendTickData(Map<String, Map<String, int>> data) {
    dataPage.sendSegmentedTickData(data);
  }

  static int emptyRef() {
    if (logPage == null) return 0;
    if (mapPage == null) return 1;
    if (dataPage == null) return 2;
    if (settings == null) return 3;

    return -1;
  }

  static void tempCelsius(bool state) {
    dataPage.tempCelsius(state);
    //logPage.tempCelsius(state);
  }

  static void autoMarking(bool state) {
    mapPage.setAutoTracking(state);
  }

  static void setMarkingDistance(double distance) {
    mapPage.setDistanceMarker(distance);
  }

  static void settingSoundPref(bool set) {
    mapPage.setSoundPref(set);
  }

  static void settingMarkerMethod(bool setting) {
    mapPage.setMarkerMethod(setting);
  }

  static void setTimePerMarker(double time) {
    mapPage.setTimeOfMarker(time);
  }

  static void cancelCurrentDrag() {
    mapPage.stepsToTerminateNDelete();
  }

  static void checkSettings() {
    settings.settingsChecker();
  }

  static void upDateTickData() {
    dataPage.updateTickText();
  }

  static void addTickSegmentData(String title, Map<String, int> map) {
    mapPage.storeSegmentData(title, map);
    dataPage.setTickData(map);
  }

  static void removeLasMarker() {
    mapPage.removeLatestMarker();
  }

  static void setSync(String f, bool b) {
    dataPage.changeSync(f, b);
  }

  static void posSubDispose() {
    mapPage.positionSubDispose();
  }
}
