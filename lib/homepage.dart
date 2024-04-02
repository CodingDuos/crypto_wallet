import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/screens/home/mainscreen.dart';
import 'package:wallet/screens/home/portfolio.dart';
import 'package:wallet/screens/home/scanner.dart';
import 'package:wallet/screens/market/market.dart';
import 'package:wallet/screens/profile.dart';
import 'package:wallet/splshscreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("Balance")
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        setState(() {
          mybalance = databaseEvent.snapshot.value.toString();
        });
      }
    });
  }

  String mybalance = "";

  @override
  void initState() {
    fetchmyuid();
    // TODO: implement initState
    super.initState();
  }

  int _currentindex = 0;
  List<Widget> screenlist = [
    PortfolioPage(
      balance: "mybalance",
    ),
    const ScannerView(),
    const MarketPage(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenlist[_currentindex],
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          selectedIconTheme: const IconThemeData(color: Colors.blue),
          unselectedItemColor: Colors.black,
          unselectedFontSize: 12,
          selectedFontSize: 12,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentindex,
          onTap: (value) {
            setState(() {
              _currentindex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Iconsax.graph,
                  color: Colors.black,
                ),
                label: "Portfolio",
                activeIcon: Icon(
                  Iconsax.graph,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white),
            BottomNavigationBarItem(
                icon: Icon(
                  Iconsax.scan,
                  color: Colors.black,
                ),
                label: "Scan",
                activeIcon: Icon(
                  Iconsax.scan,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white),
            BottomNavigationBarItem(
                icon: Icon(
                  Iconsax.buy_crypto,
                  color: Colors.black,
                ),
                label: "Market",
                activeIcon: Icon(
                  Iconsax.buy_crypto,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white),
            BottomNavigationBarItem(
                icon: Icon(
                  Iconsax.profile_2user,
                  color: Colors.black,
                ),
                label: "Profile",
                activeIcon: Icon(
                  Iconsax.profile_2user,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white),
          ]),
    );
  }
}
