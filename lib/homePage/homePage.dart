import 'package:cling/alpaca_api.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Menu { addFunds, Logout }

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final alpaca = alpacaAPI();

  void logoutAction() async {
    print(auth.currentUser);
    await auth.signOut();
    Navigator.pushNamed(context, "/login");
  }

  void addFundsAction() {
    Navigator.pushNamed(context, "/addFunds");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink,
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<Menu>(
              icon: const Icon(Icons.account_circle),
              // Callback that sets the selected popup menu item.
              onSelected: (Menu item) {
                setState(() {
                  print(item.name);
                  if (item.name == "Logout") {
                    logoutAction();
                  } else if (item.name == "addFunds") {
                    addFundsAction();
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                    const PopupMenuItem<Menu>(
                      value: Menu.addFunds,
                      child: Text('Add Funds'),
                    ),
                    const PopupMenuItem<Menu>(
                      value: Menu.Logout,
                      child: Text('Logout'),
                    ),
                  ]),
          // IconButton(
          //     onPressed: () {
          //       print(auth.currentUser);
          //     },
          //     icon: const Icon(Icons.account_circle))
        ],
      ),
      body: Text("Home Page"),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
