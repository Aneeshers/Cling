import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cling/firebase_utils/firestore_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cling/model/datum.dart';
import 'package:cling/alpaca/alpaca_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cling/pages/groupPortfolio.dart';

class portfolioArgs {
  final String stock;
  final String logoURL;
  final String company;
  final String quote;
  final String aboutData;

  portfolioArgs(
      this.stock, this.logoURL, this.company, this.quote, this.aboutData);
}

class portfolioPage extends StatefulWidget {
  const portfolioPage({
    Key? key,
    required this.symbol,
    required this.logoURL,
    required this.company,
    required this.quote,
    required this.aboutData,
  }) : super(key: key);

  final String symbol;
  final String logoURL;
  final String company;
  final String quote;
  final String aboutData;
  @override
  State<portfolioPage> createState() => _portfolioPageState();
}

class _portfolioPageState extends State<portfolioPage> {
  final alpaca = alpacaAPI();
  final firebaseManager = fireAPI();
  late double touchedValue;
  List<Color> gradientGreenColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  List<Color> gradientRedColors = [
    const Color(0xffD980FA),
    const Color(0xffB53471),
  ];
  List<FlSpot> _values = const [];
  List<FlSpot> _avgValues = const [];
  String quote = '';
  void updateQuote(String value) {
    setState(() {
      quote = value;
    });
  }

  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  int _divider = 15;
  double avg = 0;
  String aboutText = '';
  String market_value = '';
  String shares = '';
  String profit = '';
  double percentChange = 0;
  List<groupObj> groups = [];

  void _prepareStockData() async {
    final List<QtyPerTime> data = await alpaca.getWeeklyData(widget.symbol);
    double minY = double.maxFinite;
    double maxY = double.minPositive;

    _values = data.map((datum) {
      if (minY > datum.close) minY = datum.close;
      if (maxY < datum.close) maxY = datum.close;
      return FlSpot(
        datum.date.millisecondsSinceEpoch.toDouble(),
        datum.close,
      );
    }).toList();
    _minX = _values.first.x;
    _maxX = _values.last.x;
    _minY = (minY / _divider).floorToDouble() * _divider;
    _maxY = (maxY / _divider).ceilToDouble() * _divider;
    avg = (_maxY + minY) / 2;
    _avgValues = data.map((datum) {
      if (minY > datum.close) minY = datum.close;
      if (maxY < datum.close) maxY = datum.close;
      return FlSpot(
        datum.date.millisecondsSinceEpoch.toDouble(),
        avg,
      );
    }).toList();
    percentChange =
        ((_values.last.y - _values.first.y) / _values.first.y.abs()) * 100;
    percentChange = double.parse((percentChange.toStringAsFixed(2)));
    setState(() {});
  }

  void _getMarketData(accnum) async {
    market_value =
        (await alpaca.getSymbolPosition(widget.symbol, accnum)).market_value;

    shares = (await alpaca.getSymbolPosition(widget.symbol, accnum)).qty;
    profit =
        (await alpaca.getSymbolPosition(widget.symbol, accnum)).unrealized_pl;
    Position p = await alpaca.getSymbolPosition(widget.symbol, accnum);

    setState(() {});
  }

  void _getGroups(accnum) async {
    groups = await firebaseManager.getGroupName(accnum);
    for (var group in groups) {
      group.setShares();
    }
    setState(() {});
  }

