import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/homepage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:wallet/splshscreen.dart';

import 'main.dart';

class chnagepinpage extends StatefulWidget {
  const chnagepinpage({super.key});

  @override
  State<chnagepinpage> createState() => _chnagepinpageState();
}

class _chnagepinpageState extends State<chnagepinpage> {
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
    fetchmyuid();

    // TODO: implement initState
    super.initState();
  }

  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    walleTRefrence.child(uid).once().then((DatabaseEvent databaseEvent) async {
      if (databaseEvent.snapshot.value != null) {
        setState(() {
          email = databaseEvent.snapshot.child("email").value.toString();
        });
        timerfunction();
        await otpfetch();
        await sendOTP(email, otpnumber, context);
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  String uid = "";
  String email = "";

  var otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text("Forgot Pin?"),
        ),
        backgroundColor: const Color(0xff181818),
        body: email.isEmpty
            ? Container(
                child: const Center(
                  child: CircularProgressIndicator(),
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
                                                  email, otpnumber, context);
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
                                  // ignore: use_build_context_synchronously
                                  await screenLock(
                                      context: context,
                                      correctString: "1234",
                                      title: Column(
                                        children: const [
                                          Text("Update 4 Digit Pin"),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "To protext access of your wallet on this device, create a new digit pin",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      onValidate: (input) async {
                                        await updatepin(input, context);
                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DashboardScreen()),
                                          (Route<dynamic> route) => false,
                                        );

                                        // Navigator.pop(context);
                                        return true;
                                      },
                                      onUnlocked: () {
                                        print("object masheamo");
                                      });
                                  // ignore: use_build_context_synchronously
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

    // try {
    //   var useremail = "shahlili1645@gmail.com";
    //   var message = Message();
    //   message.subject = "subject = 'OTP Verification";
    //   message.text = "Your OTP is $otp";
    //   message.from = Address(useremail.toString());
    //   message.recipients.add(email);
    //   var otpservice = gmailSaslXoauth2(useremail, "ketcshvkimrcwcap");
    //  await send(message, otpservice);

    //   print('OTP sent successfully');
    // } catch (e) {
    //   print('Error sending OTP: $e');
    // }
  }
}

textfieldwidgets(
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

textfieldwidgettitles(String labeltext, TextInputType keytype) {
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

titlewidgets(IconData icon, String text) {
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
