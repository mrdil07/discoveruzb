import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  
  iconTheme: const IconThemeData(
    size: 30,
    color: Colors.blue,
  ),
  
  brightness: Brightness.light,
  
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.teal),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.teal,
    ),
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: Colors.grey[800],
      fontSize: 27,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      color: Colors.grey[800],
      fontSize: 25,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      color: Colors.grey[800],
      fontSize: 23,
      fontWeight: FontWeight.w500,
    ),
    headlineLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 21,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: const TextStyle(
      color: Colors.black87,
      fontSize: 19,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      color: Colors.grey[600],
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: const TextStyle(
      color: Colors.black38,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: const TextStyle(
      color: Colors.black87,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.grey[900],
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
  
  iconTheme: const IconThemeData(
    size: 30,
    color: Colors.blue,
  ),
  
  brightness: Brightness.dark,
  
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.grey[900],
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.teal),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.teal,
    ),
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      color: Colors.white,
      fontSize: 27,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: const TextStyle(
      color: Colors.white,
      fontSize: 25,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: const TextStyle(
      color: Colors.white,
      fontSize: 23,
      fontWeight: FontWeight.w500,
    ),
    headlineLarge: const TextStyle(
      color: Colors.white,
      fontSize: 21,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: const TextStyle(
      color: Colors.white,
      fontSize: 19,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: const TextStyle(
      color: Colors.white70,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
  ),
);