  @override
  void initState() {
    quote = widget.quote;
    _prepareStockData();
    touchedValue = -1;
    _getMarketData('24575355-35da-491c-ad92-0a5cd6590549');
    _getGroups('24575355-35da-491c-ad92-0a5cd6590549');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 48, 51, 107),
        floatingActionButton: SpeedDial(
          renderOverlay: false,
          spaceBetweenChildren: 10,
          backgroundColor: () {
            if (percentChange < 0) {
              return Color(0xffB53471);
            }
            return Color(0xff02d39a);
          }(),
          elevation: 15,
          child: Text(
            'Trade',
            style: TextStyle(color: Colors.black),
          ),
          children: [
            SpeedDialChild(
              onTap: () => _showSelectGroups(widget.symbol),
              child: Text(
                'Buy',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SpeedDialChild(
                onTap: () async => _showSellSheet(
                    widget.symbol,
                    await alpaca.getSymbolPosition(
                        widget.symbol, '24575355-35da-491c-ad92-0a5cd6590549')),
                child: Text(
                  'Sell',
                  style: TextStyle(color: Colors.black),
                )),
          ],
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 48, 51, 107), //rgb(48, 51, 107)
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(children: [
            Row(
              children: [
                SizedBox(height: 70),
                CircleAvatar(
                  foregroundImage: NetworkImage(widget.logoURL),
                  radius: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  widget.symbol,
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    widget.company,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Center(
                  child: Text(
                    '\$' + quote,
                    style: TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Center(
                  child: Text(
                    '%' + percentChange.toString(),
                    style: TextStyle(
                        fontSize: 18,
                        color: () {
                          if (percentChange < 0) {
                            return gradientRedColors[1];
                          }
                          return gradientGreenColors[1];
                        }(),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                          showOnTopOfTheChartBoxArea: false,
                          tooltipRoundedRadius: 25,
                          tooltipMargin: 25,
                          tooltipPadding: EdgeInsets.fromLTRB(15, 10, 15, -8),
                          tooltipBgColor: Colors.transparent,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              final DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      flSpot.x.toInt());
                              // updateBuyingPower(flSpot.y.toString());
                              return LineTooltipItem(
                                '${DateFormat.E().add_jm().format(date).toString()} \n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          }),
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? lineTouch) {
                        if (!event.isInterestedForInteractions ||
                            lineTouch == null ||
                            lineTouch.lineBarSpots == null) {
                          setState(() {
                            touchedValue = -1;
                            updateQuote(widget.quote);
                          });
                          return;
                        }
                        final value = lineTouch.lineBarSpots![0].x;
                        updateQuote(lineTouch.lineBarSpots![0].y.toString());

                        setState(() {
                          touchedValue = value;
                        });
                      }),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: avg,
                      color: Colors.blueGrey.withOpacity(0.8),
                      strokeWidth: 1.5,
                      dashArray: [10, 2],
                    ),
                  ]),
                  lineBarsData: [
                    LineChartBarData(
                      dotData: FlDotData(
                        show: false,
                      ),
                      isStepLineChart: false,
                      spots: _values,
                      isCurved: false,
                      barWidth: 2.5,
                      colors: () {
                        if (percentChange > 0) {
                          return gradientGreenColors;
                        }
                        return gradientRedColors;
                      }(),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                  minX: _minX,
                  maxX: _maxX,
                  minY: _minY,
                  maxY: _maxY,
                  gridData: FlGridData(
                    show: false,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  titlesData: FlTitlesData(
                    show: false,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'About',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ReadMoreText(
                    widget.aboutData,
                    trimLines: 2,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Show less',
                    moreStyle: TextStyle(fontSize: 15, color: Colors.pink),
                    lessStyle: TextStyle(color: Colors.pink, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  'Your Position',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Card(
                  color: Colors.transparent,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Shares: $shares",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text("Market value: \$$market_value",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Profit: \$$profit",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
          ]),
        )); // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _showSelectGroups(String symbol) async {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: .8,
      headerHeight: 200,
      context: context,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 132, 140, 207),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Color.fromRGBO(100, 108, 175, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(offset == 0.8 ? 0 : 40),
              topRight: Radius.circular(offset == 0.8 ? 0 : 40),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Invest in $symbol',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([
          for (var group in groups)
            Card(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(group.name),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showSelectTrade(symbol, group, true);
                  },
                ))
        ]);
      },
      anchors: [.2, 0.5, .8],
    );
  }

  void _showSelectTrade(String symbol, groupObj group, bool buy) async {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: .8,
      headerHeight: 200,
      context: context,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 132, 140, 207),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Color.fromRGBO(100, 108, 175, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(offset == 0.8 ? 0 : 40),
              topRight: Radius.circular(offset == 0.8 ? 0 : 40),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              if (buy)
                Text(
                  'Invest in $symbol',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              if (!buy)
                Text(
                  'Sell $symbol',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              Text(
                group.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              if (buy)
                Text(
                  ' \$1203.34',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 5),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 35,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await postProposal(group, 20, symbol,
                              "24575355-35da-491c-ad92-0a5cd6590549", buy);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black26,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Text(
                          '\$20',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await postProposal(group, 30, symbol,
                              "24575355-35da-491c-ad92-0a5cd6590549", buy);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black26,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Text(
                          '\$30',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await postProposal(group, 40, symbol,
                              "24575355-35da-491c-ad92-0a5cd6590549", buy);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black26,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Text(
                          '\$40',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Other amount",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([]);
      },
      anchors: [.2, 0.5, .8],
    );
  }

  void _showSellSheet(String symbol, Position position_history) {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: .8,
      headerHeight: 200,
      context: context,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 132, 140, 207),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Color.fromRGBO(100, 108, 175, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(offset == 0.8 ? 0 : 40),
              topRight: Radius.circular(offset == 0.8 ? 0 : 40),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Sell $symbol',
                style: TextStyle(
                    fontSize: 27,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'You own ${position_history.qty} shares of $symbol',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([
          for (var group in groups)
            if (group.containsShare(symbol))
              Card(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(group.name),
                    trailing: Text("\$" +
                        (group.getShare(widget.symbol) *
                                double.parse(widget.quote))
                            .toDouble()
                            .toStringAsFixed(2)),
                    onTap: () {
                      _showSelectTrade(symbol, group, false);
                    },
                  ))
        ]);
      },
      anchors: [.2, 0.5, .8],
    );
  }

  Future<void> postProposal(groupObj group, double amount, String symbol,
      String accnum, bool buy) async {
    String trade = "Buy";
    bool fundable = false;

    if (!buy) {
      trade = "Sell";
      double notional_owned = double.parse(
          (group.getShare(widget.symbol) * double.parse(widget.quote))
              .toDouble()
              .toStringAsFixed(2));
      if (amount <= notional_owned) {
        fundable = true;
      }
    } else {
      // Add check for buying power
      fundable = true;
    }
    if (fundable) {
      firebaseManager.postProposal(group.id, amount, symbol, trade,
          "24575355-35da-491c-ad92-0a5cd6590549");
      Navigator.pushNamed(context, '/groupPortfolio',
          arguments:
              groupArgs(group, await firebaseManager.getGroupQuotes(group.id)));
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text('Transacation Failed'),
          content: Text('You do not have enough shares to sell $amount'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}

class RequestState {
  const RequestState();
}

class RequestInitial extends RequestState {}

class RequestLoadInProgress extends RequestState {}

class RequestLoadSuccess extends RequestState {
  const RequestLoadSuccess(this.body);
  final String body;
}

class RequestLoadFailure extends RequestState {}
