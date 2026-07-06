import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcome;

  /// No description provided for @findPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find Places'**
  String get findPlaces;

  /// No description provided for @famousPlaces.
  ///
  /// In en, this message translates to:
  /// **'Popular places'**
  String get famousPlaces;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @recommendPlaces.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendPlaces;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get category;

  /// No description provided for @toshkent.
  ///
  /// In en, this message translates to:
  /// **'Tashkent'**
  String get toshkent;

  /// No description provided for @andijon.
  ///
  /// In en, this message translates to:
  /// **'Andijan'**
  String get andijon;

  /// No description provided for @namangan.
  ///
  /// In en, this message translates to:
  /// **'Namangan'**
  String get namangan;

  /// No description provided for @fargona.
  ///
  /// In en, this message translates to:
  /// **'Fergana'**
  String get fargona;

  /// No description provided for @samarqand.
  ///
  /// In en, this message translates to:
  /// **'Samarkand'**
  String get samarqand;

  /// No description provided for @surxondaryo.
  ///
  /// In en, this message translates to:
  /// **'Surkhandaryo'**
  String get surxondaryo;

  /// No description provided for @xorazm.
  ///
  /// In en, this message translates to:
  /// **'Xorazm'**
  String get xorazm;

  /// No description provided for @navoiy.
  ///
  /// In en, this message translates to:
  /// **'Navoiy'**
  String get navoiy;

  /// No description provided for @qoraqol.
  ///
  /// In en, this message translates to:
  /// **'Karakalpakstan'**
  String get qoraqol;

  /// No description provided for @sirdaryo.
  ///
  /// In en, this message translates to:
  /// **'Sirdaryo'**
  String get sirdaryo;

  /// No description provided for @buxoro.
  ///
  /// In en, this message translates to:
  /// **'Bukhara'**
  String get buxoro;

  /// No description provided for @qashqa.
  ///
  /// In en, this message translates to:
  /// **'Qashqadaryo'**
  String get qashqa;

  /// No description provided for @jizzax.
  ///
  /// In en, this message translates to:
  /// **'Jizzakh'**
  String get jizzax;

  /// No description provided for @boshqalar.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get boshqalar;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get myPosts;

  /// No description provided for @mySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved posts'**
  String get mySaved;

  /// No description provided for @myLiked.
  ///
  /// In en, this message translates to:
  /// **'My liked posts'**
  String get myLiked;

  /// No description provided for @noInfo.
  ///
  /// In en, this message translates to:
  /// **'No posts!'**
  String get noInfo;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @likedBy.
  ///
  /// In en, this message translates to:
  /// **'people liked'**
  String get likedBy;

  /// No description provided for @fullInfo.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get fullInfo;

  /// No description provided for @addedSaved.
  ///
  /// In en, this message translates to:
  /// **'Added to the saved posts'**
  String get addedSaved;

  /// No description provided for @removeSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the saved posts'**
  String get removeSaved;

  /// No description provided for @wantDelete.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete posts?'**
  String get wantDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continu.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continu;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit?'**
  String get exit;

  /// No description provided for @searchResult.
  ///
  /// In en, this message translates to:
  /// **'Search Result'**
  String get searchResult;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @resetPass.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPass;

  /// No description provided for @toEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Parolni yangilash uchun elektron pochta manzilingizni kiriting'**
  String get toEnterEmail;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Elektron manzilizni kiriting'**
  String get enterEmail;

  /// No description provided for @enterPass.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPass;

  /// No description provided for @smsSent.
  ///
  /// In en, this message translates to:
  /// **'Elektron pochtangizga parolni yangilash uchun xabar jo\'natildi'**
  String get smsSent;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmail;

  /// No description provided for @checkEmailOrPass.
  ///
  /// In en, this message translates to:
  /// **'Check your email or password'**
  String get checkEmailOrPass;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passValidator.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters: \n Uppercase and lowercase letters, \n and numbers'**
  String get passValidator;

  /// No description provided for @forgotPass.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPass;

  /// No description provided for @notMember.
  ///
  /// In en, this message translates to:
  /// **'Not a member?'**
  String get notMember;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullname;

  /// No description provided for @enterLastname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your lastname'**
  String get enterLastname;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your fullname'**
  String get enterFullName;

  /// No description provided for @enterValidPass.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters: Uppercase and \n lowercase letters, and 1 number'**
  String get enterValidPass;

  /// No description provided for @confirmPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPass;

  /// No description provided for @notMatch.
  ///
  /// In en, this message translates to:
  /// **'Not Match'**
  String get notMatch;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyMember;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered from the system'**
  String get success;

  /// No description provided for @usedEmail.
  ///
  /// In en, this message translates to:
  /// **'This email was already used'**
  String get usedEmail;

  /// No description provided for @tryLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryLater;

  /// No description provided for @validInfo.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid information'**
  String get validInfo;

  /// No description provided for @newAdded.
  ///
  /// In en, this message translates to:
  /// **'New Added'**
  String get newAdded;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotel;

  /// No description provided for @sanatoriya.
  ///
  /// In en, this message translates to:
  /// **'Sanatoriums'**
  String get sanatoriya;

  /// No description provided for @damOlish.
  ///
  /// In en, this message translates to:
  /// **'Recreation areas'**
  String get damOlish;

  /// No description provided for @basseyn.
  ///
  /// In en, this message translates to:
  /// **'Swimming pools'**
  String get basseyn;

  /// No description provided for @dacha.
  ///
  /// In en, this message translates to:
  /// **'Country Houses'**
  String get dacha;

  /// No description provided for @discoverUz.
  ///
  /// In en, this message translates to:
  /// **'Discover Uzbekistan \n with Us!'**
  String get discoverUz;

  /// No description provided for @adminPage.
  ///
  /// In en, this message translates to:
  /// **'For now, The posts will be uploaded by only admin!'**
  String get adminPage;

  /// No description provided for @aloqa.
  ///
  /// In en, this message translates to:
  /// **'Contact:'**
  String get aloqa;

  /// No description provided for @searchInfo.
  ///
  /// In en, this message translates to:
  /// **'No data found!'**
  String get searchInfo;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @getSMS.
  ///
  /// In en, this message translates to:
  /// **'Get SMS code'**
  String get getSMS;

  /// No description provided for @registerWith.
  ///
  /// In en, this message translates to:
  /// **'Register with the following:'**
  String get registerWith;

  /// No description provided for @verifySMS.
  ///
  /// In en, this message translates to:
  /// **'SMS code confirmation'**
  String get verifySMS;

  /// No description provided for @smsAuto.
  ///
  /// In en, this message translates to:
  /// **'The SMS code will be checked automatically'**
  String get smsAuto;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number: '**
  String get verifyPhone;

  /// No description provided for @reSend.
  ///
  /// In en, this message translates to:
  /// **'Resend a request'**
  String get reSend;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search places...'**
  String get searchPlaceholder;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @resendSms.
  ///
  /// In en, this message translates to:
  /// **'Resend SMS'**
  String get resendSms;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover Uzbekistan'**
  String get appTagline;

  /// No description provided for @telegramHint.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent via Telegram'**
  String get telegramHint;

  /// No description provided for @phoneIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Phone number is incomplete'**
  String get phoneIncomplete;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @googleSignInError.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInError;

  /// No description provided for @phoneNumberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Phone number not found'**
  String get phoneNumberNotFound;

  /// No description provided for @timeExpired.
  ///
  /// In en, this message translates to:
  /// **'Time expired'**
  String get timeExpired;

  /// No description provided for @enterYourInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your details'**
  String get enterYourInfo;

  /// No description provided for @registerProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Provide your first and last name for your profile'**
  String get registerProfileHint;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameRequired;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get next;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by MrDil'**
  String get createdBy;

  /// No description provided for @externalReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews from external maps'**
  String get externalReviewsTitle;

  /// No description provided for @externalReviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews from this source'**
  String get externalReviewsEmpty;

  /// No description provided for @externalReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String externalReviewsCount(String count);

  /// No description provided for @externalReviewsMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more...'**
  String externalReviewsMore(String count);

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to like, save places and leave comments.'**
  String get loginRequiredMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
