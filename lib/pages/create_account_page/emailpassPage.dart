import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';
import 'package:cling/pages/create_account_page/contactPage.dart';
import 'package:cling/alpaca/alpaca_api.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage(
      {Key? key, required this.title, required this.alpacaAccount})
      : super(key: key);

  final String title;
  final alpaca_account alpacaAccount;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _reenterpasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _reenterpasswordController = TextEditingController();
    FirebaseAuth auth = FirebaseAuth.instance;

    if (widget.alpacaAccount.email_address != "") {
      _emailController.text = widget.alpacaAccount.email_address;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _reenterpasswordController.dispose();
    super.dispose();
  }

  void createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        widget.alpacaAccount.email_address = _emailController.text;
        //await alpacaAPI().createAccount();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateAccountPage2(
                    title: 'Location Information',
                    alpacaAccount: widget.alpacaAccount)));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Invalid form");
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
                      controller: _emailController,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.email), labelText: 'Email'),
                      validator: (text) {
                        if (text?.indexOf('@') == -1) {
                          return "Invalid Email Format";
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    )),
              )),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.password), labelText: 'Password'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _reenterpasswordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.password),
                        labelText: 'Re-Enter Password'),
                    validator: (text) {
                      if (_reenterpasswordController.text !=
                          _passwordController.text) {
                        return "Passwords do not match";
                      } else {
                        return null;
                      }
                    },
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
