import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';
import 'package:cling/pages/create_account_page/emailpassPage.dart';
import 'package:cling/pages/explore.dart';
import 'package:cling/pages/groupPages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cling/firebase_utils/firestore_api.dart';
import '../alpaca/alpaca_api.dart';
import '/model/stock.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late alpaca_account alpacaAccount;
  final buySellManager = alpacaAPI();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    alpacaAccount = new alpaca_account(
        "",
        "",
        "",
        "",
        "",
        ""
            "",
        "",
        "",
        "",
        "",
        "",
        false,
        false,
        false,
        false);
    FirebaseAuth auth = FirebaseAuth.instance;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginAction() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      String alpacaID = await fireAPI().getAlpacaId(_emailController.text);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(alpacaID);
      Navigator.pushNamed(context, '/homePage');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        alpacaAccount.email_address = _emailController.text;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateAccountPage(
                    title: 'Create Account', alpacaAccount: alpacaAccount)));
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _emailController,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.email), labelText: 'Email'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? val) {
                        // login field validation
                      },
                    ))),
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
              child: TextButton(
                child: Text("Login"),
                onPressed: () => loginAction(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
