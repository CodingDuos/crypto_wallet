import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:random_words/random_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/faauthentication.dart';
import 'package:wallet/main.dart';

class KeywordsPage extends StatefulWidget {
  const KeywordsPage({super.key});

  @override
  State<KeywordsPage> createState() => _KeywordsPageState();
}

class _KeywordsPageState extends State<KeywordsPage> {
  List<String> keywords = [];
  bool issave = false;
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
        print("object p");
        print(preferences.getString("finger"));
      } else {
        preferences.setString("finger", "false");
        print("object p");
        print(preferences.getString("finger"));
      }
      setState(() {});
    }
  }

  createkeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var element in keywords) {
      print(element);
      String uidofkeys = const Uuid().v4().toString();
      Map keysmap = {"uid": uidofkeys, "key": element};
      if (issave == true) {
        walleTRefrence
            .child(prefs.getString("uid").toString())
            .child("keys")
            .child(uidofkeys)
            .set(keysmap);
      }
    }
  }

  String uid = "";

  fetchwords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    generateNoun().take(12).forEach((e) {
      keywords.add(e.asString);
    });
    setState(() {});
  }

  @override
  void initState() {
    fetchwords();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings"),
        backgroundColor: const Color(0xff181818),
      ),
      body: keywords.isEmpty
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Write down the 12 phrase words in a safe place",
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      uid,
                      style: const TextStyle(color: Colors.amber, fontSize: 8),
                    ),
                    IconButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: uid));
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 3 - 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primarycolorGold)),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 10, right: 10),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 10 / 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 20),
                          itemCount: keywords.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return Container(
                              height: 10,
                              width: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                keywords[index],
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 30,
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              height: 20,
                              width: 20,
                              color: Colors.white,
                              child: Checkbox(
                                  value: issave,
                                  onChanged: (d) {
                                    setState(() {
                                      issave = !issave;
                                    });
                                  }),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "save keywords?",
                              style:
                                  TextStyle(fontSize: 8, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
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
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Finger Lock",
                              style:
                                  TextStyle(fontSize: 8, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    await createkeys();

                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthenticationPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffd4af37),
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    height: 52,
                    child: const Center(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "These 12 phrase words and account address are the only way to restore the wallet please save them in a safe and secure place to ensure your funds safety and access to your wallet in the future",
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
    );
  }
}

List<String> phrasestring = [
  "butter",
  "crypto",
  "cricket",
  "man",
  "women",
  "ball",
  "butter",
  "crypto",
  "cricket",
  "man",
  "women",
  "ball",
];
