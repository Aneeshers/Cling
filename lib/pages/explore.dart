import 'package:cling/model/stock.dart';
import 'package:cling/alpaca/alpaca_api.dart';
import 'package:cling/pages/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:cling/pages/stockPortfolioPage.dart';

class FilterLocalListPage extends StatefulWidget {
  FilterLocalListPage({Key? key}) : super(key: key);
  @override
  FilterLocalListPageState createState() => FilterLocalListPageState();
}

class FilterLocalListPageState extends State<FilterLocalListPage> {
  late List<Asset> stocks;
  final buySellManager = alpacaAPI();
  String query = '';

  List<Asset> alls = [];
  void getStocks() async {
    alls = await buySellManager.getAssets();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getStocks();

    stocks = [];
  }

  List<String> top = ["AAPL", "COIN", "SPOT", "SNAP", "MSFT", "SBUX"];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 70, 20, 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Explore",
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              buildSearch(),
              Expanded(
                child: Container(
                  height: 75,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 185),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: top.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://s3.polygon.io/logos/${top[index].toLowerCase()}/logo.png')),
                                title: Text(
                                  top[index],
                                  style: TextStyle(color: Colors.black87),
                                ),
                                onTap: () async {
                                  Navigator.pushNamed(context, '/portfolioPage',
                                      arguments: portfolioArgs(
                                          top[index],
                                          await buySellManager
                                              .getSymbolLogo(top[index]),
                                          top[index],
                                          (await buySellManager
                                                  .getAlphaQuote(top[index]))
                                              .toString(),
                                          await buySellManager
                                              .getAboutData(top[index])));
                                },
                              )),
                        );
                      }),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final book = stocks[index];

                    return buildStock(book);
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search Stocks and Companies',
        onChanged: searchStocks,
      );

  Widget buildStock(Asset stock) => ListTile(
        // leading: Image.network(
        //  stock.urlImage,
        // fit: BoxFit.cover,
        //width: 50,
        //height: 50,
        //placeholder: (context, url) => CircularProgressIndicator(),
        //errorWidget: (context, url, error) => Icon(Icons.error),
        //),
        title: Text(stock.symbol),
        subtitle: Text(stock.name),
        onTap: () async {
          print(buySellManager.getSymbolLogo(stock.symbol));
          Navigator.pushNamed(context, '/portfolioPage',
              arguments: portfolioArgs(
                  stock.symbol,
                  await buySellManager.getSymbolLogo(stock.symbol),
                  stock.name,
                  (await buySellManager.getAlphaQuote(stock.symbol)).toString(),
                  await buySellManager.getAboutData(stock.symbol)));
        },
      );

  void searchStocks(String query) {
    if (query != "") {
      final stocks = alls.where((stock) {
        final symbolLower = stock.symbol.toLowerCase();
        final companyLower = stock.name.toLowerCase();
        final searchLower = query.toLowerCase();

        return symbolLower.contains(searchLower) ||
            companyLower.contains(searchLower);
      }).toList();

      setState(() {
        this.query = query;
        this.stocks = stocks;
      });
    } else {
      setState(() {
        this.query = query;
        this.stocks = [];
      });
    }
  }
}
