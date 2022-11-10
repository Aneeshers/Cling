import 'package:flutter/material.dart';
import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';
import 'package:cling/pages/create_account_page/disclosuresPage.dart';

class CreateAccountPage3 extends StatefulWidget {
  const CreateAccountPage3(
      {Key? key, required this.title, required this.alpacaAccount})
      : super(key: key);

  final String title;
  final alpaca_account alpacaAccount;

  @override
  State<CreateAccountPage3> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage3> {
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _DOBController;
  late TextEditingController _countryController;
  late TextEditingController _fundingSourceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController();
    _lnameController = TextEditingController();
    _DOBController = TextEditingController();
    _countryController = TextEditingController();
    _fundingSourceController = TextEditingController();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _DOBController.dispose();
    _countryController.dispose();
    _fundingSourceController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (_formKey.currentState!.validate()) {
      widget.alpacaAccount.given_name = _fnameController.text;
      widget.alpacaAccount.family_name = _lnameController.text;
      widget.alpacaAccount.date_of_birth = _DOBController.text;
      widget.alpacaAccount.country_of_tax_residency = _countryController.text;
      widget.alpacaAccount.funding_source = _fundingSourceController.text;

      //Navigate to next page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccountPage4(
                  title: 'Disclosures', alpacaAccount: widget.alpacaAccount)));
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
                      controller: _fnameController,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.account_circle),
                          labelText: 'First Name'),
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
                    controller: _lnameController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Last Name'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _DOBController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.date_range),
                        labelText: 'Date of Birth'),
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
                    controller: _countryController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.local_airport),
                        labelText: 'Country of Tax Residency'),
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
                    controller: _fundingSourceController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.money), labelText: 'Funding Source'),
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
