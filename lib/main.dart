import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tabela_treino/screens/login_screen.dart';
import 'package:tabela_treino/tabs/home_tab.dart';

import 'ads/ads_model.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  //SystemChrome.setEnabledSystemUIOverlays([]);
  FirebaseAdMob.instance
      .initialize(appId: "ca-app-pub-7831186229252322~9095625736");

  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

FirebaseAuth _auth = FirebaseAuth.instance;
bool _payApp = false;

class _MyAppState extends State<MyApp> {
  void displayBanner() {
    myBanner
      ..load()
      ..show(
        anchorOffset: -2,
        anchorType: AnchorType.bottom,
      ).then((value) {
        print("anuncio mostrado");
      }).catchError((_) {
        print("ERRO $_");
      });
  } 

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    myBanner?.dispose();
    myInterstitial?.dispose();
    super.dispose();
  }

  Future<bool> _getUserAppState() async {
    bool payApp;
    ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      payApp = model.userData["payApp"];
      return;
    });
    return payApp;
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-7831186229252322~9095625736");

    _getUserAppState().then((value) {
      print(value);
      setState(() {
        if (value == true || value == false) _payApp = value;
      });
      print("ESTADO DO USUARIO -- $_payApp");
      if (!_payApp) {
        startBanner();
        displayBanner();
        print("COMPRE NOSSO APP PORRA");
      } else if (_payApp) {
        print("OBRIGADO POR COMPRAR NOSSO APP");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
        model: UserModel(),
        child: MaterialApp(
          title: 'Treino Fácil',
          theme: ThemeData(
            primarySwatch: Colors.amber, //descobrir cor boa
            primaryColor: const Color(0xffffd200),
          ),
          debugShowCheckedModeBanner: false,
          home: _auth.currentUser == null ? LoginScreen() : HomeTab(),
        ));
  }
}
