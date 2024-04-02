import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/faauthentication.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/transfer/sendtokens.dart';
import 'package:wallet/splshscreen.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage(
      {super.key,
      required this.oldprice,
      required this.coinuid,
      required this.coins,
      required this.search,
      required this.title,
      required this.amount,
      required this.image,
      required this.marketcap,
      required this.name,
      required this.price,
      required this.pricechange,
      required this.symbol});

  String oldprice;
  String coinuid;
  String search;
  String coins;
  String title;
  String amount;
  String symbol;
  String image;
  String name;
  String marketcap;
  List price;
  String pricechange;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController amountcontroller = TextEditingController();
  @override
  void initState() {
    ca();
    fetchhistory();
    // TODO: implement initState
    super.initState();
  }

  ca() {
    if (widget.search.isNotEmpty) {
      _controller.text = widget.search;
      setState(() {});
    }
  }

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      appBar: AppBar(
        backgroundColor: primarycolorGold,
        elevation: 0,
        title: Text("Send ${widget.title} "),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 10,
          child: Container(
            color: const Color(0xff1F1E20),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Text(
                          "Receipient Address",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          hintText: "Receipient Address"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Text(
                          "Amount",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: amountcontroller,
                      onChanged: (v) {},
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          hintText: "Enter the coins"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Total: \$${widget.amount}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  errormessage.isEmpty
                      ? Container()
                      : Text(
                          errormessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            errormessage = "";
                          });

                          if (double.parse(widget.amount) >
                                  double.parse(amountcontroller.text) &&
                              amountcontroller.text.isNotEmpty) {
                            double newxoins =
                                double.parse(amountcontroller.text) /
                                    double.parse(widget.amount);

                            walleTRefrence
                                .child(_controller.text)
                                .once()
                                .then((DatabaseEvent databaseEventuser) async {
                              if (databaseEventuser.snapshot.value == null) {
                                setState(() {
                                  errormessage = "No Wallet Found";
                                });
                              } else {
                                await walleTRefrence
                                    .child(_controller.text)
                                    .child("tokens")
                                    .orderByChild("shortname")
                                    .equalTo(widget.symbol)
                                    .once()
                                    .then((DatabaseEvent databaseEvent) async {
                                  if (databaseEvent.snapshot.value == null) {
                                    await purchasemarkettransfer(
                                        widget.oldprice,
                                        _controller.text,
                                        widget.symbol,
                                        newxoins,
                                        widget.image,
                                        widget.name,
                                        widget.marketcap,
                                        widget.price,
                                        amountcontroller.text,
                                        widget.pricechange);
                                    await updatemybalance(widget.coinuid,
                                        double.parse(amountcontroller.text));
                                    historydat(_controller.text, widget.symbol,
                                        amountcontroller.text);
                                    savenotification(
                                        "${amountcontroller.text} of ${widget.symbol} tranfered to ${_controller.text}");
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    // await updatebalance(users.currentPrice);
                                  } else {
                                    Map map =
                                        databaseEvent.snapshot.value as dynamic;
                                    double coinsquantity = double.parse(
                                        map.values.first["coins"].toString());
                                    double coins = coinsquantity + newxoins;
                                    await walleTRefrence
                                        .child(_controller.text)
                                        .child("tokens")
                                        .child(
                                            map.values.first["uid"].toString())
                                        .child("coins")
                                        .set(coins.toString());
                                    var price =
                                        double.parse(amountcontroller.text) *
                                            coins;
                                    await walleTRefrence
                                        .child(_controller.text)
                                        .child("tokens")
                                        .child(
                                            map.values.first["uid"].toString())
                                        .child("currentprice")
                                        .set(price.toString());
                                    await updatemybalance(widget.coinuid,
                                        double.parse(amountcontroller.text));
                                    historydat(_controller.text, widget.symbol,
                                        amountcontroller.text);
                                    savenotification(
                                        "${amountcontroller.text} of ${widget.symbol} tranfered to ${_controller.text}");
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    // await updatebalance(users.currentPrice);
                                    // await fetchmyuid();
                                  }
                                });
                              }
                            });
                          } else {
                            setState(() {
                              errormessage = "error , try again";
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: primarycolorGold,
                              borderRadius: BorderRadius.circular(12)),
                          height: 50,
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Text(
                          "Recent Transactions ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  storedocs.isEmpty
                      ? Container(
                          child: const Center(
                            child: Text(
                              "No Recent Transactions",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 250,
                          child: ListView.builder(
                              itemCount: storedocs[0].length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        " ${storedocs[0][index]["Coin"]}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "\$${double.parse(storedocs[0][index]["amount"].toString()).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      )
                                    ],
                                  ),
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.send),
                                  ),
                                  title: Text(
                                    storedocs[0][index]["receiver"],
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    storedocs[0][index]["time"],
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List storedocs = [];

  fetchhistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("history")
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        Map map = databaseEvent.snapshot.value as dynamic;
        storedocs.add(map.values.toList());

        setState(() {});
      }
    });
  }
}

historydat(customerid, coin, coinamount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = const Uuid().v1().toString();
  Map mapofhistory = {
    "uid": uid,
    "time": DateTime.now().toString(),
    "receiver": customerid.toString(),
    "sender": prefs.getString("uid").toString(),
    "Coin": coin.toString(),
    "amount": coinamount.toString(),
  };
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("history")
      .child(uid)
      .set(mapofhistory);
}

updatemybalance(String coinuid, double minusamount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("tokens")
      .child(coinuid)
      .child("currentprice")
      .once()
      .then((DatabaseEvent databaseEvent) async {
    if (databaseEvent.snapshot.value != null) {
      double price = double.parse(databaseEvent.snapshot.value.toString());
      print(price);
      double newprice = price - minusamount;
      await walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("tokens")
          .child(coinuid)
          .child("currentprice")
          .set(newprice.toString());
    }
  });
}
