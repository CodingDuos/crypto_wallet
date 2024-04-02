import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/homepage.dart';
import 'package:wallet/splshscreen.dart';

import 'main.dart';

class lofinpage extends StatefulWidget {
  const lofinpage({super.key});

  @override
  State<lofinpage> createState() => _lofinpageState();
}

class _lofinpageState extends State<lofinpage> {
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController keywordsscontroller = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  List<String> keywords = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Enter Your Wallet Address",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: addresscontroller,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: "Enter Address",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff262528),
                    prefixIcon: const Icon(
                      Iconsax.personalcard,
                      color: Colors.white,
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              child: TextField(
                controller: keywordsscontroller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Enter password",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff262528),
                    prefixIcon: const Icon(
                      Iconsax.personalcard,
                      color: Colors.white,
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            errormessage.isEmpty
                ? Container()
                : Text(
                    errormessage,
                    style: const TextStyle(color: Colors.red),
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: MaterialButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  print(prefs.getString("finger"));
                  if (prefs.getString("finger").toString() == "true") {
                    print("object authed true");
                    bool isAuthenticated =
                        await _localAuthentication.authenticate(
                      localizedReason: 'Scan your fingerprint to authenticate',
                    );

                    if (isAuthenticated) {
                      print("object authed");
                      if (isloading == false) {
                        setState(() {
                          errormessage = "";
                          isloading = true;
                        });
                        walleTRefrence
                            .child(addresscontroller.text)
                            .once()
                            .then((DatabaseEvent databaseEvent) async {
                          if (databaseEvent.snapshot.value != null) {
                            if (databaseEvent.snapshot
                                    .child("password")
                                    .value
                                    .toString()
                                    .trim() ==
                                keywordsscontroller.text.toString().trim()) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString(
                                  "uid",
                                  databaseEvent.snapshot
                                      .child("uid")
                                      .value
                                      .toString());
                              // ignore: use_build_context_synchronously
                              showmessageofalert(context, "Login Successfully");
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DashboardScreen()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              errormessage = "Wrong Password";
                            }
                            setState(() {
                              isloading = false;
                            });
                          } else {
                            setState(() {
                              errormessage =
                                  "Invalid Wallet Address , Not found";
                              isloading = false;
                            });
                          }
                        });
                      }
                    } else {
                      showmessageofalert(context, "Authentication Failed");
                    }
                  } else {
                    print("object failed authed");
                    if (isloading == false) {
                      setState(() {
                        errormessage = "";
                        isloading = true;
                      });
                      walleTRefrence
                          .child(addresscontroller.text)
                          .once()
                          .then((DatabaseEvent databaseEvent) async {
                        if (databaseEvent.snapshot.value != null) {
                          if (databaseEvent.snapshot
                                  .child("password")
                                  .value
                                  .toString()
                                  .trim() ==
                              keywordsscontroller.text.toString().trim()) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.clear();
                            prefs.setString(
                                "uid",
                                databaseEvent.snapshot
                                    .child("uid")
                                    .value
                                    .toString());
                            // ignore: use_build_context_synchronously
                            showmessageofalert(context, "Login Successfully");
                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardScreen()),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            errormessage = "Wrong Password";
                          }
                          setState(() {
                            isloading = false;
                          });
                        } else {
                          setState(() {
                            errormessage = "Invalid Wallet Address , Not found";
                            isloading = false;
                          });
                        }
                      });
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)),
                  height: 48,
                  child: Center(
                    child: isloading == true
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Login Wallet",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List userkeywords = [];
  bool isloading = false;
  String errormessage = "";
}
