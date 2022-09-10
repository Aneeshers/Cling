import 'dart:convert';
import 'dart:math';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cling/deposit.dart';
import 'package:cling/alpaca_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_api.dart';
import 'groupPortfolio.dart';

class utils {
  static final Random _random = Random.secure();

  static String CreateCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

class groupsPage extends StatefulWidget {
  const groupsPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<groupsPage> createState() => _groupsPageState();
}

class _groupsPageState extends State<groupsPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final firebaseManager = fireAPI();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String accnum = "24575355-35da-491c-ad92-0a5cd6590549";

  final GlobalKey<FormState> _formNameKey = GlobalKey<FormState>();
  String createGroupName = '';
  @override
  Widget build(BuildContext context) {
    String depositAmount = "";
    String shares = "";

    final Stream<QuerySnapshot> _userGroupsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(accnum)
        .collection('groups')
        .snapshots();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return StreamBuilder<QuerySnapshot>(
      stream: _userGroupsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something is going wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(children: [
            SizedBox(height: 50),
            Center(
                child: Container(
                    child: Text(
              "Groups",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )))
          ]);
        }

        return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                //Navigator.pushNamed(context, '/createGroupPage');
                _createGroupSheet();
              },
            ),
            body: Column(children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width / 3, 60, 0, 0),
                child: Row(children: [
                  Text(
                    "Groups",
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(children: [
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      final Stream<DocumentSnapshot> groupNameStream =
                          FirebaseFirestore.instance
                              .collection('groups')
                              .doc(data['groupLocation'])
                              .snapshots();
                      return StreamBuilder<DocumentSnapshot>(
                        stream: groupNameStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }
                          try {
                            if (snapshot.data?['users'].length > 0) {
                              groupObj g = groupObj(
                                  id: data['groupLocation'],
                                  name: snapshot.data?['Name']);
                              return Card(
                                  child: ListTile(
                                title: Text(snapshot.data?['Name']),
                                onTap: () async {
                                  Navigator.pushNamed(
                                      context, '/groupPortfolio',
                                      arguments: groupArgs(
                                          g,
                                          await firebaseManager
                                              .getGroupQuotes(g.id)));
                                },
                              ));
                            }
                          } catch (e) {}
                          return Card(
                              child: ListTile(
                            title: Text(snapshot.data?['Name']),
                            trailing: Column(children: [
                              SizedBox(
                                height: 5,
                              ),
                              Icon(
                                Icons.error_outline,
                                color: Colors.amberAccent,
                              ),
                              Text("no users")
                            ]),
                            onTap: () async {
                              groupObj g = groupObj(
                                  id: data['groupLocation'],
                                  name: snapshot.data?['Name']);

                              Navigator.pushNamed(context, '/groupPortfolio',
                                  arguments: groupArgs(
                                      g,
                                      await firebaseManager
                                          .getGroupQuotes(g.id)));
                            },
                          ));
                        },
                      );
                    }).toList(),
                  ),
                ]),
              )
            ]));
      },
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _createGroupSheet() {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: .8,
      headerHeight: 200,
      context: context,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 48, 51, 107),
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
            color: Colors.transparent,
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
                'Create Group',
                style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: Form(
                  key: _formNameKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter group name',
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          print(value);
                          String groupID = utils.CreateCryptoRandomString();
                          CollectionReference userGroups = FirebaseFirestore
                              .instance
                              .collection('users')
                              .doc(accnum)
                              .collection('groups');
                          userGroups
                              .doc(groupID)
                              .set({
                                'groupLocation': groupID // 42
                              })
                              .then((value) => print("groups Added to users"))
                              .catchError((error) => print(
                                  "Failed to add group to users: $error"));
                          CollectionReference groups =
                              FirebaseFirestore.instance.collection('groups');
                          groups
                              .doc(groupID)
                              .set({
                                'Name': value,
                                'users': [accnum],
                                'shares': {},
                              })
                              .then((value) =>
                                  print("groups Added to groups collection"))
                              .catchError((error) => print(
                                  "Failed to add group to groups collection: $error"));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 255, 118, 117)),
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formNameKey.currentState!.validate()) {
                              _formNameKey.currentState?.save();
                              // Process data.

                            }
                          },
                          child: const Text('Create!'),
                        ),
                      ),
                    ],
                  ),
                ),
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
}
