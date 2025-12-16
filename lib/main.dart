import 'package:discoveruzb/screens/introPages/splash_page.dart';
import 'package:discoveruzb/service/themes.dart';
import 'package:discoveruzb/view_models/account_vm.dart';
import 'package:discoveruzb/view_models/comment_vm.dart';
import 'package:discoveruzb/view_models/create_gallery_vm.dart';
import 'package:discoveruzb/view_models/details_vm.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:discoveruzb/view_models/login_vm.dart';
import 'package:discoveruzb/view_models/main_vm.dart';
import 'package:discoveruzb/view_models/media_page.dart';
import 'package:discoveruzb/view_models/otp_vm.dart';
import 'package:discoveruzb/view_models/registration_vm.dart';
import 'package:discoveruzb/view_models/search_vm.dart';
import 'package:discoveruzb/view_models/splash_vm.dart';
import 'package:discoveruzb/view_models/sub_category_vm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('person');
  await Hive.openBox('restore');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => OTPViewModel()),
        ChangeNotifierProvider(create: (_) => RegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
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
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const SplashPage(),
    );
  }
}
