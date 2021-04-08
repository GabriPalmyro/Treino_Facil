import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/ads/ads_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/screens/musclesList_screen.dart';
import 'package:tabela_treino/screens/tokenPersonal_screen.dart';
import 'package:tabela_treino/screens/tokenUser_screen.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import 'dart:async';

// ignore: must_be_immutable
class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  AdmobBanner _admobBanner;

  double _height = 0;

  final _nativeAdController = NativeAdmobController();
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();

    _admobBanner = AdmobBanner(
      adUnitId: bannerAdUnitId(),
      adSize: AdmobBannerSize.BANNER,
      listener: (e, e2) {
        if (e == AdmobAdEvent.loaded) {}
        if (e == AdmobAdEvent.closed) {
          _admobBanner = null;
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _nativeAdController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      if (model.userData["name"] == null)
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
      return Scaffold(
          drawer: CustomDrawer(0),
          appBar: AppBar(
            toolbarHeight: 70,
            shadowColor: Colors.grey[850],
            elevation: 25,
            centerTitle: true,
            title: Text(
              "Treino Fácil",
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
                                    fontSize: 22,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MuscleListScreen(false, 0, null,
                          null, 0, model.firebaseUser.uid, null)));
                },
                child: Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.only(top: 15, left: 20),
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(30.0)),
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(2, 5), // changes position of shadow
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
                              fontStyle: FontStyle.italic,
                              fontSize: 25),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        AutoSizeText(
                          "Veja a execução e os movimentos da nossa lista de exercícios",
                          maxLines: 3,
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontFamily: "Gotham",
                              fontStyle: FontStyle.italic,
                              fontSize: 20),
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: _height,
                child: NativeAdmob(
                  adUnitID: nativeAdUnitId(),
                  loading: Container(),
                  error: Text("Failed to load the ad"),
                  controller: _nativeAdController,
                  type: NativeAdmobType.banner,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (model.userData["personal_type"]) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TokenPersonalScreen(model)));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TokenScreen(model)));
                  }
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 10),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(30.0)),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(2, 5), // changes position of shadow
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
                                  fontStyle: FontStyle.italic,
                                  fontSize: 25),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Veja pedidos de conexão ou corte conexão com seu Personal Trainer",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontFamily: "Gotham",
                                  fontStyle: FontStyle.italic,
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
                                  fontStyle: FontStyle.italic,
                                  fontSize: 25),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Adicione, remova ou edite a planilha de seus alunos",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontFamily: "Gotham",
                                  fontStyle: FontStyle.italic,
                                  fontSize: 22),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ));
    });
  }
}
