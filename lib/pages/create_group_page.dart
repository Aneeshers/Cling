import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cling/firebase_utils/firestore_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cling/model/datum.dart';
import 'package:cling/alpaca/alpaca_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyData {
  String name = '';
  String phone = '';
  String email = '';
  String age = '';
}

class createGroupPage extends StatefulWidget {
  const createGroupPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;
  @override
  State<createGroupPage> createState() => _createGroupPageState();
}

class _createGroupPageState extends State<createGroupPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<FormState> _formNameKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 51, 107),
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.transparent, //rgb(48, 51, 107)
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Form(
          key: _formNameKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formNameKey.currentState!.validate()) {
                      // Process data.
                    }
                  },
                  child: const Text('Create!'),
                ),
              ),
            ],
          ),
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
