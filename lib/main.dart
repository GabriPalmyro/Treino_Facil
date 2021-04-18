import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tabela_treino/screens/login_screen.dart';
import 'package:tabela_treino/tabs/home_tab.dart';
import 'package:tabela_treino/tiles/intro_tile.dart';

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
bool _payApp;
double padding = 0;

class _MyAppState extends State<MyApp> {
  void displayBanner() {
    myBanner
      ..load()
      ..show(
        anchorOffset: -2,
        anchorType: AnchorType.bottom,
      ).then((value) {
        print("anuncio mostrado");
        padding = 0;
        print(padding);
      }).catchError((_) {
        print("ERRO $_");
        padding = 0;
        print(padding);
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
    bool payApp = false;
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
            home: new Splash()
            /*_auth.currentUser == null
              ? LoginScreen(padding)
              : HomeTab(padding),*/
            ));
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool seen =
        prefs.getBool('seen'); //checa se o usuario já viu a intro screen

    if (prefs.getBool('ad_seen') == null) prefs.setBool('ad_seen', false);

    if (seen == null) {
      seen = false;
      await prefs.setBool('seen', false);
    } //se a variavel n exister ele seta ela como falsa

    if (seen) {
      // caso ele já tenha visto

      /*String dateSeenS = prefs
          .getString('seen_date'); // procurar pela data da ultima vez visto

      if (dateSeenS ==
          null) // se ela for igual a nula, criar ultima vez visto como atualmente
        await prefs.setString('seen_date', DateTime.now().toString());

      DateTime dateSeen = DateTime.parse(
          dateSeenS); // caso ela exista, tirar a diferença com a data atual
      int dateSeenDif = DateTime.now().difference(dateSeen).inDays;

      print(seen.toString() + " : " + dateSeenDif.toString());
      if (dateSeenDif > 7) {
        // se a dif for maior que 7 dias mostrar a introscreen de novo
        DateTime now = DateTime.now();
        await prefs.setString('seen_date', now.toString());
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => IntroScreen(padding)));
      } else {*/
      //se ela for menor que 7 dias ir ao app normalment
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) => _auth.currentUser == null
              ? LoginScreen(padding)
              : HomeTab(padding)));
      //}
    } else {
      // caso seja a primeira vez, mostrar introscreen e setar true
      await prefs.setBool('seen', true);
      //DateTime now = DateTime.now();
      //await prefs.setString('seen_date', now.toString());
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => IntroScreen(padding)));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff313131),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 180,
                ),
                SizedBox(
                  height: 50,
                ),
                CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.grey[850]),
                )
              ],
            ),
          ),
        ));
  }
}
