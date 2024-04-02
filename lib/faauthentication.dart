import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/homepage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'main.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool codesended = false;
  int seconds = 60;
  timerfunction() {
    setState(() {
      seconds = 60;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds != 0) {
        if (mounted) {
          setState(() {
            seconds--;
          });
        }
      } else {
        setState(() {
          otpnumber = "0";
        });
        timer.cancel();
      }
    });
  }

  String otpnumber = "";
  otpfetch() {
    setState(() {
      otpnumber = generateOTP().toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  var usernamecontroller = TextEditingController();
  var phonecontroller = TextEditingController();

  var otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text("2FA Authentication"),
        ),
        backgroundColor: const Color(0xff181818),
        body: codesended == false
            ? AnimatedContainer(
                duration: const Duration(seconds: 1),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 20, right: 20),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.password_sharp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            textfieldwidget(passwordcontroller,
                                "Enter Password", TextInputType.text),
                            titlewidget(Icons.email, "Email Address"),
                            textfieldwidget(emailcontroller, "Enter Email",
                                TextInputType.text),
                            titlewidget(Icons.person, "Username"),
                            textfieldwidget(usernamecontroller,
                                "Enter Username", TextInputType.text),
                            titlewidget(Icons.phone, "Phone"),
                            textfieldwidget(phonecontroller, "Enter Phone",
                                TextInputType.number),
                            //  titlewidget(Icons.email, "Email Address"),
                            // textfieldwidget(emailcontroller, "Enter Email")
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      errormessage.isEmpty
                          ? Container()
                          : Text(
                              errormessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30, top: 30),
                        child: MaterialButton(
                          onPressed: () async {
                            print(emailcontroller.text.contains("@"));
                            print(emailcontroller.text.contains("."));
                            setState(() {
                              isloading = true;
                              errormessage = "";
                            });
                            if (passwordcontroller.text.length < 8) {
                              errormessage = "Enter 8 digits Password";
                            } else if (emailcontroller.text.isEmpty) {
                              errormessage = "Enter Valid Email Address";
                            } else if (emailcontroller.text.contains("@") ==
                                false) {
                              errormessage = "Enter Valid Email Address";
                            } else if (emailcontroller.text.contains(".") ==
                                false) {
                              errormessage = "Enter Valid Email Address";
                            } else if (usernamecontroller.text.isEmpty) {
                              errormessage = "Enter Username";
                            } else if (emailcontroller.text.isEmpty) {
                              errormessage = "Enter Phone";
                            } else {
                              await savewmail();
                              await otpfetch();
                              await sendOTP(
                                  emailcontroller.text, otpnumber, context);
                            }
                            setState(() {
                              isloading = false;
                            });
                          },
                          child: isloading == true
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffd4af37),
                                      borderRadius: BorderRadius.circular(10)),
                                  width: double.infinity,
                                  height: 52,
                                  child: const Center(
                                    child: Text(
                                      "Send Code",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : AnimatedContainer(
                duration: const Duration(seconds: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                Row(
                                  children: const [
                                    Text(
                                      "Enter Verification Code",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Text(
                                      "Enter the code send to your email to verify",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: TextField(
                              controller: otp,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                    padding: const EdgeInsets.all(17.0),
                                    child: seconds == 0
                                        ? TextButton(
                                            onPressed: () async {
                                              timerfunction();
                                              await otpfetch();
                                              // ignore: use_build_context_synchronously
                                              await sendOTP(
                                                  emailcontroller.text,
                                                  otpnumber,
                                                  context);
                                              // ignore: use_build_context_synchronously
                                              showmessageofalert(
                                                  context, "Code Resended");
                                            },
                                            child: const Text(
                                              "Resend",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : const Text("")),
                                fillColor: Colors.black.withOpacity(0.3),
                                filled: true,
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                                label: const Text("Enter Code"),
                                labelStyle: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    seconds == 0
                                        ? "Code Expired, click Resend to Resend the OTP to your Email"
                                        : "Codes Expires in $seconds Seconds",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    seconds == 0
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: MaterialButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                if (otp.text == otpnumber) {
                                  walleTRefrence
                                      .child(prefs.getString("uid").toString())
                                      .child("verified")
                                      .set("true");
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                } else {
                                  showmessageofalert(context, "Invalid OTP");
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xffd4af37),
                                    borderRadius: BorderRadius.circular(10)),
                                width: double.infinity,
                                height: 52,
                                child: const Center(
                                  child: Text(
                                    "Verify",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ));
  }

  final walleTRefrence = FirebaseDatabase.instance.ref("Users");
  bool isloading = false;

  savewmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("email")
        .set(emailcontroller.text);
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("password")
        .set(passwordcontroller.text);
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("otp")
        .set("123456");
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("phone")
        .set(phonecontroller.text);
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("username")
        .set(usernamecontroller.text);
  }

  Future<void> sendOTP(String email, String otp, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = 'shahlili1645@gmail.com';
    String password = 'lfzhdzgojlhsgubh';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Shah Lili')
      ..recipients.add(email)
      ..subject = 'Email Verification of E-Gold :: ${DateTime.now()}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Test</h1>\n<p>Hey! E-Gold App , Authentication Code of Your Wallet is $otp</p>";
    try {
      final sendReport = await send(message, smtpServer);
      setState(() {
        codesended = true;
      });
      timerfunction();
      // ignore: use_build_context_synchronously
      showmessageofalert(context, "6 digits otp send to your email $email");
    } on MailerException catch (e) {
      // ignore: use_build_context_synchronously
      showmessageofalert(context, "OTP not sent. $e");
      for (var p in e.problems) {
        // ignore: use_build_context_synchronously
        showmessageofalert(context, "Problem: ${p.code}: ${p.msg}");
      }
    }

  }
}

textfieldwidget(
    TextEditingController controller, String labeltext, TextInputType keytype) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: TextField(
      keyboardType: keytype,
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.black.withOpacity(0.3),
        filled: true,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
        label: Text(labeltext),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
  );
}

textfieldwidgettitle(String labeltext, TextInputType keytype) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: TextField(
      readOnly: true,
      keyboardType: keytype,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        fillColor: Colors.black.withOpacity(0.3),
        filled: true,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        hintText: labeltext,
      ),
    ),
  );
}

titlewidget(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    ),
  );
}

String generateOTP() {
  Random random = Random();
  int otp = random.nextInt(999999);
  return otp.toString().padLeft(6, '0');
}

String errormessage = "";
