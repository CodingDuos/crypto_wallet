import 'package:flutter/material.dart';
import 'package:wallet/main.dart';
import 'package:wallet/screens/market/coinModel.dart';
import 'package:http/http.dart' as http;

class CryptoCalculator extends StatefulWidget {
  const CryptoCalculator({Key? key}) : super(key: key);

  @override
  _CryptoCalculatorState createState() => _CryptoCalculatorState();
}

class _CryptoCalculatorState extends State<CryptoCalculator> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  bool isRefreshing = true;
  double newvalue = 0;
  String uidpanerl = "";

  int indexnumber = 0;

  List? coinMarket = [];

  List? filtercoinMarket = [];

  final String _cryptoCurrency = 'BTC';
  final String _fiatCurrency = 'USD';
  double _cryptoAmount = 0.0;
  double _fiatAmount = 0.0;
  var coinMarketList;

  final Map<String, double> _exchangeRates = {
    'BTC': 50000.0,
    'ETH': 3000.0,
    'DOGE': 0.50,
    'ADA': 2.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1E20),
      appBar: AppBar(
        backgroundColor: primarycolorGold,
        title: const Text('Crypto Calculator'),
      ),
      body: coinMarket!.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crypto Currency',
                      style: TextStyle(color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Coins"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height: 400,
                                            child: ListView.builder(
                                                itemBuilder: (context, index) {
                                              return Card(
                                                child: ListTile(
                                                  onTap: () {
                                                    setState(() {
                                                      _fiatAmount = 0;
                                                      controller.clear();
                                                      newvalue = 0;
                                                      indexnumber = index;
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  leading: CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            coinMarket![index]
                                                                .image
                                                                .toString()),
                                                  ),
                                                  title: Text(
                                                      coinMarket![index].name),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            coinMarket![indexnumber]
                                                .image
                                                .toString()),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                          coinMarket![indexnumber]
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
                                          "\$${coinMarket![indexnumber].currentPrice.toString()}",
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
                    const SizedBox(height: 16.0),
                    const Text(
                      'Fiat Currency',
                      style: TextStyle(color: Colors.white),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            hintText: "USD \$"),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            hintText: "Enter Crypto Amount"),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      '$_fiatAmount $_fiatCurrency',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                            onPressed: () {
                              setState(() {
                                _cryptoAmount =
                                    double.parse(controller.text.toString());
                                _fiatAmount = _cryptoAmount *
                                    coinMarket![indexnumber].currentPrice;
                              });
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                              }
                            },
                            child: Container(
                              color: primarycolorGold,
                              height: 40,
                              width: 200,
                              child: const Center(
                                child: Text(
                                  'Calculate',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
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
    getCoinMarket();
    // TODO: implement initState
    super.initState();
  }
}
