import 'package:cling/alpaca/alpaca_api.dart';
import 'package:cling/pages/create_group_page.dart';
import 'package:cling/pages/groupPages.dart';
import 'package:flutter/material.dart';
import 'package:cling/pages/explore.dart';
import 'package:cling/pages/login.dart';
import 'package:cling/model/stock.dart';
import 'package:cling/pages/homePage/homePage.dart';
import 'package:cling/stockPortfolioPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'create_account_page/emailpassPage.dart';
import 'package:cling/funding/funding_page.dart';
import '../firebase_utils/firebase_options.dart';
import 'package:cling/pages/create_account_page/alpaca_account_create_object.dart';
import 'groupPortfolio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyStatefulWidget());
  // to test login to nav bar do this:
  //runApp(initializeAuth());
}

class initializeAuth extends StatelessWidget {
  final int number = 1;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/homePage': (context) => MyStatefulWidget()},
      home: LoginPage(
        title: 'Login',
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => MyApp();
}

class MyApp extends State<MyStatefulWidget> {
  final newAlpacaAccount = new alpaca_account(
      "", "", "", "", "", "", "", "", "", "", "", false, false, false, false);
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(title: 'Home'),
    FilterLocalListPage(),
    groupsPage(title: 'Groups')
  ];
  final buySellManager = alpacaAPI();
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            //final args = settings.arguments as loginData;
            return MaterialPageRoute(
              builder: (context) {
                return initializeAuth();
              },
            );
          }
          if (settings.name == '/create_account') {
            //final args = settings.arguments as loginData;
            return MaterialPageRoute(
              builder: (context) {
                return CreateAccountPage(
                  title: 'Create an Account',
                  alpacaAccount: newAlpacaAccount,
                );
              },
            );
          }
          if (settings.name == '/homePage') {
            //final args = settings.arguments as loginData;
            return MaterialPageRoute(builder: (context) {
              return HomePage(title: 'Home');
            });
          }
          if (settings.name == '/filter') {
            final args = settings.arguments as allStocks;
            return MaterialPageRoute(
              builder: (context) {
                return FilterLocalListPage();
              },
            );
          }
          if (settings.name == '/groupPortfolio') {
            final args = settings.arguments as groupArgs;
            return MaterialPageRoute(
              builder: (context) {
                return groupPortfolio(
                  group: args.group,
                  quotes: args.quotes,
                );
              },
            );
          }
          if (settings.name == '/createGroupPage') {
            return MaterialPageRoute(
              builder: (context) {
                return createGroupPage(title: 'Create A New Group');
              },
            );
          }
          if (settings.name == '/portfolioPage') {
            final args = settings.arguments as portfolioArgs;
            return MaterialPageRoute(
              builder: (context) {
                return portfolioPage(
                  symbol: args.stock,
                  logoURL: args.logoURL,
                  company: args.company,
                  quote: args.quote,
                  aboutData: args.aboutData,
                );
              },
            );
          }

          if (settings.name == '/addFunds') {
            // final args = settings.arguments as addFundsArgs;
            return MaterialPageRoute(builder: (context) {
              return FundingPage(title: 'Funding Page');
            });
          }
        },
        home: Scaffold(
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            onTap: onTabTapped, // new
            currentIndex:
                _currentIndex, // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Groups',
              )
            ],
          ),
        ));
  }
}

class RequestState {
  const RequestState();
}

class RequestInitial extends RequestState {}

class RequestLoadInProgress extends RequestState {}

class RequestLoadSuccess extends RequestState {
  const RequestLoadSuccess(this.body);
  final String body;
}

class RequestLoadFailure extends RequestState {}
