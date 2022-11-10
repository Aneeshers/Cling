import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';
import 'package:cling/alpaca/alpaca_api.dart';

class CreateAccountPage4 extends StatefulWidget {
  const CreateAccountPage4(
      {Key? key, required this.title, required this.alpacaAccount})
      : super(key: key);

  final String title;
  final alpaca_account alpacaAccount;

  @override
  State<CreateAccountPage4> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage4> {
  final _formKey = GlobalKey<FormState>();
  late bool _is_control_person;
  late bool _is_affiliated_exchange_or_finra;
  late bool _is_politically_exposed;
  late bool _immediate_family_exposed;

  @override
  void initState() {
    _is_control_person = false;
    _is_affiliated_exchange_or_finra = false;
    _is_politically_exposed = false;
    _immediate_family_exposed = false;
  }

  void createAccount() async {
    if (_formKey.currentState!.validate()) {
      widget.alpacaAccount.is_affiliated_exchange_or_finra =
          _is_affiliated_exchange_or_finra;
      widget.alpacaAccount.is_politically_exposed = _is_politically_exposed;
      widget.alpacaAccount.is_control_person = _is_control_person;
      widget.alpacaAccount.immediate_family_exposed = _immediate_family_exposed;
      await alpacaAPI().createAccount(widget.alpacaAccount, context);
    } else {
      print("invalid form");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Form(
                key: _formKey,
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text("Is affiliated exchange or FINRA?"),
                        CupertinoSwitch(
                          value: _is_affiliated_exchange_or_finra,
                          onChanged: (value) {
                            setState(() {
                              _is_affiliated_exchange_or_finra = value;
                            });
                          },
                        )
                      ],
                    )),
              )),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text("Is Control Person?"),
                        CupertinoSwitch(
                          value: _is_affiliated_exchange_or_finra,
                          onChanged: (value) {
                            setState(() {
                              _is_affiliated_exchange_or_finra = value;
                            });
                          },
                        )
                      ],
                    )),
              ),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text("Is Politcally Exposed?"),
                        CupertinoSwitch(
                          value: _is_politically_exposed,
                          onChanged: (value) {
                            setState(() {
                              _is_politically_exposed = value;
                            });
                          },
                        )
                      ],
                    )),
              ),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text("Immediate Family Exposed?"),
                        CupertinoSwitch(
                          value: _immediate_family_exposed,
                          onChanged: (value) {
                            setState(() {
                              _immediate_family_exposed = value;
                            });
                          },
                        )
                      ],
                    )),
              ),
              Center(
                child: ElevatedButton(
                  child: Text("Open New Account"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreenAccent),
                  onPressed: () => createAccount(),
                ),
              )
            ],
          ),
        ));
  }
}
