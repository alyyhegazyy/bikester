import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_sharing_app/dataHandler/appdata.dart';
import 'package:vehicle_sharing_app/screens/home_page.dart';
import 'package:vehicle_sharing_app/screens/login_page.dart';
import 'package:vehicle_sharing_app/screens/onboarding_page.dart';
import 'package:vehicle_sharing_app/services/authentication_service.dart';
import 'package:vehicle_sharing_app/utils/app_router.dart';

import 'notifier/station_bloc.dart';

int initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:297855924061:ios:c6de2b69b03a5be8',
            apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '297855924061',
            databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:345376185565:android:6a4af9507c2103694f4f34',
            apiKey: 'AIzaSyAIbAkWiUW7Q1recjEIsqVb8pwSqx2R7zw',
            messagingSenderId: '345376185565',
            projectId: 'bikester-6e598',
            databaseURL: 'https://bikester-6e598-default-rtdb.firebaseio.com',
          ),
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt('initScreen');
  await prefs.setInt('initScreen', 1);

  runApp(MyApp(initScreen));
}

class MyApp extends StatelessWidget {
  final int initScreen;
  const MyApp(this.initScreen, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => AuthenticationService(FirebaseAuth.instance)),
        ChangeNotifierProvider(create: (_) => AppData()),
        ChangeNotifierProvider(create: (_) => StationBloc()),
        StreamProvider(create: (context) => context.read<AuthenticationService>().authStateChanges),
      ],
      child: MaterialApp(
        title: 'Bikester',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primaryColor: Color.fromRGBO(0, 0, 0, 1),
        ),
        routes: AppRouter.routes,
        // initialRoute: initScreen == 0 || initScreen == null ? OnboradingPage.routeName : AuthenticationWrapper.routeName,
        initialRoute: OnboradingPage.routeName,
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  static const String routeName = '/auth';

  const AuthenticationWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}
