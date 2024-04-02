import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';
import 'package:wallet/splshscreen.dart';

class historypage extends StatefulWidget {
  const historypage({super.key});

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {
  fetchuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    setState(() {});
  }

  String uid = "";
  @override
  void initState() {
    fetchuid();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              "Notifications",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: primarycolorGold,
      ),
      body: uid.isEmpty
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : FirebaseAnimatedList(
              query: walleTRefrence.child(uid).child("Notifications"),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return Card(
                  elevation: 10,
                  child: ListTile(
                    subtitle: Text(
                      snapshot.child("time").value.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 8),
                    ),
                    title: Text(
                      snapshot.child("message").value.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                );
              }),
    );
  }
}
