import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: Colors.white,

  iconTheme: const IconThemeData(
    size: 30,
    color: Colors.blue,
  ),
  brightness: Brightness.light,
  //primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  primaryIconTheme: const IconThemeData(color: Colors.grey, size: 30),
  scaffoldBackgroundColor: Colors.white,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(
      color: Colors.red[600]!,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    suffixStyle: const TextStyle(
      color: Colors.blue,
    ),
    counterStyle: const TextStyle(color: Colors.black),
    // contentPadding: const EdgeInsets.only(
    //   top: 0.0,
    //   left: 20.0,
    //   right: 20.0,
    //   bottom: 20.0,
    // ),
    isDense: false,
    focusedBorder: OutlineInputBorder(
      // borderRadius: const BorderRadius.only(
      //   topLeft: Radius.circular(7.5),
      //   topRight: Radius.circular(7.5),
      //   bottomLeft: Radius.circular(7.5),
      //   bottomRight: Radius.circular(7.5),
      // ),
      //borderRadius: BorderRadius.circular(2.0),
      borderSide: BorderSide(color: Colors.blue[700]!, width: 1.2),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide:
          BorderSide(color: Color.fromARGB(255, 190, 190, 190), width: 1.2),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(
        width: 1.2,
        color: Color.fromARGB(255, 190, 190, 190),
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.red[600]!, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.red[600]!, width: 1.2),
    ),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
      color: Colors.grey[800],
      fontSize: 27,
      fontWeight: FontWeight.w700,
    ),
    headline2: TextStyle(
      color: Colors.grey[800],
      fontSize: 25,
      fontWeight: FontWeight.w700,
    ),
    headline3: TextStyle(
      color: Colors.grey[800],
      fontSize: 23,
      fontWeight: FontWeight.w500,
    ),
    headline4: const TextStyle(
      color: Colors.black87,
      fontSize: 21,
      fontWeight: FontWeight.w500,
    ),
    headline5: const TextStyle(
      color: Colors.black87,
      fontSize: 19,
      fontWeight: FontWeight.w500,
    ),
    headline6: TextStyle(
      color: Colors.grey[600],
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    bodyText1: const TextStyle(
      color: Colors.black38,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    subtitle1: const TextStyle(
      color: Colors.black87,
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    subtitle2: const TextStyle(
      color: Colors.black87,
      fontSize: 27,
      fontWeight: FontWeight.w400,
    ),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    //shadowColor: Colors.blue,
    iconTheme: IconThemeData(color: Colors.black87, size: 30),
    actionsIconTheme: IconThemeData(color: Colors.black87, size: 30),
    titleSpacing: NavigationToolbar.kMiddleSpacing,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  tabBarTheme: TabBarTheme(
    labelStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    labelColor: Colors.red[600]!, //Color.fromARGB(255, 50, 50, 50),
    unselectedLabelStyle: const TextStyle(
      color: Colors.yellow,
      fontSize: 18,
    ),
    unselectedLabelColor: const Color.fromARGB(255, 50, 50, 50),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Colors.red[600]!, width: 3.5),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      primary: Colors.grey[500],
      shape: const StadiumBorder(),
      side: const BorderSide(
        color: Colors.transparent,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.transparent,
      onPrimary: Colors.grey[500],
      onSurface: Colors.red,
      shadowColor: Colors.transparent,
      shape: const StadiumBorder(),
      // side: BorderSide(
      //   color: Colors.transparent,
      // ),
    ),
  ),
  buttonBarTheme: const ButtonBarThemeData(
    alignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
  ),
  splashColor: Colors.red.withAlpha(30),
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 3,
  ),
  //buttonColor: Colors.white,
  buttonTheme: ButtonThemeData(
    disabledColor: Colors.black12,
    focusColor: Colors.black12,
    buttonColor: Colors.white,
    splashColor: Colors.red.withAlpha(30),
    //textTheme: ButtonTextTheme.primary,
    colorScheme: ColorScheme(
      primary: Colors.grey,
      secondary: Colors.green,
      background: Colors.red,
      surface: Colors.grey[900]!,
      brightness: Brightness.light,
      error: const Color(0xffcf6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
    splashColor: Colors.red.withAlpha(30),
    highlightElevation: 6,
    elevation: 4,
  ),

  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.white,
    shape: CircularNotchedRectangle(),
    elevation: 3,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: Colors.red,
    unselectedItemColor: Colors.grey,
  ),
  dividerTheme: const DividerThemeData(
    color: Colors.black12,
    thickness: 1,
    // space: 0,
    // indent: 0,
    // endIndent: 0,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black87),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(
    //size: 30,
    color: Colors.white,
  ),
  brightness: Brightness.dark,
  //primarySwatch: Colors.grey,
  primaryColor: Colors.grey[900],
  primaryIconTheme: const IconThemeData(color: Colors.white, size: 30),
  scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(
      color: Colors.red[600]!,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    suffixStyle: const TextStyle(
      color: Colors.white,
    ),
    counterStyle: const TextStyle(color: Colors.black),
    fillColor: Colors.grey[800],
    contentPadding: const EdgeInsets.only(
      top: 0.0,
      left: 20.0,
      right: 20.0,
      bottom: 14.0,
    ),

    filled: true,
    isDense: false,
    //focusedBorder:
    //hintStyle: const TextStyle(color: Colors.black),

    focusedBorder: OutlineInputBorder(
      // borderRadius: const BorderRadius.only(
      //   topLeft: Radius.circular(7.5),
      //   topRight: Radius.circular(7.5),
      //   bottomLeft: Radius.circular(7.5),
      //   bottomRight: Radius.circular(7.5),
      // ),
      //borderRadius: BorderRadius.circular(2.0),
      borderSide: BorderSide(color: Colors.blue[700]!, width: 1.2),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide:
          BorderSide(color: Color.fromARGB(255, 190, 190, 190), width: 1.2),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(
        width: 1.2,
        color: Color.fromARGB(255, 190, 190, 190),
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.red[600]!, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.red[600]!, width: 1.2),
    ),
  ),

  textTheme: const TextTheme(
    headline1: TextStyle(
      color: Colors.white,
      fontSize: 27,
      fontWeight: FontWeight.w500,
    ),
    headline2: TextStyle(
      color: Colors.white,
      fontSize: 25,
      fontWeight: FontWeight.w500,
    ),
    headline3: TextStyle(
      color: Colors.white,
      fontSize: 23,
      fontWeight: FontWeight.w500,
    ),
    headline4: TextStyle(
      color: Colors.white,
      fontSize: 21,
      fontWeight: FontWeight.w500,
    ),
    headline5: TextStyle(
      color: Colors.white,
      fontSize: 19,
      fontWeight: FontWeight.w500,
    ),
    headline6: TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    bodyText1: TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.grey[900],
    elevation: 3,
    //shadowColor: Colors.blue,
    iconTheme: const IconThemeData(color: Colors.white, size: 30),
    actionsIconTheme: const IconThemeData(color: Colors.white, size: 30),
    // titleTextStyle: const TextStyle(
    //     // //color: Color.fromARGB(255, 3, 78, 162),
    //     // color: Colors.black87,
    //     // fontFamily: "HP Simplified",
    //     // fontWeight: FontWeight.w500,
    //     // fontStyle: FontStyle.normal,
    //     // fontSize: 30,
    //     // letterSpacing: 0.0,
    //     ),
    titleSpacing: NavigationToolbar.kMiddleSpacing,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    toolbarTextStyle: TextTheme(
      headline1: const TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w500,
      ),
      headline2: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w500,
      ),
      headline3: const TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.w500,
      ),
      headline4: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w500,
      ),
      headline5: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w500,
      ),
      headline6: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      bodyText2: const TextStyle(
        color: Colors.amber,
        fontSize: 15.0,
        fontFamily: 'Hind',
      ),
      button: TextStyle(
        color: Colors.pink[900],
      ),
    ).bodyText2,
    titleTextStyle: TextTheme(
      headline1: const TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w500,
      ),
      headline2: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w500,
      ),
      headline3: const TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.w500,
      ),
      headline4: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w500,
      ),
      headline5: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w500,
      ),
      headline6: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      bodyText2: const TextStyle(
        color: Colors.amber,
        fontSize: 15.0,
        fontFamily: 'Hind',
      ),
      button: TextStyle(
        color: Colors.pink[900],
      ),
    ).headline6,
  ),
  tabBarTheme: TabBarTheme(
    labelStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    labelColor: Colors.white, //Color.fromARGB(255, 50, 50, 50),
    unselectedLabelStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
    ),
    unselectedLabelColor: Colors.white,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Colors.red[600]!, width: 3.5),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      primary: Colors.grey[500],
      shape: const StadiumBorder(),
      side: const BorderSide(
        color: Colors.transparent,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.transparent,
      onPrimary: Colors.grey[500],
      onSurface: Colors.red,
      shadowColor: Colors.transparent,
      shape: const StadiumBorder(),
      // side: BorderSide(
      //   color: Colors.transparent,
      // ),
    ),
  ),
  buttonBarTheme: const ButtonBarThemeData(
    alignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
  ),
  splashColor: Colors.red.withAlpha(30),
  cardTheme: CardTheme(
    color: Colors.grey[800],
    shadowColor: Colors.grey[700],
    elevation: 3,
  ),
  buttonTheme: ButtonThemeData(
    disabledColor: Colors.black12,
    focusColor: Colors.black12,
    buttonColor: Colors.grey[900],
    splashColor: Colors.red.withAlpha(30),
    //textTheme: ButtonTextTheme.primary,
    colorScheme: ColorScheme(
      primary: Colors.red,
      secondary: Colors.green,
      background: Colors.red,
      surface: Colors.grey[900]!,
      brightness: Brightness.light,
      error: const Color(0xffcf6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey[800],
    splashColor: Colors.red.withAlpha(30),
    highlightElevation: 6,
    elevation: 4,
  ),

  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.grey[900],
    shape: const CircularNotchedRectangle(),
    elevation: 3,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.grey[900],
    selectedItemColor: Colors.red,
    unselectedItemColor: Colors.grey,
  ),
  dividerTheme: const DividerThemeData(
    color: Colors.white,
    thickness: 1,
    // space: 0,
    // indent: 0,
    // endIndent: 0,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
);
