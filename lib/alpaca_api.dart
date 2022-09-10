import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:cling/model/stock.dart';
import 'package:cling/main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cling/alpaca_account_create_object.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cling/firestore_api.dart';

import 'datum.dart';

final String authHeader =
    "Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==";

class order {
  String accnum;
  String orderID;

  order({
    required this.accnum,
    required this.orderID,
  });

  Map getOrderID() {
    return {accnum: orderID};
  }
}

class alpacaAPI {
  final resultNotifier = ValueNotifier<RequestState>(RequestInitial());
  static const urlPrefix =
      'https://broker-api.sandbox.alpaca.markets/v1/accounts';

  Future<void> buy(String accountNumber, String symbol, String shares) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accountNumber/orders');
    Map data = {
      "symbol": symbol,
      "qty": shares,
      "side": "buy",
      "type": "market",
      "time_in_force": "day",
      "commission": "1"
    };
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  Future<order> tradeNotional(
      String accnum, String symbol, String notional, String side) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accnum/orders');
    Map data = {
      "symbol": symbol,
      "notional": notional,
      "side": side.toLowerCase(),
      "type": "market",
      "time_in_force": "day",
      "commission": "0"
    };
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    String orderID = jsonDecode(response.body)["id"];

    return order(accnum: accnum, orderID: orderID);
  }

  Future<void> buyForGroupShares(List<dynamic> users, String symbol,
      double shares, String groupName, BuildContext context) async {
    int num = users.length;
    if (num > 1) {
      for (var user in users) {
        String shareSplit = (shares / num).toString();
        print("ShareSplit: $shareSplit");
        await buy(user, symbol, shareSplit);
      }
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Congratulations!'),
                content: Text(
                    'You have bought $shares share of $symbol for $groupName'),
              ));
    }
  }

  Future<List<order>> tradeGroupNotional(
      List<dynamic> users,
      String symbol,
      double notional,
      String side,
      String groupName,
      BuildContext context) async {
    int num = users.length;
    List<order> orders = [];

    if (num > 1) {
      for (var user in users) {
        String shareSplit = (notional / num).toString();
        print("ShareSplit: $shareSplit");
        order o =
            await tradeNotional(user, symbol, shareSplit, side.toLowerCase());
        orders.add(o);
      }
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Congratulations!'),
                content: Text(
                    'You have traded \$$notional of $symbol for $groupName'),
              ));
    }
    return orders;
  }

  Future<void> depositFunds(
      String? accountID, String relationshipID, double amount) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/$accountID/transfers');

    Map data = {
      "transfer_type": "ach",
      "relationship_id": "a02c923b-1101-458b-a594-ccb8eccabf91",
      "amount": amount,
      "direction": "INCOMING"
    };

    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    var decoded_response = jsonDecode(response.body);
    print(decoded_response);
  }

  Future<void> createACHRelationship(String? accountID) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/$accountID/ach_relationships');

    Map data = {
      "account_owner_name": "John Doe",
      "bank_account_type": "CHECKING",
      "bank_account_number": "32131231abc",
      "bank_routing_number": "121000358",
      "nickname": "Bank of America Checking"
    };

    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    var decoded_response = jsonDecode(response.body);
    print(decoded_response);
  }

  Future<void> createAccount(
      alpaca_account account, BuildContext context) async {
    final firebaseManager = fireAPI();
    Uri url =
        Uri.parse('https://broker-api.sandbox.alpaca.markets/v1/accounts');
    Map data = {
      "contact": {
        //"email_address": account.email_address,
        "email_address": account.email_address,
        "phone_number": account.phone_number,
        "street_address": [account.street_address],
        "city": account.city,
        "state": account.state,
        "postal_code": account.postal_code,
        "country": account.country_of_tax_residency
      },
      "identity": {
        "given_name": account.given_name,
        "family_name": account.family_name,
        "date_of_birth": account.date_of_birth,
        //"tax_id": "666-55-4321",
        //"tax_id_type": "USA_SSN",
        //"country_of_citizenship": "USA",
        //"country_of_birth": "USA",
        "country_of_tax_residence": account.country_of_tax_residency,
        "funding_source": [account.funding_source]
      },
      "disclosures": {
        "is_control_person": account.is_control_person,
        "is_affiliated_exchange_or_finra":
            account.is_affiliated_exchange_or_finra,
        "is_politically_exposed": account.is_politically_exposed,
        "immediate_family_exposed": account.immediate_family_exposed
      },
      "agreements": [
        {
          "agreement": "margin_agreement",
          "signed_at": "2020-09-11T18:09:33Z",
          "ip_address": "185.13.21.99",
          "revision": "16.2021.05"
        },
        {
          "agreement": "account_agreement",
          "signed_at": "2020-09-11T18:13:44Z",
          "ip_address": "185.13.21.99",
          "revision": "16.2021.05"
        },
        {
          "agreement": "customer_agreement",
          "signed_at": "2020-09-11T18:13:44Z",
          "ip_address": "185.13.21.99",
          "revision": "16.2021.05"
        }
      ],
      /*"documents": [
        {
          "document_type": "identity_verification",
          "document_sub_type": "passport",
          "content": "QWxwYWNhcyBjYW5ub3QgbGl2ZSBhbG9uZS4=",
          "mime_type": "image/jpeg"
        }
      ],
      "trusted_contact": {
        "given_name": "Jane",
        "family_name": "Doe",
        "email_address": "jane.doe@example.com"
      }*/
    };
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    var decoded_response = jsonDecode(response.body);
    print(decoded_response['code']);
    if (decoded_response['code'] == null) {
      firebaseManager.addNewUser(
          decoded_response['id'],
          decoded_response['identity']['given_name'],
          decoded_response['identity']['family_name'],
          decoded_response['contact']['email_address']);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(decoded_response['id']);
      Navigator.pushNamed(context, '/homePage');
    } else {
      print(decoded_response);
    }
  }

  Future<void> buyNotional(
      String accountNumber, String symbol, String notional, String side) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accountNumber/orders');
    Map data = {
      "symbol": symbol,
      "notional": notional,
      "side": side,
      "type": "market",
      "time_in_force": "day",
      "commission": "1"
    };
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  Future<List> getOrders(String accountNumber) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accountNumber/orders?status=all');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    List orders = jsonDecode(response.body);

    orders.forEach((element) {
      print(element["symbol"]);
      print(element["qty"]);
    });
    return orders;
  }

  Future<String> getBuyingPower(String accountNumber) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accountNumber/account');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );

    String buyingPower = jsonDecode(response.body)["buying_power"];
    return buyingPower;
  }

  Future<String> getFirstName(String accountNumber) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/$accountNumber/');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );

    String firstName = jsonDecode(response.body)["identity"]["given_name"];
    return firstName;
  }

  Future<String> getSymbolQuote(String symbol) async {
    Uri url = Uri.parse(
        'https://data.sandbox.alpaca.markets/v2/stocks/$symbol/quotes/latest');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    try {
      double quoteP = jsonDecode(response.body)["quote"]["ap"].toDouble();
      return quoteP.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<double> getAlphaQuote(String symbol) async {
    Uri url = Uri.parse(
        'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=BV7KB38XJD03CHK7');
    final response = await read(url);
    double price = 0;
    price = double.parse(jsonDecode(response)['Global Quote']['05. price']);
    return price;
  }

  Future<List<Stock>> searchAssets(String query) async {
    Uri url = Uri.parse(
        'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$query&apikey=BV7KB38XJD03CHK7');
    final response = await read(url);
    print(jsonDecode(response)['bestMatches']);
    List<Stock> all = [];
    for (var result in jsonDecode(response)['bestMatches']) {
      print(result['2. name']);
      all.add(Stock(
          name: result['2. name'],
          symbol: result['1. symbol'],
          urlImage:
              'https://upload.wikimedia.org/wikipedia/commons/8/8e/Pan_Blue_Circle.png'));
    }

    return all;
  }

  Future<List<Stock>> getAssets() async {
    Uri url = Uri.parse('https://broker-api.sandbox.alpaca.markets/v1/assets');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    List<Stock> all = [];
    for (var symbol in jsonDecode(response.body)) {
      if (symbol['tradable']) {
        String sym = symbol['symbol'];
        sym = sym.toLowerCase();
        String logoUrl = 'https://s3.polygon.io/logos/aapl/logo.png';
        //final response = await http.head(Uri.parse(logoUrl));
        //if (response.statusCode == 403)
        //{
        all.add(Stock(
            name: symbol['name'], symbol: symbol['symbol'], urlImage: logoUrl));

        // }
        //else
        //{
        // all.add(Stock(name: symbol['name'], symbol: symbol['symbol'], urlImage: logoUrl));

        //print("added symbol");
      }
    }
    print("stock list length: ");
    print(all.length);

    return all;
  }

  Future<String> getSymbolLogo(String symbol) async {
    symbol = symbol.toLowerCase();
    String logoUrl = 'https://s3.polygon.io/logos/$symbol/logo.png';
    final response = await http.head(Uri.parse(logoUrl));
    if (response.statusCode == 403) {
      logoUrl =
          'https://hoseco.com.au/wp-content/uploads/2018/03/Light-Blue-Box.jpg';
    }
    return logoUrl;
  }

  String datify(int m) {
    if (m.toInt() <= 10) {
      return "0" + m.toString();
    }
    return m.toString();
  }

  Future<List<Datum>> getWeeklyData(String symbol) async {
    var yest = DateTime.now().subtract(Duration(days: 2));
    var l_week = yest.subtract(Duration(days: 7));
    String start =
        "${l_week.year}-${datify(l_week.month)}-${datify(l_week.day)}";
    String end = "${yest.year}-${datify(yest.month)}-${datify(yest.day)}";
    print(start);
    print(end);
    Uri url = Uri.parse(
        'https://data.sandbox.alpaca.markets/v2/stocks/$symbol/bars?start=$start&end=$end&timeframe=15Min');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    List<Datum> d = [];
    for (var symbol in jsonDecode(response.body)['bars']) {
      d.add(Datum(
          date: DateTime.parse(symbol['t']), close: symbol['c'].toDouble()));
    }
    return d;
  }

  Future<String> getAboutData(String symbol) async {
    Uri url = Uri.parse(
        'https://www.alphavantage.co/query?function=OVERVIEW&symbol=$symbol&apikey=BV7KB38XJD03CHK7');
    final response = await read(url);
    try {
      return jsonDecode(response)['Description'];
    } catch (e) {
      return 'No data';
    }
  }

  Future<double> getOrderShare(String accnum, String orderID) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accnum/orders/$orderID');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    if (jsonDecode(response.body)["side"] == "sell") {
      return -1.0 * double.parse(jsonDecode(response.body)["filled_qty"]);
    } else {
      return double.parse(jsonDecode(response.body)["filled_qty"]);
    }
  }

  Future<Position> getSymbolPosition(String symbol, String accNum) async {
    Uri url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/$accNum/positions/$symbol');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: authHeader,
      },
    );
    var position_data = jsonDecode(response.body);
    if (response.statusCode == 404) {
      return Position(
          symbol: '',
          qty: '',
          market_value: '',
          cost_basis: '',
          unrealized_pl: '',
          unrealized_plpc: '',
          unrealized_intraday_pl: '',
          unrealized_intraday_plpc: '',
          current_price: '',
          change_today: '');
    } else {
      return Position(
          symbol: position_data['symbol'],
          qty: position_data['qty'],
          market_value: position_data['market_value'],
          cost_basis: position_data['cost_basis'],
          unrealized_pl: position_data['unrealized_pl'],
          unrealized_plpc: position_data['unrealized_plpc'],
          unrealized_intraday_pl: position_data['unrealized_intraday_pl'],
          unrealized_intraday_plpc: position_data['unrealized_intraday_plpc'],
          current_price: position_data['current_price'],
          change_today: position_data['change_today']);
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode >= 400) {
      resultNotifier.value = RequestLoadFailure();
    } else {
      resultNotifier.value = RequestLoadSuccess(response.body);
    }
  }
}

class Position {
  Position({
    required this.symbol,
    required this.qty,
    required this.market_value,
    required this.cost_basis,
    required this.unrealized_pl,
    required this.unrealized_plpc,
    required this.unrealized_intraday_pl,
    required this.unrealized_intraday_plpc,
    required this.current_price,
    required this.change_today,
  });

  final String symbol;
  final String qty;
  final String market_value;
  final String cost_basis;
  final String unrealized_pl;
  final String unrealized_plpc;
  final String unrealized_intraday_pl;
  final String unrealized_intraday_plpc;
  final String current_price;
  final String change_today;
}
