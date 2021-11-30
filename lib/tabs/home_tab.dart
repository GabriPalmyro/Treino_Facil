import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/screens/meuTreino_screen.dart';
import 'package:tabela_treino/screens/musclesList_screen.dart';
import 'package:tabela_treino/screens/tokenPersonal_screen.dart';
import 'package:tabela_treino/screens/tokenUser_screen.dart';
import 'package:tabela_treino/tabs/planilha_tab.dart';
import 'package:tabela_treino/transition/transitions.dart';
import 'package:tabela_treino/treinos_prontos/lista_treinos.dart';
import 'package:tabela_treino/treinos_prontos/menuTF_screen.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import 'dart:async';

// ignore: must_be_immutable
class HomeTab extends StatefulWidget {
  final double padding;
  HomeTab(this.padding);
  @override
  _HomeTabState createState() => _HomeTabState(padding);
}

class _HomeTabState extends State<HomeTab> {
  final double padding;
  _HomeTabState(this.padding);

  // ignore: unused_field
  AdmobBanner _admobBanner;

  double _height = 0;

  final _nativeAdController = NativeAdmobController();
  StreamSubscription _subscription;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List _planilhaList = [];
  int _currentIndex;
  bool _isLoading = true;

  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();
    getPlanSnapshots();

    //print(padding.toString() + " home tab pad");
    // _admobBanner = AdmobBanner(
    //   adUnitId: bannerAdUnitId(),
    //   adSize: AdmobBannerSize.BANNER,
    //   listener: (e, e2) {
    //     if (e == AdmobAdEvent.loaded) {
    //       print("padding home tab 2 = loaded");
    //     }
    //     if (e == AdmobAdEvent.closed) {
    //       _admobBanner = null;
    //     }
    //   },
    // );
  }

  // @override
  // void dispose() {
  //   _subscription.cancel();
  //   _nativeAdController.dispose();
  //   super.dispose();
  // }

  void _onStateChanged(AdLoadState state) {
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          _height = 0;
        });
        break;

      case AdLoadState.loadCompleted:
        setState(() {
          _height = 90;
        });
        break;

      default:
        break;
    }
  }

  getPlanSnapshots() async {
    QuerySnapshot data;
    //if (_selTypeSearch == "title") {
    data = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser.uid)
        .collection("planilha")
        .orderBy('title')
        .get();

    setState(() {
      _planilhaList = data.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      if (model.userData["name"] == null || _isLoading)
        return Center(
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
        );
      return Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: Scaffold(
            drawer: CustomDrawer(0, padding),
            appBar: AppBar(
              toolbarHeight: 70,
              shadowColor: Colors.grey[850],
              elevation: 25,
              centerTitle: true,
              title: Text(
                "Início",
                style: TextStyle(
                    color: Colors.grey[850],
                    fontFamily: "GothamBold",
                    fontSize: 30),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            backgroundColor: const Color(0xff313131),
            body: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(top: 30),
                        margin: const EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Olá, ${model.userData["name"][0].toUpperCase() + model.userData["name"].substring(1)}",
                                  style: TextStyle(
                                      fontFamily: "GothamBold",
                                      fontSize: 33,
                                      color: Theme.of(context).primaryColor),
                                ),
                                Text(
                                  "Vamos treinar?",
                                  style: TextStyle(
                                      fontFamily: "GothamThin",
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
                SizedBox(
                  height: _planilhaList.isEmpty ? 10 : 14,
                ),
                _isLoading
                    ? Container(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _planilhaList.isEmpty
                        ? Container(
                            height: 100,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        settings:
                                            RouteSettings(name: "/planilhas"),
                                        builder: (context) => PlanilhaScreen(
                                            model.firebaseUser.uid,
                                            model.userData["name"],
                                            padding)));
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Text(
                                    "Clique aqui para criar sua primeira planilha",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "GothamBook",
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 140.0,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.horizontal,
                                itemCount: _planilhaList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                settings: RouteSettings(
                                                    name: "/treino"),
                                                builder: (context) =>
                                                    TreinoScreen(
                                                        _planilhaList[index]
                                                            ["title"],
                                                        _planilhaList[index].id,
                                                        _auth.currentUser.uid,
                                                        padding)));
                                      },
                                      child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 20),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 20),
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(10.0)),
                                            color:
                                                Theme.of(context).primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: 4,
                                                blurRadius: 8,
                                                offset: Offset(0,
                                                    4), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _planilhaList[index]["title"]
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: "GothamBold"),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Divider(
                                                  color: Colors.black,
                                                  thickness: 1.5,
                                                ),
                                                Text(
                                                  _planilhaList[index]
                                                      ["description"],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: "GothamBook"),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          )));
                                }),
                          ),
                SizedBox(
                  height: 12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MuscleListScreen(false, 0, null,
                            null, 0, model.firebaseUser.uid, null, padding)));
                  },
                  child: Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding:
                          const EdgeInsets.only(top: 15, left: 20, bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            "Biblioteca de exercícios",
                            style: TextStyle(
                                color: Colors.grey[900],
                                fontFamily: "GothamBold",
                                fontSize: 25),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          AutoSizeText(
                            "Veja a execução e os movimentos da nossa lista de mais de 100 exercícios",
                            maxLines: 3,
                            style: TextStyle(
                                color: Colors.grey[900],
                                fontFamily: "GothamBook",
                                fontSize: 20),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          String levelChoice = prefs.getString('levelChoice');

                          //prefs.setString('levelName', 'Iniciante');

                          String levelName = prefs.getString(
                              'levelName'); //checa se o usuario já tem um nivel escolhido

                          print(levelName);

                          if (levelChoice == null) {
                            showModalBottomSheet(
                                backgroundColor: Colors.white,
                                context: context,
                                builder: (_) => MenuTreinosFaceis());
                          } else {
                            Navigator.push(
                                context,
                                SlideLeftRoute(
                                    page: ListaTreinosProntos(
                                  sexo: "masculino",
                                  level: levelName,
                                  idLevel: levelChoice,
                                )));
                          }
                        },
                        child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width / 1.4,
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            padding: const EdgeInsets.only(
                                top: 15, left: 20, right: 20, bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(10.0)),
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 4,
                                  blurRadius: 8,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  "Treinos Fáceis",
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "GothamBold",
                                      fontSize: 25),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                AutoSizeText(
                                  "Lista de treinos prontos para você usar no seu dia a dia",
                                  maxLines: 4,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "GothamBook",
                                      fontSize: 20),
                                ),
                              ],
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (model.userData["personal_type"]) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    TokenPersonalScreen(model, padding)));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    TokenScreen(model, padding)));
                          }
                        },
                        child: Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width / 1.3,
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(
                              top: 15, left: 20, right: 10, bottom: 30),
                          margin: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                spreadRadius: 4,
                                blurRadius: 8,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: !model.userData["personal_type"]
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Meu Personal Trainer",
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontFamily: "GothamBold",
                                          fontSize: 25),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    AutoSizeText(
                                      "Veja pedidos de conexão ou corte conexão com seu Personal Trainer",
                                      maxLines: 4,
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontFamily: "GothamBook",
                                          fontSize: 20),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Controle de alunos",
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontFamily: "GothamBold",
                                          fontSize: 25),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    AutoSizeText(
                                      "Adicione, remova ou edite a planilha de seus alunos",
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontFamily: "GothamBook",
                                          fontSize: 22),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            )),
      );
    });
  }
}
