import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:cling/pages/main.dart';
import 'dart:convert';
import 'dart:io';

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
}
