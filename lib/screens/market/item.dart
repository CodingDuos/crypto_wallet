import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  var item;
  bool valuebook;
  void Function(bool?)? func;
  Item({super.key, this.item, required this.valuebook, required this.func});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: GestureDetector(
          child: Card(
            color: Color(0xff262528),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: Row(
                  children: [
                    SizedBox(
                        height: myHeight * 0.05,
                        width: 40,
                        child: Image.network(widget.item.image)),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalize(widget.item.id.toString()),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Text(
                            '1 ' + widget.item.symbol,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: myHeight * 0.05,
                        // width: myWidth * 0.2,
                        child: Sparkline(
                          data: widget.item.sparklineIn7D.price,
                          lineWidth: 1.0,
                          backgroundColor: Color(0xff262528),
                          lineColor:
                              widget.item.marketCapChangePercentage24H >= 0
                                  ? Colors.green
                                  : Colors.red,
                          fillMode: FillMode.none,
                          pointColor: Colors.black,
                          fillGradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.7],
                              colors:
                                  widget.item.marketCapChangePercentage24H >= 0
                                      ? [Colors.green, Colors.white]
                                      : [Colors.red, Colors.white]),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: myWidth * 0.10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$ ${widget.item.currentPrice}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.item.priceChange24H
                                        .toString()
                                        .contains('-')
                                    ? "-\$${widget.item.priceChange24H.toStringAsFixed(2).toString().replaceAll('-', '')}"
                                    : "\$" +
                                        widget.item.priceChange24H
                                            .toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                width: myWidth * 0.01,
                              ),
                              Text(
                                widget.item.marketCapChangePercentage24H
                                        .toStringAsFixed(2) +
                                    '%',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: widget.item
                                                .marketCapChangePercentage24H >=
                                            0
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
