import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/transition/transitions.dart';
import 'package:tabela_treino/treinos_prontos/lista_treinos.dart';

class MenuTreinosFaceis extends StatefulWidget {
  @override
  _MenuTreinosFaceisState createState() => _MenuTreinosFaceisState();
}

class _MenuTreinosFaceisState extends State<MenuTreinosFaceis> {
  // //CREATE INTERSTITIAL
  // InterstitialAd interstitialAdMuscle;
  // bool _isInterstitialAdReady;
  // bool _isInterstitialAdShow = false;
  // int adClick = 0;

  // void _loadInterstitialAd() {
  //   interstitialAdMuscle.load();
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _isInterstitialAdReady = false;

  //   interstitialAdMuscle = InterstitialAd(
  //     adUnitId: interstitialAdUnitId(),
  //     listener: _onInterstitialAdEvent,
  //   );
  //   _loadInterstitialAd();
  // }

  // void _onInterstitialAdEvent(MobileAdEvent event) {
  //   switch (event) {
  //     case MobileAdEvent.loaded:
  //       _isInterstitialAdReady = true;
  //       break;
  //     case MobileAdEvent.failedToLoad:
  //       _isInterstitialAdReady = false;
  //       print('Failed to load an interstitial ad');
  //       break;
  //     case MobileAdEvent.closed:
  //       break;
  //     default:
  //     // do nothing
  //   }
  // }

  List level = ["owNiAMA7DN9trhiK3nDp", "RGwqW8GwUoNwnCem1KAH"];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.grey[900],
      height: height * 0.8,
      child: Column(
        children: [
          SizedBox(
            height: 14,
          ),
          Container(
            width: width * 0.6,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5)),
          ),
          SizedBox(
            height: 28,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: AutoSizeText(
              "Selecione seu nível".toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontFamily: "GothamBook", fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              //checa se o usuario já tem um nivel escolhido
              prefs.setString("levelChoice", level[0]);
              prefs.setString("levelName", 'iniciante');
              //TODO TESTAR ISSO
              Navigator.push(
                  context,
                  SlideLeftRoute(
                    page: ListaTreinosProntos(
                      sexo: "masculino",
                      level: "iniciante",
                      idLevel: level[0],
                    ),
                  )).then((value) {
                Navigator.pop(context);
              });
            },
            splashColor: Colors.grey[900],
            borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
            child: Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: decorationOpLevels(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: AutoSizeText(
                      "Iniciante",
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontFamily: "GothamBold",
                          fontSize: 25),
                    ),
                  ),
                )),
          ),
          SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              //checa se o usuario já tem um nivel escolhido
              prefs.setString("levelChoice", level[1]);
              prefs.setString("levelName", 'avançado');
              //TODO TESTAR ISSO
              Navigator.push(
                  context,
                  SlideLeftRoute(
                    page: ListaTreinosProntos(
                      sexo: "masculino",
                      level: "avançado",
                      idLevel: level[1],
                    ),
                  )).then((value) {
                Navigator.pop(context);
              });
            },
            child: Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: decorationOpLevels(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: AutoSizeText(
                      "Avançado",
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontFamily: "GothamBold",
                          fontSize: 25),
                    ),
                  ),
                )),
          ),
          SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  BoxDecoration decorationOpLevels(BuildContext context) {
    return BoxDecoration(
      borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
      color: Theme.of(context).primaryColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          spreadRadius: 3,
          blurRadius: 8,
          offset: Offset(0, 4), // changes position of shadow
        ),
      ],
    );
  }
}
