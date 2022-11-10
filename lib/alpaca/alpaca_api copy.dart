import 'dart:ffi';
import 'package:http/http.dart';
import 'package:cling/model/stock.dart';
import 'dart:convert';
import 'dart:io';
import '../model/datum.dart';
import 'package:cling/data/currentUserInfo.dart' as globals;

final String authHeader = globals.authHeader;

/// Handle orders respective to Alpaca account
class Order {
  final accnum;
  final String orderID;

  Order({
    required this.accnum,
    required this.orderID,
  });

  Map getOrderID() {
    return {accnum: orderID};
  }
}

// SymPostion obj -- contains market position for a respective asset
class AssetPos {
  final String symbol;
  final String qty;
  final String marketValue;
  final String costBasis;
  final String unrealizedPl;
  final String currentPrice;
  final String changeToday;

  AssetPos({
    required this.symbol,
    required this.qty,
    required this.marketValue,
    required this.costBasis,
    required this.unrealizedPl,
    required this.currentPrice,
    required this.changeToday,
  });
}

// REST Helper Class -- sends authorization headers to backend
// to execute GET and POST requests.

class AlpacaREST {
  Future<Response> POST(data, url) async {
    Uri endpoint = Uri.parse(url);
    final response = await post(
      endpoint,
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    return response;
  }

  Future<Response> GET(url) async {
    Uri endpoint = Uri.parse(url);
    final response = await get(
      endpoint,
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    return response;
  }

  // Throw Errors defined by Alpaca Response Error Codes
  void checkResponse(Response response) {
    if (response == null) {
      throw "Empty Response.";
    }
    final statusCode = response.statusCode;
    switch (statusCode) {
      case 501:
        {
          throw "Failed to liquiadte.";
        }
      case 500:
        {
          throw "Internal Server Error.";
        }
      case 431:
        {
          throw "Invalid funds.";
        }
      case 430:
        {
          throw "Unprocessable Entity.";
        }
      case 429:
        {
          throw "Reached rate limit.";
        }
      case 422:
        {
          throw "Account Conflict.";
        }
      case 404:
        {
          throw "Bad request.";
        }
      case 401:
        {
          throw "Both QTY and Notional were supplied.";
        }
      case 398:
        {
          throw "requested asset is not fractionable";
        }
    }
  }
}

// Allows us to access Alpaca User's identity, previous orders,
// assets' market poisiton, and buying power.
// Crucially, this class also allows an Alpaca User
// to buy and sell an asset.
class AlpacaUser {
  final String accnum;

  // Init Alpaca user with Alpaca account number
  AlpacaUser({required this.accnum});

  // Init REST access and Endpoint Prefixes
  final alpacaRest = AlpacaREST();
  static const brokerV1 = 'https://broker-api.sandbox.alpaca.markets/v1/';
  static const brokerV2 = 'https://data.sandbox.alpaca.markets/v2/';

  // Trades asset for user. Safety checks for sell and buy side found in frontend.
  // Returns Order obj for post-firebase processing.
  Future<Order> tradeNotional(
      String symbol, Double notional, globals.Side side) async {
    Map data = {
      "symbol": symbol,
      "notional": notional,
      "side": side,
      "type": "market",
      "time_in_force": "day",
    };

    // Sends transaction to Alpaca
    final response = await alpacaRest.POST(
        data, brokerV1 + 'trading/accounts/$accnum/orders');

    // Safety Check
    alpacaRest.checkResponse(response);

    // Alpaca will return the Order ID for that transaction.
    String orderID = jsonDecode(response.body)["id"];
    return Order(accnum: accnum, orderID: orderID);
  }

  // Returns list of User's orders
  // Orders are post-processed as Maps
  Future<List> getOrders() async {
    // Access all orders, including pending, rejected, and successful
    final response = await alpacaRest
        .GET(brokerV1 + 'trading/accounts/${this.accnum}/orders?status=all');

    // Safety Check
    alpacaRest.checkResponse(response);

    List orders = jsonDecode(response.body);
    return orders;
  }

  // Retrieve User's market position for a given Asset.
  // Returns an AssetPos obj -- containing symbol, qty, market value,
  // cost basis, unrealized profit, current price, and change today.
  Future<AssetPos> getAssetMarketPosition(String symbol, String accNum) async {
    final response = await alpacaRest
        .GET(brokerV1 + 'trading/accounts/$accNum/positions/$symbol');

    // Safety Check
    alpacaRest.checkResponse(response);

    final positionData = jsonDecode(response.body);

    // Return AssetPos obj with market position data
    return AssetPos(
        symbol: positionData['symbol'],
        qty: positionData['qty'],
        marketValue: positionData['market_value'],
        costBasis: positionData['cost_basis'],
        unrealizedPl: positionData['unrealized_pl'],
        currentPrice: positionData['current_price'],
        changeToday: positionData['change_today']);
  }

  // Access User's buying power -- see depost.dart
  // for funding and initializing bank information.
  Future<Double> getBuyingPower() async {
    final response = await alpacaRest
        .GET(brokerV1 + 'trading/accounts/${this.accnum}/account');

    // Safety Check
    alpacaRest.checkResponse(response);

    Double buyingPower = jsonDecode(response.body)["buying_power"];
    return buyingPower;
  }

  // Return Identity Map -- includes
  //first name, last name, address, and bank ACH relationship
  Future<Map> getIdentity() async {
    final response =
        await alpacaRest.GET(brokerV1 + 'accounts/${this.accnum}/');

    // Safety Check
    alpacaRest.checkResponse(response);

    Map identity = jsonDecode(response.body)["identity"];
    return identity;
  }
}

// Access market data through Alpaca's Historical Data Endpoint.
// Access all tradable assets, their ask price, and weekly data.
class AlpacaMarket {
  final alpacaRest = AlpacaREST();

  // Endpoint Prefixes
  static const brokerV1 = 'https://broker-api.sandbox.alpaca.markets/v1/';
  static const brokerV2 = 'https://data.sandbox.alpaca.markets/v2/';

  // Helper Function for Weekly Data
  String dateToStr(int digit) {
    if (digit.toInt() <= 10) {
      return "0" + digit.toString();
    }
    return digit.toString();
  }

  // Access all tradable assets from Alpaca's Market API
  // Returns list of Asset objects.
  Future<List<Asset>> getAllAssets() async {
    final response = await alpacaRest.GET(brokerV1 + 'assets');

    // Safety Check
    alpacaRest.checkResponse(response);
    List<Asset> assets = [];

    // Add all tradable assets to our output
    for (var asset in jsonDecode(response.body)) {
      if (asset['tradable']) {
        String sym = asset['symbol'];
        sym = sym.toLowerCase();

        String logoUrl = 'https://s3.polygon.io/logos/${sym}}/logo.png';
        assets.add(Asset(
            name: asset['name'], symbol: asset['symbol'], urlImage: logoUrl));
      }
    }
    return assets;
  }

  // Access latest (15min delay) ask price of an asset.
  Future<double> getAssetAskPrice(String symbol) async {
    final response =
        await alpacaRest.GET(brokerV2 + 'stocks/$symbol/quotes/latest');

    // Safety Check
    alpacaRest.checkResponse(response);

    // Return ask price of asset
    double askPrice = jsonDecode(response.body)["quote"]["ap"].toDouble();
    return askPrice;
  }

  // Get close price data for asset for every 15 minutes since last week until now.
  // Returns list of QtyPerTime obj containing time and cp.
  Future<List<QtyPerTime>> getWeeklyData(String symbol) async {
    // Init start time and end time (now and one week before now).
    final currentTime = DateTime.now();
    var lastWeek = currentTime.subtract(Duration(days: 7));
    String start =
        "${lastWeek.year}-${dateToStr(lastWeek.month)}-${dateToStr(lastWeek.day)}";
    String end =
        "${currentTime.year}-${dateToStr(currentTime.month)}-${dateToStr(currentTime.day)}";

    // Get Data for every 15 minutes since last week to now.
    final response = await alpacaRest.GET(
        brokerV2 + 'stocks/$symbol/bars?start=$start&end=$end&timeframe=15Min');

    // Safety Check
    alpacaRest.checkResponse(response);

    // Add every 15-min data point to our output
    List<QtyPerTime> weeklyData = [];
    for (var dataPoint in jsonDecode(response.body)['bars']) {
      weeklyData.add(QtyPerTime(
          date: DateTime.parse(dataPoint['t']),
          close: dataPoint['c'].toDouble()));
    }
    return weeklyData;
  }
}
