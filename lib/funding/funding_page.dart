import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cling/alpaca_api.dart';

enum Menu { addFunds, Logout }

class FundingPage extends StatefulWidget {
  const FundingPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<FundingPage> createState() => _FundingPageState();
}

class _FundingPageState extends State<FundingPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  void logoutAction() async {
    print(auth.currentUser);
    await auth.signOut();
    Navigator.pushNamed(context, "/login");
  }

  void createACHRelationship() async {
    await alpacaAPI().createACHRelationship(auth.currentUser!.photoURL);
  }

  void depositFunds() async {
    await alpacaAPI().depositFunds(auth.currentUser!.photoURL, "test", 500);
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
                    if (item.name == "Logout") {
                      logoutAction();
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  createACHRelationship();
                },
                child: Text('Add Bank Account'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  depositFunds();
                },
                child: Text('Add 500 Dollars'),
              )
            ],
          ),
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
