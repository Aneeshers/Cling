import 'package:cling/alpaca_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

class HomePageState extends StatefulWidget {
  const HomePageState({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePageState> createState() => HomePage();
}

class HomePage extends State<HomePageState> {
  final stateManager = HomePageManager();
  final depositManager = deposit();
  final buySellManager = alpacaAPI();
  late TextEditingController _depositController;
  late TextEditingController _symbolController;
  late TextEditingController _sharesController;
  String accnum = "24575355-35da-491c-ad92-0a5cd6590549";

  String buyingPower = "";
  String quotePrice = "";
  String symbol = "";
  void updateBuyingPower(String value) {
    setState(() {
      buyingPower = "Buying power \$" + value;
    });
  }

  void updateQuotePrice(String value) {
    setState(() {
      quotePrice = value;
    });
  }

  void updateSymbol(String value) {
    setState(() {
      symbol = value;
    });
  }

  List orderHistory = [];
  void updateOrders(List values) {
    setState(() {
      orderHistory = values;
    });
  }

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController();
    _symbolController = TextEditingController();
    _sharesController = TextEditingController();
  }

  @override
  void dispose() {
    _depositController.dispose();
    _symbolController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String depositAmount = "";
    String shares = "";
    String accnum = "24575355-35da-491c-ad92-0a5cd6590549";

    return Column(
      children: [
        SizedBox(height: 50),
        Center(
          child: Wrap(
            spacing: 50,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Logout'),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ValueListenableBuilder<RequestState>(
          valueListenable: stateManager.resultNotifier,
          builder: (context, requestState, child) {
            if (requestState is RequestLoadInProgress) {
              return CircularProgressIndicator();
            } else if (requestState is RequestLoadSuccess) {
              return Expanded(
                  child: SingleChildScrollView(child: Text(requestState.body)));
            } else {
              return Container();
            }
          },
        ),
        Center(
            child: Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: TextField(
            controller: _depositController,
            onChanged: (String value) async {
              depositAmount = value;
            },
            onSubmitted: (String value) async {
              await showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Thanks!'),
                    content:
                        Text('You have deposited "$value" to your account.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            decoration: InputDecoration(
                label: Center(child: Text("Deposit Amount USD"))),
          ),
        )),
        ElevatedButton.icon(
          icon: Icon(Icons.money_off_csred_rounded),
          label: Text("deposit"),
          style: ElevatedButton.styleFrom(primary: Colors.pinkAccent),
          onPressed: () async {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thanks!'),
                  content: Text(
                      'You have deposited \$$depositAmount USD to your account.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        depositManager.depositing(accnum, depositAmount);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            controller: _symbolController,
            onChanged: (String value) async {
              updateSymbol(value);
              updateQuotePrice(await buySellManager.getSymbolQuote(value));
            },
            decoration:
                InputDecoration(label: Center(child: Text("Buy (i.e AAPL)"))),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            controller: _sharesController,
            onChanged: (String value) async {
              shares = value;
            },
            decoration:
                InputDecoration(label: Center(child: Text("Shares (i.e 3)"))),
          ),
        ),
        ElevatedButton.icon(
          label: Text("buy"),
          icon: Icon(Icons.arrow_right_alt_sharp),
          style: ElevatedButton.styleFrom(primary: Colors.pinkAccent),
          onPressed: () async {
            buySellManager.buy(accnum, symbol, shares);
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thanks!'),
                  content: Text('You have bought $shares shares of $symbol.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        updateOrders(await buySellManager.getOrders(accnum));
                        updateBuyingPower(
                            await buySellManager.getBuyingPower(accnum));
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Text(buyingPower,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 10),
        Text("Symbol Price: $quotePrice",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 10),
        Text("Order History", style: const TextStyle(fontSize: 15)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Symbol',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Shares',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  for (var i in orderHistory)
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text(i["symbol"])),
                        DataCell(Text(i["qty"])),
                        DataCell(Text(i["status"])),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomePageManager {
  final resultNotifier = ValueNotifier<RequestState>(RequestInitial());
  static const urlPrefix =
      'https://broker-api.sandbox.alpaca.markets/v1/accounts';

  Future<void> makeGetRequest() async {
    final url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/24575355-35da-491c-ad92-0a5cd6590549/ach_relationships');
    Response retrieve = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
    );
    print(retrieve.body);
  }

  Future<void> makePostRequest() async {
    Map data = {
      "id": "24575355-35da-491c-ad92-0a5cd6590549",
      "account_id": "24575355-35da-491c-ad92-0a5cd6590549",
      "account_owner_name": "John Doe",
      "bank_account_type": "CHECKING",
      "bank_account_number": "123456789abc",
      "bank_routing_number": "121000358",
      "nickname": "Bank of America Checking"
    };
    final url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/24575355-35da-491c-ad92-0a5cd6590549/ach_relationships');
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  Future<void> makePutRequest() async {
    Map data = {
      "transfer_type": "ach",
      "relationship_id": "24575355-35da-491c-ad92-0a5cd6590549",
      "amount": "5000",
      "direction": "INCOMING"
    };
    final url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/24575355-35da-491c-ad92-0a5cd6590549/transfers');
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  Future<void> deposit() async {
    Map data = {
      "transfer_type": "ach",
      "relationship_id": "32505aaa-5ca3-41ee-8da5-ff231b23cccd",
      "amount": "500",
      "status": "COMPLETE",
      "direction": "INCOMING"
    };
    final url = Uri.parse(
        'https://broker-api.sandbox.alpaca.markets/v1/accounts/24575355-35da-491c-ad92-0a5cd6590549/transfers');
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  Future<void> makePatchRequest() async {
    resultNotifier.value = RequestLoadInProgress();
    final url = Uri.parse('$urlPrefix/posts/1');
    final headers = {"Content-type": "application/json"};
    final json = '{"title": "Hello"}';
    final response = await patch(url, headers: headers, body: json);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    _handleResponse(response);
  }

  Future<void> makeDeleteRequest() async {
    resultNotifier.value = RequestLoadInProgress();
    final url = Uri.parse('$urlPrefix/posts/1');
    final response = await delete(url);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    _handleResponse(response);
  }

  void _handleResponse(Response response) {
    if (response.statusCode >= 400) {
      resultNotifier.value = RequestLoadFailure();
    } else {
      resultNotifier.value = RequestLoadSuccess(response.body);
    }
  }
}

class deposit {
  final resultNotifier = ValueNotifier<RequestState>(RequestInitial());
  static const urlPrefix =
      'https://broker-api.sandbox.alpaca.markets/v1/accounts/';
  Future<void> depositing(String accountNumber, String amount) async {
    Uri url = Uri.parse(
        "https://broker-api.sandbox.alpaca.markets/v1/accounts/$accountNumber/ach_relationships");
    Response retrieve = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
    );
    String bankAch = jsonDecode(retrieve.body)[0]["id"];
    print("bank");
    print(bankAch);
    Map data = {
      "transfer_type": "ach",
      "relationship_id": bankAch,
      "amount": amount,
      "status": "COMPLETE",
      "direction": "INCOMING"
    };
    url = Uri.parse('https://broker-api.sandbox.alpaca.markets/v1/accounts/' +
        accountNumber +
        '/transfers');
    print(url);
    final response = await post(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
      body: json.encode(data),
    );
    print(response.body);
  }

  void _handleResponse(Response response) {
    if (response.statusCode >= 400) {
      resultNotifier.value = RequestLoadFailure();
    } else {
      resultNotifier.value = RequestLoadSuccess(response.body);
    }
  }
}

class orders {
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
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
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
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
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
        'https://broker-api.sandbox.alpaca.markets/v1/trading/accounts/24575355-35da-491c-ad92-0a5cd6590549/account');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
    );
    String buyingPower = jsonDecode(response.body)["buying_power"];
    return buyingPower;
  }

  Future<String> getSymbolQuote(String symbol) async {
    Uri url = Uri.parse(
        'https://data.sandbox.alpaca.markets/v2/stocks/$symbol/quotes/latest');
    final response = await get(
      url,
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic Q0tMMzRMV1NPT09FU05LWTVMVjA6TFk1cWFaWXZjc0t3THpuOGo0VDVlUzFsbVg0MlgxeEtXMDd3aGxGZg==',
      },
    );
    try {
      double quoteP = jsonDecode(response.body)["quote"]["bp"];
      return quoteP.toString();
    } catch (e) {
      return "";
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
