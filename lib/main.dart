import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/faauthentication.dart';
import 'package:wallet/homepage.dart';
import 'package:wallet/splshscreen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  String uid = "";
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  uid = prefs.getString("uid").toString();

  await Firebase.initializeApp();
  if (uid.toString() != "null") {
    await walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("verified")
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value == null) {
        uid = "unverified";
      }
    });
  }
  runApp(MyApp(
    uid: uid,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.uid});
  String uid;

  route() {
    if (uid.toString() == "null") {
      return const SplashScreen();
    } else if (uid.toString() == "unverified") {
      return const AuthenticationPage();
    } else {
      return const DashboardScreen();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
          primarySwatch: Colors.blue,
        ),
        home: route());
  }
}

Color primarycolor = const Color(0xff4698B4);
Color primarycolorGold = const Color(0xffd4af37);

showmessageofalert(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

savenotification(String message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String notificationuid = const Uuid().v1().toString();
  Map map = {
    "uid": notificationuid,
    "message": message,
    "time": DateTime.now().toString(),
  };
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("Notifications")
      .child(notificationuid)
      .set(map);
}
