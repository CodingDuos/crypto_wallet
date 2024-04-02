import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';
import 'package:wallet/homepage.dart';
import 'package:wallet/keywords.dart';
import 'package:wallet/login.dart';
import 'package:wallet/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff181818),
        body: SizedBox(
          height: myHeight,
          width: myWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  color: const Color(0xff181818),
                  height: 300,
                  child: LottieBuilder.asset("images/2.json")),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'EGOLD',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffd4af37)),
                  ),
                ],
              ),
              Column(
                children: [
                  MaterialButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const DashboardScreen()));
                      screenLock(
                          context: context,
                          correctString: "1234",
                          title: Column(
                            children: const [
                              Text("Create 4 Digit Pin"),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "To protect wallet create a new digit pin",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          onValidate: (input) async {
                            createuser(input, context);

                            // Navigator.pop(context);
                            return true;
                          },
                          onUnlocked: () {
                            print("object masheamo");
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xffd4af37),
                          borderRadius: BorderRadius.circular(10)),
                      width: double.infinity,
                      height: 52,
                      child: const Center(
                        child: Text(
                          "Create New Wallet ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const lofinpage()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffd4af37)),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      width: double.infinity,
                      height: 52,
                      child: const Center(
                        child: Text(
                          "Already have a wallet",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xffd4af37)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final walleTRefrence = FirebaseDatabase.instance.ref("Users");

createuser(String pincode, BuildContext context) async {
  String uid = const Uuid().v4().toString();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("uid", uid);

  Map usermap = {
    "uid": uid,
    "createdAt": DateTime.now().toString(),
    "pinCode": pincode
  };
  await walleTRefrence.child(uid).set(usermap);
  // ignore: use_build_context_synchronously
  await addwallet(uid, context);
  // ignore: use_build_context_synchronously
  showmessageofalert(context, "User added Successfully");
  // ignore: use_build_context_synchronously
}

updatepin(String pincode, BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("pinCode")
      .set(pincode);
  // ignore: use_build_context_synchronously
  showmessageofalert(context, "pin updated  Successfully");
  // ignore: use_build_context_synchronously
}

addwallet(uid, BuildContext context) async {
  String uids = const Uuid().v1().toString();

  Map map = {
    "uid": uids,
    "Balance": 5000,
    "created at": DateTime.now().toString()
  };

  try {
    await walleTRefrence.child(uid).child("wallets").child(uids).set(map);
    // ignore: use_build_context_synchronously
    showmessageofalert(
        context, "Default Wallet added Successfully to User Account");
    // ignore: use_build_context_synchronously
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const KeywordsPage()));
  } catch (e) {
    showmessageofalert(context, e.toString());
  }
}
