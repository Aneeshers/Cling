import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cling/alpaca/alpaca_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../firebase_utils/firestore_api.dart';

class groupArgs {
  final groupObj group;
  final Map quotes;
  groupArgs(this.group, this.quotes);
}

class utils {
  static final Random _random = Random.secure();

  static String CreateCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

class groupPortfolio extends StatefulWidget {
  const groupPortfolio({
    Key? key,
    required this.group,
    required this.quotes,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final groupObj group;
  final Map quotes;
  @override
  State<groupPortfolio> createState() => _groupPortfolioState();
}

class _groupPortfolioState extends State<groupPortfolio> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<ListTile> shareRows = [];

  void initShares() async {
    shareRows = [];
    final group = await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.group.id)
        .get();
    for (var sym in widget.quotes.keys) {
      print("Key : $sym, value : ${widget.quotes[sym]}");
      double notional = group["shares"][sym] * widget.quotes[sym];
      ListTile tile = ListTile(
          leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://s3.polygon.io/logos/${sym.toLowerCase()}/logo.png')),
          title: Text(sym),
          isThreeLine: true,
          subtitle: Text("\$" +
              notional.toStringAsFixed(2) +
              "        " +
              group["shares"][sym].toStringAsFixed(4) +
              " shares"));

      shareRows.add(tile);
    }
  }

  @override
  void initState() {
    initShares();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String accnum = "24575355-35da-491c-ad92-0a5cd6590549";

  final GlobalKey<FormState> _formNameKey = GlobalKey<FormState>();
  String createGroupName = '';
  final alpaca = alpacaAPI();
  final firebaseManager = fireAPI();

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _proposalsStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.id)
        .collection('proposals')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _proposalsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(children: [
            SizedBox(height: 50),
            Container(
                margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Text(
                  widget.group.name,
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ))
          ]);
        }

        return Scaffold(
            floatingActionButton: SpeedDial(
              renderOverlay: false,
              spaceBetweenChildren: 10,
              backgroundColor: Color(0xff02d39a),
              elevation: 15,
              child: Icon(Icons.attach_money),
              children: [
                SpeedDialChild(
                  onTap: () {},
                  child: Icon(Icons.add_card),
                ),
              ],
            ),
            body: Column(children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 60, 10, 20),
                    child: Row(children: [
                      BackButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        widget.group.name,
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                ],
              ),
              Text(
                "Group Position",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: shareRows,
                  ),
                ),
              ),
              Text(
                "Proposals",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      firebaseManager.getGroupQuotes(widget.group.id);

                      int getVoteLen() {
                        int votelen = 0;
                        data['votes'].keys.forEach((k) {
                          if (data['votes'][k]['voted'] == true) {
                            votelen++;
                          }
                        });
                        return votelen;
                      }

                      void evalProposal() async {
                        final proposal = FirebaseFirestore.instance
                            .collection('groups')
                            .doc(widget.group.id)
                            .collection('proposals')
                            .doc(document.id);

                        if (getVoteLen() == data['votes'].length) {
                          if (!data['executed']) {
                            int trueVotes = 0;
                            data['votes'].keys.forEach((k) {
                              if (data['votes'][k]['vote'] == true) {
                                trueVotes++;
                              }
                            });
                            if (trueVotes == data['votes'].length) {
                              print("execute trade for group");
                              String trade = data["trade"];

                              var users = await firebaseManager
                                  .getUsers(widget.group.id);
                              double notional = data["notional"];
                              List<order> orders =
                                  await alpaca.tradeGroupNotional(
                                      users,
                                      data["symbol"],
                                      notional.toDouble(),
                                      trade,
                                      widget.group.name,
                                      context);
                              List<Map> orderIDs = [];
                              for (var o in orders) {
                                orderIDs.add(o.getOrderID());
                              }
                              proposal.update({"executed": true});
                              DateTime now = DateTime.now();
                              proposal.update({"time_exec": now});
                              proposal.update({"orders": orderIDs});
                            } else {
                              print("remove proposal");
                              proposal.delete();
                            }
                          } else {
                            if (data["filled"] == false) {
                              firebaseManager.updateShares(
                                  widget.group.id, data["symbol"], document.id);
                              proposal.update({"filled": true});
                            }
                          }
                        } else {
                          print(
                              "Not all users have voted, only ${getVoteLen()}/${data['votes'].length}");
                        }
                      }

                      void pushVote(acc, vote) {
                        print("voted");
                        final proposal = FirebaseFirestore.instance
                            .collection('groups')
                            .doc(widget.group.id)
                            .collection('proposals')
                            .doc(document.id);
                        proposal.update({"votes.$accnum.voted": true});
                        proposal.update({"votes.$accnum.vote": vote});
                      }

                      bool getVoted(acc) {
                        return data['votes'][acc]["voted"];
                      }

                      bool getVote(acc) {
                        return data['votes'][acc]["vote"];
                      }

                      // Check if everyone has voted, then either
                      //execute or remove proposal

                      evalProposal();

                      return Card(
                          child: ListTile(
                        title: Column(
                          children: [
                            Text(
                              "${data['trade']} \$${data['notional']} ${data['symbol']}",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 18),
                            ),
                            Text("Proposed by ${data['author_name']}"),
                            Text(
                                "${getVoteLen()}/${data['votes'].length} voted"),
                            if (getVoted(accnum)) ...[
                              ElevatedButton(
                                onPressed: null,
                                child: Text((() {
                                  if (getVote(accnum)) {
                                    return "Approved";
                                  }
                                  return "Rejected";
                                })()),
                                style: ElevatedButton.styleFrom(
                                    onSurface: ((() {
                                      if (getVote(accnum)) {
                                        if (data["executed"]) {
                                          return Colors.green;
                                        } else
                                          return Colors.blue;
                                      } else
                                        return Colors.red;
                                    })()),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    )),
                              ),
                            ] else ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 70),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          pushVote(accnum, true);
                                        },
                                        child: Text("Approve"),
                                        style: ElevatedButton.styleFrom(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          pushVote(accnum, false);
                                        },
                                        child: Text(
                                          "Reject",
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.redAccent,
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0),
                                            )),
                                      ),
                                    ]),
                              )
                            ]
                          ],
                        ),
                      ));
                    }).toList(),
                  ),
                ),
              )
            ]));
      },
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
