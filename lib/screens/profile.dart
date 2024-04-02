import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/faauthentication.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/changepin.dart';
import 'package:wallet/splshscreen.dart';

import '../changepin.dart';

addwallet(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = const Uuid().v1().toString();

  Map map = {
    "uid": uid,
    "Balance": 5000,
    "created at": DateTime.now().toString()
  };

  try {
    await walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("wallets")
        .child(uid)
        .set(map);
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Successfully',
        message: 'Wallet Added',

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  } catch (e) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Failed',
        message: e.toString(),

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  var usernamecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  String uid = "";
  String username = "";

  String email = "";
  String phone = "";
  bool isupadate = false;

  bool savefinger = false;
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  final walleTRefrence = FirebaseDatabase.instance.ref("Users");

  Future<void> savefingerprint() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    if (!canCheckBiometrics) {
      // ignore: use_build_context_synchronously
      showmessageofalert(context, "FingerPrint Not Supported");
    } else {
      savefinger = !savefinger;
      if (savefinger == true) {
        preferences.setString("finger", "true");
      } else {
        preferences.setString("finger", "false");
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Add Wallet",
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
            IconButton(
                onPressed: () async {
                  await addwallet(context);
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ))
          ],
        ),
        elevation: 0,
        backgroundColor: primarycolorGold,
      ),
      backgroundColor: primarycolorGold,
      body: phone.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      color: primarycolorGold,
                      height: 150,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            bottom: 0,
                            left: -50,
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.20)),
                            ),
                          ),
                          Positioned(
                            bottom: -90,
                            right: 10,
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.20)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                  child: Text(
                                "E-GOLD",
                                style: TextStyle(
                                    color: Color(0xff181818),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold),
                              )),
                              const Text(
                                  "-------------Wallet Addrees------------"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    uid,
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: uid));
                                      },
                                      icon: const Icon(Icons.copy))
                                ],
                              )
                            ],
                          ),
                        ],
                      )),
                  Container(
                      child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xff181818),
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(100))),
                    child: isupadate == true
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              textfieldwidget(passwordcontroller,
                                  "Change Password", TextInputType.text),
                              const SizedBox(
                                height: 10,
                              ),
                              textfieldwidget(emailcontroller, "Change Email",
                                  TextInputType.text),
                              const SizedBox(
                                height: 10,
                              ),
                              textfieldwidget(usernamecontroller,
                                  "Change Username", TextInputType.text),
                              const SizedBox(
                                height: 10,
                              ),
                              textfieldwidget(phonecontroller, "Change Phone",
                                  TextInputType.number),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    await updateuser();
                                    setState(() {
                                      isupadate = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 48,
                                    child: const Center(child: Text("Update")),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    setState(() {
                                      isupadate = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 48,
                                    child: const Center(child: Text("cancel")),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 100,
                              )
                            ],
                          )
                        : Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              titlewidget(Icons.person, "Username"),
                              textfieldwidgettitle(
                                  username, TextInputType.text),
                              titlewidget(Icons.person, "Phone"),
                              textfieldwidgettitle(phone, TextInputType.text),
                              titlewidget(Icons.person, "Email"),
                              textfieldwidgettitle(email, TextInputType.text),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    setState(() {
                                      isupadate = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 48,
                                    child: const Center(
                                        child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    )),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () async {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 48,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Finger Lock",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Container(
                                            height: 20,
                                            width: 20,
                                            color: Colors.white,
                                            child: Checkbox(
                                                value: savefinger,
                                                onChanged: (d) {
                                                  savefingerprint();
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    bool saveagain = false;
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.getString("finger").toString() ==
                                        "true") {
                                      saveagain = true;
                                    }
                                    prefs.clear();
                                    if (saveagain == true) {
                                      prefs.setString("finger", "true");
                                    }
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SplashScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 48,
                                    child: const Center(
                                      child: Text(
                                        "Log out",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 120,
                              )
                            ],
                          ),
                  )),
                ],
              ),
            ),
    );
  }

  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    walleTRefrence.child(uid).once().then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        setState(() {
          username = databaseEvent.snapshot.child("username").value.toString();
          email = databaseEvent.snapshot.child("email").value.toString();
          phone = databaseEvent.snapshot.child("phone").value.toString();
          String pincode =
              databaseEvent.snapshot.child("pinCode").value.toString();

          screenLock(
              context: context,
              correctString: "1234",
              canCancel: false,
              title: Column(
                children: [
                  const Text("Enter Your 4 Digit Pin"),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "To protext access of your wallet on this device,Enter Your 4 Digit Pin",
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const chnagepinpage()));
                      },
                      child: const Text("Forgot Pin"))
                ],
              ),
              onValidate: (input) async {
                if (pincode == input) {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                  return true;
                } else {
                  return false;
                }
              },
              onUnlocked: () {
                print("object masheamo");
              });
        });
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    fetchmyuid();
    // TODO: implement initState
    super.initState();
  }

  updateuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (emailcontroller.text.isNotEmpty) {
      walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("email")
          .set(emailcontroller.text);
      email = emailcontroller.text;
    }
    if (passwordcontroller.text.isNotEmpty) {
      walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("password")
          .set(passwordcontroller.text);
    }
    if (usernamecontroller.text.isNotEmpty) {
      walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("username")
          .set(usernamecontroller.text);
      username = usernamecontroller.text;
    }
    if (phonecontroller.text.isNotEmpty) {
      walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("phone")
          .set(phonecontroller.text);
      phone = phonecontroller.text;
    }
  }
}
