import 'package:cling/pages/create_account_page/identityPage.dart';
import 'package:flutter/material.dart';
import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';

class CreateAccountPage2 extends StatefulWidget {
  const CreateAccountPage2(
      {Key? key, required this.title, required this.alpacaAccount})
      : super(key: key);

  final String title;
  final alpaca_account alpacaAccount;

  @override
  State<CreateAccountPage2> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage2> {
  late TextEditingController _phonenumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalcodeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phonenumberController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalcodeController = TextEditingController();
  }

  @override
  void dispose() {
    _phonenumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalcodeController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (_formKey.currentState!.validate()) {
      widget.alpacaAccount.street_address = _addressController.text;
      widget.alpacaAccount.city = _cityController.text;
      widget.alpacaAccount.postal_code = _postalcodeController.text;
      widget.alpacaAccount.state = _stateController.text;
      widget.alpacaAccount.phone_number = _phonenumberController.text;

      //Navigate to next page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccountPage3(
                  title: 'Identity Information',
                  alpacaAccount: widget.alpacaAccount)));
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
                    child: TextFormField(
                      controller: _addressController,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.add_location),
                          labelText: 'Street Address'),
                      validator: (text) {
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    )),
              )),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _cityController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.location_city), labelText: 'City'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _stateController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.location_city), labelText: 'State'),
                    validator: (text) {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _postalcodeController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.confirmation_number),
                        labelText: 'Zipcode'),
                    validator: (text) {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _phonenumberController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.phone), labelText: 'Phone Number'),
                    validator: (text) {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: Text("Next Page"),
                  onPressed: () => createAccount(),
                ),
              )
            ],
          ),
        ));
  }
}
