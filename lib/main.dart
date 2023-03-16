import 'package:discoveruzb/screens/introPages/splash_page.dart';
import 'package:discoveruzb/service/themes.dart';
import 'package:discoveruzb/view_models/account_vm.dart';
import 'package:discoveruzb/view_models/comment_vm.dart';
import 'package:discoveruzb/view_models/create_gallery_vm.dart';
import 'package:discoveruzb/view_models/details_vm.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:discoveruzb/view_models/main_vm.dart';
import 'package:discoveruzb/view_models/media_page.dart';
import 'package:discoveruzb/view_models/sub_category_vm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('person');
  await Hive.openBox('restore');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => MediaPageVM()),
        ChangeNotifierProvider(create: (_) => AccountViewModel()),
        ChangeNotifierProvider(create: (_) => SubCategoryVM()),
        ChangeNotifierProvider(create: (_) => DetailsVM()),
        ChangeNotifierProvider(create: (_) => CommentVM()),
        ChangeNotifierProvider(create: (_) => CreateGalleryVM()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String theme = "light";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('uz', ''), // Uzbek
        Locale('ru', ''), // Russian, no country code
      ],
      themeMode: ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        minWidth: 480,
        defaultScale: true,
        breakpoints: const [
          ResponsiveBreakpoint.resize(480, name: MOBILE),
          ResponsiveBreakpoint.resize(800, name: TABLET),
          ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          ResponsiveBreakpoint.resize(2460, name: "4K"),
        ],
      ),
      home: const SplashPage(),
    );
  }
}
