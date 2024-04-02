import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/market/coinModel.dart';
import 'package:wallet/screens/transfer/paymentpage.dart';
import 'package:wallet/splshscreen.dart';

class SendTokens extends StatefulWidget {
  SendTokens({super.key, required this.balance});
  String balance;

  @override
  State<SendTokens> createState() => _SendTokensState();
}

class _SendTokensState extends State<SendTokens> {
  List lengthlist = [];
  @override
  void initState() {
    fetchmyuid();
    getCoinMarket();
    _pageController.addListener(() {
      setState(() {
        currentvalue = _pageController.page!.toDouble();

        _currentPage = currentvalue.floor();
      });
    });
    super.initState();
  }

  List<dynamic> storedocs = [];
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.75);
  var currentvalue = 0.0;
  int _currentPage = 0;

  fetchmybalance() async {
    await walleTRefrence
        .child(uid)
        .child("wallets")
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        Map map = databaseEvent.snapshot.value as dynamic;
        storedocs.clear();
        storedocs.add(map == null ? [] : map.values.toList());
        setState(() {});
      }
    });
  }

  String mybalance = "";

  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    fetchmybalance();
    setState(() {});
  }

  String uid = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      appBar: AppBar(
        backgroundColor: primarycolorGold,
        elevation: 0,
        title: const Text("Select Asset to send"),
      ),
      body: storedocs.isEmpty
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(0)),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: primarycolorGold,
                              borderRadius: BorderRadius.circular(0)),
                          height: 200,
                          width: 500,
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                bottom: 0,
                                left: -120,
                                child: Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.20)),
                                ),
                              ),
                              Positioned(
                                top: -130,
                                left: 50,
                                right: 50,
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 25, bottom: 40),
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: storedocs[0].length,
                                      itemBuilder: (context, position) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: position == 0 ? 0 : 10),
                                          child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              height: 120,
                                              width: 256,
                                              decoration: BoxDecoration(
                                                  color: _currentPage ==
                                                          position
                                                      ? Colors.white
                                                      : const Color(0xffFFD0A3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Column(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: const [
                                                      Text(
                                                        "Available Balance",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 15),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "\$${double.parse(storedocs[0][position]["Balance"].toString()).toStringAsFixed(2)}",
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 0,
                                                          top: 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        storedocs[0][position]
                                                                ["uid"]
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff6A6666),
                                                            fontSize: 7,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      IconButton(
                                                          onPressed: () async {
                                                            await Clipboard.setData(ClipboardData(
                                                                text: storedocs[0]
                                                                            [
                                                                            position]
                                                                        ["uid"]
                                                                    .toString()));
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy))
                                                    ],
                                                  ),
                                                )
                                              ])),
                                        );
                                      }),
                                ),
                              ),
                              Positioned(
                                  bottom: 5,
                                  left: 50,
                                  right: 50,
                                  child: DotsIndicator(
                                    dotsCount: storedocs[0].length,
                                    decorator: DotsDecorator(
                                      color: const Color(0xffB7DCE9),
                                      activeColor: Colors.white,
                                      activeSize: const Size(50.0, 9.0),
                                      activeShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                    position:
                                        double.parse(_currentPage.toString()),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Your Assets",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isheight == false
                        ? 2000
                        : 300 * double.parse(lengthlist.length.toString()),
                    child: uid.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffFBC700),
                            ),
                          )
                        : StreamBuilder(
                            stream: walleTRefrence
                                .child(uid)
                                .child("tokens")
                                .onValue,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasError) {}
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  children: const [
                                    LinearProgressIndicator(),
                                  ],
                                );
                              }

                              List<dynamic> storedocs = [];

                              Map map = snapshot.data.snapshot.value as dynamic;

                              storedocs.clear();

                              storedocs
                                  .add(map == null ? [] : map.values.toList());

                              List lis = storedocs[0];
                              lengthlist = storedocs[0];
                              bool isheight = false;

                              return ListView.builder(
                                  padding: const EdgeInsets.all(0),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: lengthlist.length,
                                  itemBuilder: (context, index) {
                                    List<double> doublelist = [];
                                    lis[index]["price"].forEach((element) {
                                      doublelist.add(
                                          double.parse(element.toString()));
                                    });

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: Card(
                                        child: ListTile(
                                          tileColor: const Color(0xff262528),
                                          onTap: () async {
                                            if (coinMarket!.isNotEmpty) {
                                              var list = coinMarket!
                                                  .where((element) => (element
                                                          .symbol
                                                          .toString()
                                                          .toLowerCase()
                                                          .trim() ==
                                                      lis[index]["shortname"]
                                                          .toString()
                                                          .toLowerCase()
                                                          .trim()))
                                                  .toList();
                                              print(list);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PaymentPage(
                                                            oldprice: list.first
                                                                .currentPrice
                                                                .toString(),
                                                            coinuid: lis[index]
                                                                    ["uid"]
                                                                .toString(),
                                                            coins: lis[index]
                                                                    ["coins"]
                                                                .toString(),
                                                            search:
                                                                widget.balance,
                                                            symbol: lis[index][
                                                                    "shortname"]
                                                                .toString(),
                                                            pricechange: lis[
                                                                        index][
                                                                    "pricevhange"]
                                                                .toString(),
                                                            name: lis[index]
                                                                    ["name"]
                                                                .toString(),
                                                            marketcap: lis[
                                                                        index][
                                                                    "capmarker"]
                                                                .toString(),
                                                            price: lis[index]
                                                                ["price"],
                                                            image: lis[index]
                                                                    ["picture"]
                                                                .toString(),
                                                            amount: lis[index][
                                                                    "currentprice"]
                                                                .toString(),
                                                            title: lis[index]
                                                                    ["name"]
                                                                .toString(),
                                                          )));
                                            }
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                lis[index]["picture"]
                                                    .toString()),
                                          ),
                                          subtitle: Text(
                                            "${lis[index]["coins"]}${lis[index]["shortname"]}",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '\$${double.parse(lis[index]["currentprice"].toString()).toStringAsFixed(3).toString()}',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '\$${double.parse(lis[index]["capmarker"].toString())}',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                            lis[index]["name"],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  bool isRefreshing = true;
  bool isheight = false;
  final walleTRefrence = FirebaseDatabase.instance.ref("Users");

  List? coinMarket = [];
  var coinMarketList;
  Future<List<CoinModel>?> getCoinMarket() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

    setState(() {
      isRefreshing = true;
    });
    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    setState(() {
      isRefreshing = false;
    });
    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);
      setState(() {
        coinMarket = coinMarketList;
      });
    } else {
      print(response.statusCode);
    }
    return null;
  }
}

List<String> titlelist = ["All", "Gainer", "Loser", "Favourites"];
List<String> markettypelist = ["Indian-INR", "Bitcoin- BTC", "TetherUS -USDT"];

purchasemarkettransfer(oldprice, id, shortname, coins, pic, name,
    marketCapChangePercentage24H, price, currentprice, pricechange) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String uidofkeys = const Uuid().v4().toString();
  Map keysmap = {
    "oldprice": oldprice,
    "shortname": shortname,
    "uid": uidofkeys,
    "coins": coins,
    "picture": pic,
    "name": name,
    "price": price,
    "capmarker": marketCapChangePercentage24H,
    "currentprice": currentprice,
    "pricevhange": pricechange,
  };
  walleTRefrence.child(id).child("tokens").child(uidofkeys).set(keysmap);
}
