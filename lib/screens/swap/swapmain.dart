import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/market/coinModel.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/screens/market/market.dart';

import 'package:wallet/splshscreen.dart';

class SwapMainPage extends StatefulWidget {
  SwapMainPage(
      {super.key,
      required this.oldprice,
      required this.title,
      required this.amount,
      required this.image,
      required this.marketcap,
      required this.name,
      required this.idcoin,
      required this.price,
      required this.pricechange,
      required this.symbol});

  String oldprice;
  String title;
  String amount;
  String symbol;
  String idcoin;
  String image;
  String name;
  String marketcap;
  List price;
  String pricechange;

  @override
  State<SwapMainPage> createState() => _SwapMainPageState();
}

class _SwapMainPageState extends State<SwapMainPage> {
  @override
  void initState() {
    fetchmyuid();
    getCoinMarket();
    super.initState();
  }

  TextEditingController amountcontroller = TextEditingController();

  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uidpanerl = prefs.getString("uid").toString();

    if (mounted) {
      setState(() {});
    }
  }

  double newvalue = 0;
  String uidpanerl = "";

  int indexnumber = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      body: coinMarket.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Text(
                          "Currency Swap",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      color: const Color(0xff262528),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Text("From",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: const Color(0xff181818),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                NetworkImage(widget.image),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(widget.symbol,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Text(
                                              "\$${double.parse(widget.amount.toString()).toStringAsFixed(5).toString()}",
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 20))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Icon(
                            Icons.currency_exchange,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Text("To",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Coins"),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: 400,
                                                  child: ListView.builder(
                                                      itemBuilder:
                                                          (context, index) {
                                                    return Card(
                                                      child: ListTile(
                                                        onTap: () {
                                                          setState(() {
                                                            amountcontroller
                                                                .clear();
                                                            newvalue = 0;
                                                            indexnumber = index;
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        leading: CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  coinMarket[
                                                                          index]
                                                                      .image
                                                                      .toString()),
                                                        ),
                                                        title: Text(
                                                            coinMarket[index]
                                                                .name),
                                                      ),
                                                    );
                                                  }))
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                color: const Color(0xff181818),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                  coinMarket[indexnumber]
                                                      .image
                                                      .toString()),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                coinMarket[indexnumber]
                                                    .symbol
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Text(
                                                "\$${coinMarket[indexnumber].currentPrice.toString()}",
                                                style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 20))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: amountcontroller,
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (v) {
                                      setState(() {
                                        if (amountcontroller.text.isEmpty) {
                                          newvalue = 0;
                                        } else {
                                          newvalue = double.parse(
                                                  amountcontroller.text) /
                                              coinMarket[indexnumber]
                                                  .currentPrice;
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        labelText: "Enter the amount"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // Only numbers can be entered
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                "= $newvalue ${coinMarket[indexnumber].symbol}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: MaterialButton(
                      onPressed: () async {
                        if (amountcontroller.text.isEmpty) {
                          showmessageofalert(context, "enter the amount");
                        } else {
                          if (double.parse(widget.amount.toString()) >
                              double.parse(amountcontroller.text.toString())) {
                            await walleTRefrence
                                .child(uidpanerl)
                                .child("tokens")
                                .orderByChild("shortname")
                                .equalTo(
                                    coinMarket[indexnumber].symbol.toString())
                                .once()
                                .then((DatabaseEvent databaseEvent) async {
                              if (databaseEvent.snapshot.value == null) {
                                await purchasemarket(
                                    coinMarket[indexnumber]
                                        .currentPrice
                                        .toString(),
                                    coinMarket[indexnumber].symbol.toString(),
                                    newvalue,
                                    coinMarket[indexnumber].image.toString(),
                                    coinMarket[indexnumber].name.toString(),
                                    coinMarket[indexnumber]
                                        .marketCapChangePercentage24H
                                        .toString(),
                                    coinMarket[indexnumber].sparklineIn7D.price,
                                    amountcontroller.text,
                                    coinMarket[indexnumber]
                                        .priceChange24H
                                        .toString());
                                // await updatebalance();
                                updatecoins(
                                    widget.symbol,
                                    double.parse(amountcontroller.text),
                                    widget.idcoin);
                                savenotification(
                                    "${widget.symbol} Swapped with ${coinMarket[indexnumber].symbol}");

                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                databaseEvent.snapshot
                                    .child("coins")
                                    .toString();
                                Map map =
                                    databaseEvent.snapshot.value as dynamic;
                                double coinsquantity = double.parse(
                                    map.values.first["coins"].toString());
                                double coins = coinsquantity + newvalue;
                                await walleTRefrence
                                    .child(uidpanerl)
                                    .child("tokens")
                                    .child(map.values.first["uid"].toString())
                                    .child("coins")
                                    .set(coins.toString());
                                var price = double.parse(
                                        amountcontroller.text.toString()) *
                                    coins;
                                await walleTRefrence
                                    .child(uidpanerl)
                                    .child("tokens")
                                    .child(map.values.first["uid"].toString())
                                    .child("currentprice")
                                    .set(price.toString());
                                updatecoins(
                                    widget.symbol,
                                    double.parse(
                                        amountcontroller.text.toString()),
                                    widget.idcoin);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            });
                          } else {
                            showmessageofalert(context, "No Equal Coins");
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20)),
                        height: 48,
                        child: const Center(
                          child: Text(
                            "Convert",
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

  bool isRefreshing = true;

  List<CoinModel> coinMarket = [];
  List? filtercoinMarket = [];
  var coinMarketList;
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
          filtercoinMarket = coinMarket;
        });
      }
    } else {
      print(response.statusCode);
    }
    return null;
  }

  updatecoins(String symbol, double swapamount, coinid) async {
    await walleTRefrence
        .child(uidpanerl)
        .child("tokens")
        .orderByChild("shortname")
        .startAt(symbol)
        .endAt(symbol)
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        Map map = databaseEvent.snapshot.value as dynamic;
        double newamountofcoin =
            double.parse(map.entries.first.value["currentprice"].toString()) -
                swapamount;
        walleTRefrence
            .child(uidpanerl)
            .child("tokens")
            .child(coinid)
            .child("currentprice")
            .set(newamountofcoin);
      }
    });
  }
}
