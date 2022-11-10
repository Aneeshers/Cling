import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'package:flutter/services.dart' show rootBundle;

import 'package:cling/model/datum.dart';

Future<List<QtyPerTime>> loadStockData() async {
  final String fileContent = await rootBundle.loadString('assets/data.json');
  final List<dynamic> data = jsonDecode(fileContent);
  return data.map((json) => QtyPerTime.fromJson(json)).toList();
}
