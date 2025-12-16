// File generated based on google-services.json
// This file is required by firebase_core 3.x+

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAoDBNoaoN6R13ypCBTeQSQvlgLLP-bjg',
    appId: '1:498913510944:android:cebb0334ef1e39f7d2de45',
    messagingSenderId: '498913510944',
    projectId: 'discoveruzb-354423',
    storageBucket: 'discoveruzb-354423.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0qtYDBoyZ4SZiw_u8AOmgMZ2U36yIdSE',
    appId: '1:498913510944:ios:e441a025fe6074d8d2de45',
    messagingSenderId: '498913510944',
    projectId: 'discoveruzb-354423',
    storageBucket: 'discoveruzb-354423.appspot.com',
    androidClientId: '498913510944-h9v8hd23nerk96rvb9aure9mn6idkq61.apps.googleusercontent.com',
    iosClientId: '498913510944-pthbqn7g6fkdm4bmb8643bkht1p51o8f.apps.googleusercontent.com',
    iosBundleId: 'uz.dizcoveruzb.discoveruzb',
  );

}