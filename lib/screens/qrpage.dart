import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';

class QrpageMain extends StatefulWidget {
  const QrpageMain({super.key});

  @override
  State<QrpageMain> createState() => _QrpageMainState();
}

class _QrpageMainState extends State<QrpageMain> {
  String uid = "";
  fetchuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    setState(() {});
  }

  @override
  void initState() {
    fetchuid();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      appBar: AppBar(
        backgroundColor: primarycolorGold,
        title: const Text("Scan QR"),
      ),
      body: uid.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.white,
                    child: QrImage(
                      data: uid,
                      size: 200,
                      // You can include embeddedImageStyle Property if you
                      //wanna embed an image from your Asset folder
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: const Size(
                          100,
                          100,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "or share the wallet address",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        uid,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 8),
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
                  )
                ],
              ),
            ),
    );
  }
}
