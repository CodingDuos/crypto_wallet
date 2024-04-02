import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/market/coinModel.dart';
import 'package:wallet/screens/market/item.dart';
import 'package:wallet/splshscreen.dart';

bool isloading = false;

List<String> markettypelist = ["Bitcoin- BTC", "TetherUS -USDT"];

List<String> titlelist = ["All", "Top Gainer", "Top Loser", "Favourites"];
purchasemarket(oldprice, shortname, coins, Pic, name,
    marketCapChangePercentage24H, price, currentprice, pricechange) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String uidofkeys = const Uuid().v4().toString();
  Map keysmap = {
    "oldprice": oldprice,
    "shortname": shortname,
    "uid": uidofkeys,
    "coins": coins,
    "picture": Pic,
    "name": name,
    "price": price,
    "capmarker": marketCapChangePercentage24H,
    "currentprice": currentprice,
    "pricevhange": pricechange,
  };
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("tokens")
      .child(uidofkeys)
      .set(keysmap);
}

updatebalance(double price, String uid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  walleTRefrence
      .child(prefs.getString("uid").toString())
      .child("wallets")
      .child(uid)
      .child("Balance")
      .once()
      .then((DatabaseEvent databaseEvent) {
    if (databaseEvent.snapshot.value != null) {
      double newbalance = double.parse(databaseEvent.snapshot.value.toString());
      double addnewbalnce = newbalance - price;
      walleTRefrence
          .child(prefs.getString("uid").toString())
          .child("wallets")
          .child(uid)
          .child("Balance")
          .set(addnewbalnce.toStringAsFixed(2));
    }
  });
}

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int currentindex = 0;
  int currentindexbottom = 0;
  double newvalue = 0;
  List? listofdata = [];
  bool nodata = false;
  final TextEditingController _searchcontroller = TextEditingController();
  TextEditingController amountcontroller = TextEditingController();

  List fetchFavourites = [];

  String marketname = "USDT";

  String walletuid = "";
  List<dynamic> storedocs = [];
  List<bool> boollist = [];

  String mybalance = "";

  List? fianallist = [];

  String uid = "";

  String errormessagr = "Insufficient Balance, Add funds Now";
  bool isRefreshing = true;

  List? coinMarket = [];

  List? filtercoinMarket = [];

  var coinMarketList;

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        "Crypto Market",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: const [
                  Text(
                    "Of the past 24 hours",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff6C757D)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
              child: TextField(
                controller: _searchcontroller,
                onChanged: (val) {
                  setState(() {
                    nodata = false;
                    filtercoinMarket = fianallist;
                    currentindex = 0;
                    filtercoinMarket = fianallist!
                        .where((element) => (element.name
                            .toString()
                            .toLowerCase()
                            .trim()
                            .contains(_searchcontroller.text
                                .toString()
                                .toLowerCase()
                                .trim())))
                        .toList();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    hintText: "Search Coin",
                    hintStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 40, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Coins",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Row(
                                  children: const [
                                    Text(
                                      "Market",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff212529)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                    itemCount: markettypelist.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              currentindexbottom = index;
                                            },
                                            trailing: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  currentindexbottom == index
                                                      ? Colors.blue
                                                      : Colors.grey,
                                            ),
                                            dense: true,
                                            title: Text(markettypelist[index]),
                                          ),
                                          index == 2
                                              ? Container()
                                              : const Divider(
                                                  color: Colors.black,
                                                )
                                        ],
                                      );
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: MaterialButton(
                                  onPressed: () {
                                    marketname =
                                        markettypelist[currentindexbottom];
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 48,
                                    color: Colors.blue,
                                    child: const Center(
                                      child: Text(
                                        "Update Market",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ).then((value) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300] as Color)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Text(
                              marketname,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 22,
              child: ListView.builder(
                  itemCount: titlelist.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: GestureDetector(
                        onTap: () {
                          currentindex = index;
                          if (index == 1) {
                            print(fianallist!.length);
                            nodata = false;
                            filtercoinMarket = coinMarket!
                                .where((element) =>
                                    (element.marketCapChangePercentage24H >= 0))
                                .toList();

                            filtercoinMarket!.sort((a, b) => b
                                .marketCapChangePercentage24H
                                .compareTo(a.marketCapChangePercentage24H));

                            print(fianallist!.length);
                            print(filtercoinMarket!.length);
                          } else if (index == 2) {
                            nodata = false;
                            filtercoinMarket = coinMarket!
                                .where((element) =>
                                    (element.marketCapChangePercentage24H <= 0))
                                .toList();
                            filtercoinMarket!.sort((a, b) => a
                                .marketCapChangePercentage24H
                                .compareTo(b.marketCapChangePercentage24H));

                            print(fianallist!.length);
                            print(filtercoinMarket!.length);
                          } else if (index == 3) {
                            nodata = false;
                            filtercoinMarket = coinMarket!
                                .where((element) => element == element)
                                .toList();

                            for (var element in coinMarket!) {
                              if (fetchFavourites.contains(element.symbol)) {
                                print(fetchFavourites.contains(element.symbol));
                              } else {
                                filtercoinMarket!.remove(element);
                              }
                            }
                            if (filtercoinMarket!.isEmpty) {
                              setState(() {
                                nodata = true;
                              });
                            }
                          } else {
                            nodata = false;
                            filtercoinMarket = coinMarket;
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: AnimatedContainer(
                          height: 22,
                          width: MediaQuery.of(context).size.width / 5,
                          duration: const Duration(seconds: 1),
                          child: Column(
                            children: [
                              Text(
                                titlelist[index],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Visibility(
                                  visible: currentindex == index ? true : false,
                                  child: AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    color: Colors.amber,
                                    height: 5,
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            coinMarket!.isEmpty
                ? const Center(
                    child: LinearProgressIndicator(
                    backgroundColor: Colors.amber,
                    color: Colors.amber,
                  ))
                : filtercoinMarket!.isEmpty
                    ? Container(
                        child: const Center(
                          child: Text(
                            "NO Search Word",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : nodata == true
                        ? const Center(
                            child: Text(
                              "No Favourite Coin",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : SizedBox(
                            height: 75 *
                                double.parse(
                                    filtercoinMarket!.length.toString()),
                            child: coinMarket == null || coinMarket!.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(myHeight * 0.06),
                                    child: const Center(
                                      child: Text(
                                        'Attention this Api is free, so you cannot send multiple requests per second, please wait and try again later.',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: filtercoinMarket!.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      CoinModel users =
                                          filtercoinMarket![index];
                                      return GestureDetector(
                                        onTap: () {
                                          errormessagr = "";
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                  builder: (context, setstate) {
                                                return Wrap(
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "Select Wallet",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 22),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 75 *
                                                          double.parse(
                                                              storedocs[0]
                                                                  .length
                                                                  .toString()),
                                                      child: ListView.builder(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          itemCount:
                                                              storedocs[0]
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Card(
                                                              child: ListTile(
                                                                onTap: () {
                                                                  setstate(() {
                                                                    boollist = List<
                                                                            bool>.filled(
                                                                        boollist
                                                                            .length,
                                                                        false);
                                                                    boollist[
                                                                            index] =
                                                                        !boollist[
                                                                            index];
                                                                    mybalance = storedocs[0][index]
                                                                            [
                                                                            "Balance"]
                                                                        .toString();
                                                                    walletuid = storedocs[0]
                                                                            [
                                                                            index]
                                                                        ["uid"];
                                                                  });
                                                                },
                                                                trailing: Text(
                                                                  "\$${double.parse(storedocs[0][index]["Balance"].toString()).toStringAsFixed(2)}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          8),
                                                                ),
                                                                title: Text(
                                                                  storedocs[0][
                                                                              index]
                                                                          [
                                                                          "uid"]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          8),
                                                                ),
                                                                leading:
                                                                    Checkbox(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  onChanged: (bool?
                                                                      value) {},
                                                                  value:
                                                                      boollist[
                                                                          index],
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                    const SizedBox(
                                                      height: 30,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: TextField(
                                                              controller:
                                                                  amountcontroller,
                                                              onChanged: (v) {
                                                                setstate(() {
                                                                  if (amountcontroller
                                                                      .text
                                                                      .isEmpty) {
                                                                    newvalue =
                                                                        0;
                                                                  } else {
                                                                    newvalue = double.parse(amountcontroller
                                                                            .text) /
                                                                        users
                                                                            .currentPrice;
                                                                  }
                                                                });
                                                              },
                                                              decoration: const InputDecoration(
                                                                  enabledBorder:
                                                                      OutlineInputBorder(),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(),
                                                                  labelText:
                                                                      "Enter the amount"),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ], // Only numbers can be entered
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Text(
                                                          "= $newvalue ${users.symbol}",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 8),
                                                        ))
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: 100,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    Image.network(
                                                                        users
                                                                            .image),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      users.id
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  String favid =
                                                                      const Uuid()
                                                                          .v1()
                                                                          .toString();
                                                                  Map datamap =
                                                                      {
                                                                    "uid":
                                                                        favid,
                                                                    "name": users
                                                                        .symbol
                                                                        .toString(),
                                                                  };
                                                                  SharedPreferences
                                                                      prefs =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  String uid = prefs
                                                                      .getString(
                                                                          "uid")
                                                                      .toString();

                                                                  walleTRefrence
                                                                      .child(
                                                                          uid)
                                                                      .child(
                                                                          "favourites")
                                                                      .child(
                                                                          favid)
                                                                      .set(
                                                                          datamap);
                                                                  fetchfavouritelist();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: const [
                                                                      Icon(Icons
                                                                          .add_circle),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "Add Favourite",
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                    const Divider(
                                                      thickness: 1,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 30,
                                                        ),
                                                        Text(
                                                          "\$${users.currentPrice.toString()}",
                                                          style: const TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Icon(
                                                          users.marketCapChangePercentage24H >=
                                                                  0
                                                              ? Icons
                                                                  .arrow_drop_up
                                                              : Icons
                                                                  .arrow_drop_down,
                                                          color:
                                                              users.marketCapChangePercentage24H >=
                                                                      0
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                        ),
                                                        Text(
                                                          '${users.marketCapChangePercentage24H.toStringAsFixed(2)}%',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  users.marketCapChangePercentage24H >=
                                                                          0
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10),
                                                      child: MaterialButton(
                                                        onPressed: () async {
                                                          setstate(() {
                                                            isloading = true;
                                                          });

                                                          List checkwallet = boollist
                                                              .where(
                                                                  (element) =>
                                                                      element ==
                                                                      true)
                                                              .toList();
                                                          if (checkwallet
                                                              .isNotEmpty) {
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();

                                                            if (double.parse(
                                                                    mybalance) >
                                                                double.parse(
                                                                    amountcontroller
                                                                        .text
                                                                        .toString())) {
                                                              await walleTRefrence
                                                                  .child(prefs
                                                                      .getString(
                                                                          "uid")
                                                                      .toString())
                                                                  .child(
                                                                      "tokens")
                                                                  .orderByChild(
                                                                      "shortname")
                                                                  .equalTo(users
                                                                      .symbol
                                                                      .toString())
                                                                  .once()
                                                                  .then((DatabaseEvent
                                                                      databaseEvent) async {
                                                                if (databaseEvent
                                                                        .snapshot
                                                                        .value ==
                                                                    null) {
                                                                  await purchasemarket(
                                                                      users
                                                                          .currentPrice
                                                                          .toString(),
                                                                      users
                                                                          .symbol
                                                                          .toString(),
                                                                      newvalue
                                                                          .toString(),
                                                                      users
                                                                          .image
                                                                          .toString(),
                                                                      users.name
                                                                          .toString(),
                                                                      users
                                                                          .marketCapChangePercentage24H
                                                                          .toString(),
                                                                      users
                                                                          .sparklineIn7D
                                                                          .price,
                                                                      amountcontroller
                                                                          .text
                                                                          .toString(),
                                                                      users
                                                                          .priceChange24H
                                                                          .toString());
                                                                  await updatebalance(
                                                                      double.parse(amountcontroller
                                                                          .text
                                                                          .toString()),
                                                                      walletuid);
                                                                  await fetchmyuid();
                                                                  await savenotification(
                                                                      "Purchased ${amountcontroller.text} of ${users.symbol}");
                                                                  showmessageofalert(
                                                                      context,
                                                                      "Successfully Purchased ${users.symbol}");
                                                                } else {
                                                                  databaseEvent
                                                                      .snapshot
                                                                      .child(
                                                                          "coins")
                                                                      .toString();
                                                                  Map map = databaseEvent
                                                                          .snapshot
                                                                          .value
                                                                      as dynamic;
                                                                  double
                                                                      coinsquantity =
                                                                      double.parse(map
                                                                          .values
                                                                          .first[
                                                                              "coins"]
                                                                          .toString());
                                                                  double coins =
                                                                      coinsquantity +
                                                                          newvalue;
                                                                  await walleTRefrence
                                                                      .child(prefs
                                                                          .getString(
                                                                              "uid")
                                                                          .toString())
                                                                      .child(
                                                                          "tokens")
                                                                      .child(map
                                                                          .values
                                                                          .first[
                                                                              "uid"]
                                                                          .toString())
                                                                      .child(
                                                                          "coins")
                                                                      .set(coins
                                                                          .toString());
                                                                  var price =
                                                                      double.parse(amountcontroller
                                                                              .text
                                                                              .toString()) *
                                                                          coins;
                                                                  await walleTRefrence
                                                                      .child(prefs
                                                                          .getString(
                                                                              "uid")
                                                                          .toString())
                                                                      .child(
                                                                          "tokens")
                                                                      .child(map
                                                                          .values
                                                                          .first[
                                                                              "uid"]
                                                                          .toString())
                                                                      .child(
                                                                          "currentprice")
                                                                      .set(price
                                                                          .toString());
                                                                  await updatebalance(
                                                                      double.parse(amountcontroller
                                                                          .text
                                                                          .toString()),
                                                                      walletuid);
                                                                  await fetchmyuid();
                                                                  await savenotification(
                                                                      "Purchased ${amountcontroller.text} of ${users.symbol}");
                                                                }
                                                              });
                                                              fetchmybalance();
                                                              await fetchmyuid();
                                                            } else {
                                                              errormessagr =
                                                                  "Insufficient Balance, Add funds Now";
                                                              // ignore: use_build_context_synchronously
                                                            }
                                                          } else {
                                                            errormessagr =
                                                                "Select Wallet First";
                                                          }

                                                          setstate(() {
                                                            isloading = false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          height: 48,
                                                          child: isloading ==
                                                                  true
                                                              ? const Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                ))
                                                              : const Center(
                                                                  child: Text(
                                                                    "BUY",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              });
                                            },
                                          ).then((value) {
                                            if (errormessagr ==
                                                    "Insufficient Balance, Add funds Now" ||
                                                errormessagr ==
                                                    "Select Wallet First") {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "ok"))
                                                      ],
                                                      title:
                                                          const Text("Error"),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                    errormessagr),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          });

                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) {
                                          //       return AlertDialog(
                                          //         actions: [
                                          //           TextButton(
                                          //               onPressed: () async {
                                          //
                                          //               child: Text("Ok"))
                                          //         ],
                                          //         title: const Text("Confirmation"),
                                          //         content: Column(
                                          //           mainAxisSize: MainAxisSize.min,
                                          //           children: const [
                                          //             Text(
                                          //                 "Are you Sure to Buy the coin?")
                                          //           ],
                                          //         ),
                                          //       );
                                          //     });
                                        },
                                        child: Item(
                                          func: (value) {},
                                          valuebook: false,
                                          item: users,
                                        ),
                                      );
                                    },
                                  ),
                          ),
          ],
        ),
      ),
    );
  }

  fetchfavouritelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    walleTRefrence
        .child(prefs.getString("uid").toString())
        .child("favourites")
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        Map map = databaseEvent.snapshot.value as dynamic;

        List<dynamic> storedocss = [];
        storedocss.add(map == null ? [] : map.values.toList());

        fetchFavourites.clear();
        storedocss[0].forEach((element) {
          print(element["name"]);
          fetchFavourites.add(element["name"].toString());
        });
      }
    });
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
        boollist =
            List.generate(storedocs[0].length, (index) => false).toList();

        setState(() {});
      }
    });
  }

  fetchmyuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid").toString();
    fetchmybalance();
    if (mounted) {
      setState(() {});
    }
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
          filtercoinMarket = coinMarket;
        });
      }
    } else {
      print(response.statusCode);
    }
    return null;
  }

  @override
  void initState() {
    fetchfavouritelist();
    fetchmyuid();
    getCoinMarket();
    super.initState();
  }
}
