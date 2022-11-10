import 'package:cling/alpaca/alpaca_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class userVotes {
  List<dynamic> users;
  userVotes({
    required this.users,
  });
  final alpaca = alpacaAPI();
  Future<Map<dynamic, dynamic>> toMap() async {
    var usersMap = {};
    for (var user in users) {
      var name = await alpaca.getFirstName(user);
      usersMap[user] = {"name": name, "vote": false, "voted": false};
    }
    return usersMap;
  }
}

class groupObj {
  final String id;
  final String name;
  Map shares = {};
  List<DataRow> shareRows = [];
  final fire = fireAPI();
  final alpaca = alpacaAPI();
  double oneTMarketVal = 0;

  groupObj({required this.id, required this.name});

  Future<void> setShares() async {
    shares = await fire.getGroupShares(id);
  }

  Future<void> setShareRows() async {
    setShares();
    print("func called");
    List<DataRow> rows = [];
    for (var k in shares.keys) {
      print("Key : $k, value : ${shares[k]}");
      double notional = await alpaca.getAlphaQuote(k) * shares[k];
      DataRow row = DataRow(
        cells: <DataCell>[
          DataCell(Text(k)),
          DataCell(Text("\$" + notional.toStringAsFixed(2))),
          DataCell(Text(shares[k].toStringAsFixed(4))),
        ],
      );
      rows.add(row);
    }

    shareRows = rows;
  }

  Future<List<DataRow>> getShareRows() async {
    if (shareRows.isNotEmpty) {
      return shareRows;
    } else {
      await setShares();
      print("func called");
      List<DataRow> rows = [];
      for (var k in shares.keys) {
        print("Key : $k, value : ${shares[k]}");
        double notional = await alpaca.getAlphaQuote(k) * shares[k];
        DataRow row = DataRow(
          cells: <DataCell>[
            DataCell(Text(k)),
            DataCell(Text("\$" + notional.toStringAsFixed(2))),
            DataCell(Text(shares[k].toStringAsFixed(4))),
          ],
        );
        rows.add(row);
      }
      return rows;
    }
  }

  bool containsShare(String symbol) {
    return shares.containsKey(symbol);
  }

  void setMarketVals(double s, String symbol) {
    if (this.containsShare(symbol)) {
      oneTMarketVal = s;
    }
  }

  double getShare(String symbol) {
    if (this.containsShare(symbol)) {
      return shares[symbol];
    }
    return 0.0;
  }

  double getMarketVal(String symbol) {
    if (this.containsShare(symbol)) {
      return oneTMarketVal;
    }
    return 0.0;
  }
}

class fireAPI {
  final alpaca = alpacaAPI();
  Future<List<groupObj>> getGroupName(String accnum) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<groupObj> groupRefs = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(accnum)
        .collection('groups')
        .get()
        .then((QuerySnapshot documentSnapshot) async {
      for (var doc in documentSnapshot.docs) {
        var id = doc['groupLocation'];
        var name = '';
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(id)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            print('name is ${documentSnapshot['Name']}');
            groupRefs.add(groupObj(id: id, name: documentSnapshot['Name']));
          }
        });
      }
    });
    return groupRefs;
  }

  Future<List<dynamic>> getUsers(String groupID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<dynamic> users = [];

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          users = documentSnapshot['users'];
        }
      });
      print(users);
      return users;
    } catch (e) {
      return users;
    }
  }

  Future<Map> getGroupQuotes(String groupID) async {
    Map quotes = {};
    final group = await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupID)
        .get();
    Map shares = group["shares"];
    for (var sym in shares.keys) {
      quotes[sym] = await alpaca.getAlphaQuote(sym);
    }
    return quotes;
  }

  Future<void> postProposal(String groupID, double notional, String symbol,
      String trade, String authorID) async {
    var users = await getUsers(groupID);
    var firstName = await alpaca.getFirstName(authorID);
    userVotes votes = userVotes(users: users);
    final proposal = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('proposals');

    print(votes.toMap());
    proposal
        .add({
          'notional': notional,
          'symbol': symbol,
          'trade': trade,
          'votes': await votes.toMap(),
          'author_id': authorID,
          'author_name': firstName,
          'executed': false,
          'filled': false,
        })
        .then((value) => print("proposal added to group stream"))
        .catchError((error) => print("Failed to add proposal: $error"));
  }

  Future<void> updateShares(
      String groupID, String symbol, String propID) async {
    double qty = await getProposalShares(groupID, propID);
    final group = FirebaseFirestore.instance.collection("groups").doc(groupID);
    var prev_qty = (await group.get())["shares"][symbol];

    if (prev_qty == null) {
      group.update({"shares.$symbol": qty});
    } else {
      group.update({"shares.$symbol": (qty + prev_qty)});
    }
  }

  Future<void> addNewUser(
    String alpacaId,
    String fName,
    String lName,
    String email,
  ) async {
    final newUser =
        FirebaseFirestore.instance.collection('users').doc(alpacaId);

    print(newUser);
    newUser
        .set({
          'First Name': fName,
          'Last Name': lName,
          'email': email,
          'alpacaID': alpacaId,
        })
        .then((value) => print("new user added to database"))
        .catchError((error) => print("Failed to add new user: $error"));
  }

  Future<String> getAlpacaId(String email) async {
    final users = await FirebaseFirestore.instance.collection('users').get();

    for (var user in users.docs) {
      print(email);
      print(user.data()['email']);
      if (email == user.data()['email']) {
        return user.data()['alpacaID'];
      }
    }

    return "None";
  }

  Future<List<String>> getGroupProposals(String groupID) async {
    List<String> proposals_ls = [];
    final proposals = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('proposals')
        .get();
    for (var doc in proposals.docs) {
      proposals_ls.add(doc.id);
    }
    print(proposals_ls);
    return proposals_ls;
  }

  Future<double> getProposalShares(String groupID, String propID) async {
    double totalShares = 0.0;
    final proposal = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('proposals')
        .doc(propID)
        .get();
    for (var order in proposal["orders"]) {
      for (var key in order.keys) {
        double share = await alpaca.getOrderShare(key, order[key]);
        totalShares += share;
      }
    }
    return totalShares;
  }

  void count(QuerySnapshot documentSnapshot) {
    List lst = [];
    for (var doc in documentSnapshot.docs) {
      lst.add(doc.id);
    }
    ;
    print("lst: ");
    print(lst);
  }

  Future<Map> getGroupShares(String groupID) async {
    var groupShares = {};
    final proposals = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('proposals')
        .where("executed", isEqualTo: true)
        .get();
    if (proposals.docs.isNotEmpty) {
      for (var doc in proposals.docs) {
        if (!groupShares.containsKey(doc["symbol"])) {
          // Unique symbol
          groupShares[doc["symbol"]] = 0.0;
        }
        groupShares[doc["symbol"]] += await getProposalShares(groupID, doc.id);
      }
    }
    print(groupShares);
    return groupShares;
  }
}
