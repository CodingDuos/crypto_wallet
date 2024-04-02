import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/calculate.dart';
import 'package:wallet/screens/historypage.dart';
import 'package:wallet/screens/market/coinModel.dart';
import 'package:wallet/screens/qrpage.dart';
import 'package:wallet/screens/transfer/sendtokens.dart';
import 'package:wallet/screens/transfer/swaptokens.dart';
import 'package:wallet/splshscreen.dart';

List<String> markettypelist = ["Indian-INR", "Bitcoin- BTC", "TetherUS -USDT"];

List<String> titlelist = ["All", "Gainer", "Loser", "Favourites"];

final walleTRefrence2 = FirebaseDatabase.instance.ref("Users");

class PortfolioPage extends StatefulWidget {
  String balance;
  PortfolioPage({super.key, required this.balance});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List lengthlist = [];
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.75);
  var currentvalue = 0.0;
  int _currentPage = 0;

  List<dynamic> storedocs = [];

  String mybalance = "";

  String uid = "";

  bool isRefreshing = true;

  final walleTRefrence = FirebaseDatabase.instance.ref("Users");

  List? coinMarket = [];

  var coinMarketList;

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      appBar: AppBar(
        backgroundColor: primarycolorGold,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const historypage()))
                    .then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.history)),
          IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QrpageMain()))
                    .then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.qr_code)),
          IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CryptoCalculator()))
                    .then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.calculate))
        ],
        elevation: 0,
        title: const Text("Crypto Wallet"),
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
                                                      storedocs.isEmpty
                                                          ? Text("")
                                                          : Text(
                                                              "\$${double.parse(storedocs[0][position]["Balance"].toString()).toStringAsFixed(2)}",
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .blue,
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SendTokens(
                                          balance: "",
                                        )));
                          },
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2 - 60,
                            color: primarycolorGold,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Iconsax.send_sqaure_2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Send",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SwapTokensPage(
                                          balance: "",
                                        ))).then((value) {
                              setState(() {});
                            });
                          },
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2 - 60,
                            color: primarycolorGold,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Iconsax.send_sqaure_2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Swap",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Row(
                      children: const [
                        Text(
                          "Your Coins",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
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
                            stream: walleTRefrence2
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

                              List<dynamic> storedocss = [];

                              Map map = snapshot.data.snapshot.value as dynamic;

                              storedocss.clear();

                              storedocss
                                  .add(map == null ? [] : map.values.toList());

                              List lis = storedocss[0];
                              lengthlist = storedocss[0];
                              isheight = true;

                              return lengthlist.isEmpty
                                  ? Container(
                                      child: const Center(
                                        child: Text("No Coins"),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: lengthlist.length,
                                      itemBuilder: (context, index) {
                                        List<double> doublelist = [];
                                        lis[index]["price"].forEach((element) {
                                          doublelist.add(
                                              double.parse(element.toString()));
                                        });

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await showdialogofsellcons(
                                                  context,
                                                  storedocs,
                                                  lis[index]["currentprice"]
                                                      .toString(),
                                                  lis[index]["uid"]);

                                              fetchmyuid();
                                              getCoinMarket();
                                            },
                                            child: Container(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff262528),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                height: 200,
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        lis[index]["name"],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      leading: SizedBox(
                                                          height:
                                                              myHeight * 0.05,
                                                          child: Image.network(
                                                              lis[index][
                                                                      "picture"]
                                                                  .toString())),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height: myHeight * 0.05,
                                                        // width: myWidth * 0.2,
                                                        child: Sparkline(
                                                          data: doublelist,
                                                          lineWidth: 3.0,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xff262528),
                                                          lineColor: double.parse(
                                                                      lis[index]
                                                                              [
                                                                              "capmarker"]
                                                                          .toString()) >=
                                                                  0
                                                              ? Colors.green
                                                              : Colors.red,
                                                          fillMode:
                                                              FillMode.none,
                                                          fillGradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              stops: const [
                                                                0.0,
                                                                0.7
                                                              ],
                                                              colors: double.parse(lis[index]
                                                                              [
                                                                              "capmarker"]
                                                                          .toString()) >=
                                                                      0
                                                                  ? [
                                                                      Colors
                                                                          .green,
                                                                      Colors
                                                                          .white
                                                                    ]
                                                                  : [
                                                                      Colors
                                                                          .red,
                                                                      Colors
                                                                          .white
                                                                    ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 20,
                                                                right: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '${double.parse(lis[index]["currentprice"].toString()).toStringAsFixed(2)}\$',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: double.parse(lis[index]["currentprice"]
                                                                              .toString()) >=
                                                                          0
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red),
                                                            ),
                                                            Text(
                                                              double.parse(lis[
                                                                              index]
                                                                          [
                                                                          "coins"]
                                                                      .toString())
                                                                  .toStringAsFixed(
                                                                      6)
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ))
                                                  ],
                                                ),
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

  bool isheight = false;
  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    fetchmybalance();
    setState(() {});
  }

  Future<List<CoinModel>?> getCoinMarket() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';
    if (mounted) {
      setState(() {
        isRefreshing = true;
      });
    }

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    if (mounted) {
      setState(() {
        isRefreshing = false;
      });
    }
    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);
      if (mounted) {
        setState(() {
          coinMarket = coinMarketList;
        });
      }
      fetchmytokens();
    } else {
      print(response.statusCode);
    }
    return null;
  }

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

  fetchmytokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("tokens")
        .once()
        .then((DatabaseEvent databaseEvent) async {
      if (databaseEvent.snapshot.value != null) {
        List<dynamic> storedocs = [];

        Map map = databaseEvent.snapshot.value as dynamic;

        storedocs.clear();

        storedocs.add(map == null ? [] : map.values.toList());
        showmessageofalert(
            context, "${storedocs[0].length} coins in the wallet");
        await updatemyvalues(storedocs[0]);
      } else {
        showmessageofalert(context, "no coin ");
      }
    });
  }

  updatemyvalues(var userdata) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      for (var elements in userdata) {
        var list = coinMarket!
            .where((element) =>
                (element.symbol.toString().toLowerCase().trim() ==
                    elements["shortname"].toString().toLowerCase().trim()))
            .toList();

        await walleTRefrence
            .child(prefs.getString("uid").toString())
            .child("tokens")
            .orderByChild("shortname")
            .startAt(list.first.symbol.toString())
            .endAt(list.first.symbol.toString())
            .once()
            .then((DatabaseEvent databaseEvent) {
          if (databaseEvent.snapshot.value != null) {
            Map map = databaseEvent.snapshot.value as dynamic;
            List<dynamic> storedoxs = [];

            storedoxs.add(
                // ignore: unnecessary_null_comparison
                map == null ? [] : map.values.toList());

            double newv = (double.parse(
                        storedoxs[0].first["currentprice"].toString()) /
                    double.parse(storedoxs[0].first["oldprice"].toString())) *
                double.parse(list.first.currentPrice.toString());
            walleTRefrence
                .child(prefs.getString("uid").toString())
                .child("tokens")
                .child(storedoxs[0].first["uid"].toString())
                .child("currentprice")
                .set(newv);
            walleTRefrence
                .child(prefs.getString("uid").toString())
                .child("tokens")
                .child(storedoxs[0].first["uid"].toString())
                .child("capmarker")
                .set(list.first.marketCapChangePercentage24H);
          } else {
            showmessageofalert(context, "Coins Updation Error");
          }
        });
      }
    } catch (e) {
      showmessageofalert(context, e.toString());
    }
  }
}

showdialogofsellcons(BuildContext context, var list, amoubt, coinid) {
  String walleuid = "";
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure to sell?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select the wallet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 76 * double.parse(list.length.toString()),
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            print(list[0]);

                            print(list[0][index]["uid"].toString());
                            print(list[0][index]["Balance"]);
                            walleuid = list[0][index]["uid"].toString();
                            double newv = double.parse(
                                    list[0][index]["Balance"].toString()) +
                                double.parse(amoubt.toString());
                            await addamounttowallet(
                                list[0][index]["uid"].toString(), newv);
                            await deletecoin(coinid);
                            Navigator.pop(context);
                          },
                          title: Text(
                            list[0][index]["uid"].toString(),
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        );
      });
}

addamounttowallet(walletuid, newvalue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("wallets")
      .child(walletuid.toString())
      .child("Balance")
      .set(newvalue.toString());
}

deletecoin(coundid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("tokens")
      .child(coundid.toString())
      .remove();
}
