import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/ads/ads_model.dart';
import 'package:tabela_treino/screens/musclesList_screen.dart';

class ExerciseDetail extends StatefulWidget {
  final String authId;
  final String treinoId;
  final String exeId;
  final DocumentSnapshot exercise;
  final bool addMode;
  final int qntdExe;
  final int set;
  final String titleId;
  final double padding;
  ExerciseDetail(this.exercise, this.set, this.addMode, this.qntdExe,
      this.treinoId, this.exeId, this.authId, this.titleId, this.padding);

  @override
  _ExerciseDetailState createState() => _ExerciseDetailState(exercise, set,
      addMode, qntdExe, treinoId, exeId, authId, titleId, padding);
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  final String authId;
  final DocumentSnapshot exercise;
  final bool addMode;
  final int qntdExe;
  final String treinoId;
  final String exeId;
  final int set;
  final String titleId;
  final double padding;
  _ExerciseDetailState(this.exercise, this.set, this.addMode, this.qntdExe,
      this.treinoId, this.exeId, this.authId, this.titleId, this.padding);

  //adicionar a planilha

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _seriesController = TextEditingController();
  final _repsController = TextEditingController();
  final _pesoController = TextEditingController();

  //CREATE INTERSTITIAL
  InterstitialAd interstitialAdMuscle;
  bool _isInterstitialAdReady;
  bool _isInterstitialAdShow = false;
  int adClick = 0;

  // ignore: unused_field
  AdmobBanner _admobBanner;
  final _nativeAdController = NativeAdmobController();
  double _height = 0;
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();

    _isInterstitialAdReady = false;

    interstitialAdMuscle = InterstitialAd(
      adUnitId: interstitialAdUnitId(),
      listener: _onInterstitialAdEvent,
    );
    _loadInterstitialAd();

    print(padding.toString() + " home tab pad");
    _admobBanner = AdmobBanner(
      adUnitId: bannerAdUnitId(),
      adSize: AdmobBannerSize.BANNER,
      listener: (e, e2) {
        if (e == AdmobAdEvent.loaded) {
          print("padding home tab 2 = loaded");
        }
        if (e == AdmobAdEvent.closed) {
          _admobBanner = null;
        }
      },
    );
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
  void dispose() {
    _subscription.cancel();
    _nativeAdController.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    interstitialAdMuscle.load();
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        if (set == 0) {
          _addExercicio(
              muscleId: exercise["muscleId"],
              title: exercise["title"],
              video: exercise["video"],
              planilhaId: treinoId,
              userId: authId,
              id: exercise.id,
              obs: _observTextController.text.isNotEmpty
                  ? _observTextController.text
                  : "",
              series: _seriesController.text,
              reps: _repsController.text,
              carga: int.parse(_pesoController.text),
              pos: qntdExe);
        } else if (set == 1) {
          _addBiSetExercicio(
              muscleId: exercise["muscleId"],
              title: exercise["title"],
              video: exercise["video"],
              planilhaId: treinoId,
              exeId: exeId,
              userId: authId,
              id: exercise.id,
              obs: _observTextController.text.isNotEmpty
                  ? _observTextController.text
                  : "",
              series: _seriesController.text,
              reps: _repsController.text,
              carga: int.parse(_pesoController.text),
              pos: qntdExe);
        }
        break;
      default:
      // do nothing
    }
  }

  Future<void> _alertNextExeAdd(BuildContext context, String idExe) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Color(0xff313131),
            title: Text(
              'Agora você deve escolher o segundo exercício do Bi-Set',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 20,
                  height: 1.1),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "GothamBook",
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MuscleListScreen(addMode, set,
                          treinoId, idExe, qntdExe, authId, titleId, padding)));
                },
              )
            ],
          );
        });
  }

  // ignore: missing_return
  Future<Null> _addExercicio(
      {@required String muscleId,
      @required String title,
      @required String video,
      @required String planilhaId,
      @required userId,
      @required String id,
      String obs,
      String reps,
      String series,
      int carga,
      int pos}) {
    if (pos == null) pos = 1;
    setState(() {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("planilha")
          .doc(planilhaId)
          .collection("exercícios")
          .add({
        "muscleId": muscleId,
        "title": title,
        "video": video,
        "id": id,
        "set_type": "uniset",
        "obs": obs,
        "series": series,
        "reps": reps,
        "peso": carga,
        "pos": pos + 1
      }).then((value) {
        print("deu certo");
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((_) {
        print("deu errado");
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text("Exercício não adicionado, tentar novamente mais tarde!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      });
    });
  }

  // ignore: missing_return
  Future<Null> _addBiSetExercicio(
      {@required String muscleId,
      @required String title,
      @required String video,
      @required String planilhaId,
      @required String exeId,
      @required userId,
      @required String id,
      String obs,
      String reps,
      String series,
      int carga,
      int pos}) async {
    String idExe;
    if (pos == null) pos = 1;
    if (exeId == null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("planilha")
          .doc(planilhaId)
          .collection("exercícios")
          .add({
        "set_type": "biset",
        "pos": pos + 1,
        "title1": title,
        "title2": ""
      }).then((value) {
        idExe = value.id;
        value.collection("sets").add({
          "muscleId": muscleId,
          "title": title,
          "video": video,
          "id": id,
          "obs": obs,
          "series": series,
          "reps": reps,
          "peso": carga,
        }).then((value) {
          _alertNextExeAdd(context, idExe);
        });
      });
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("planilha")
          .doc(planilhaId)
          .collection("exercícios")
          .doc(exeId)
          .get()
          .then((value) async {
        Map<String, dynamic> exeData = {
          "set_type": "biset",
          "pos": value["pos"],
          "title1": value["title1"],
          "title2": title
        };
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("planilha")
            .doc(planilhaId)
            .collection("exercícios")
            .doc(exeId)
            .update(exeData)
            .then((value) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("planilha")
              .doc(planilhaId)
              .collection("exercícios")
              .doc(exeId)
              .collection("sets")
              .add({
            "muscleId": muscleId,
            "title": title,
            "video": video,
            "id": id,
            "obs": obs,
            "series": series,
            "reps": reps,
            "peso": carga,
          }).then((value) {
            Navigator.popUntil(
                context, ModalRoute.withName('/treino')); //arrumar aq
          });
        });
      });
    }
  }

  /*
  Future<void> _notifyAddMore(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            backgroundColor: Color(0xff313131),
            title: Text(
              'Deseja adicionar mais\num exercício?',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 20,
                  height: 1.1),
            ),
            actions: <Widget>[
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: TextButton(
                  child: Text('NÃO',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: TextButton(
                  child: Text('SIM',
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        });
  }*/

  double _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
        loadingProgress.expectedTotalBytes);
  }

  final _observTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            "${exercise["title"].toString().toUpperCase()}",
            style: TextStyle(fontFamily: "GothamBold"),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: [
            addMode
                ? IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.black.withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        _seriesController.clear();
                        _repsController.clear();
                        _pesoController.clear();
                        _observTextController.clear();
                      });
                    })
                : Container(),
          ],
        ),
        backgroundColor: Color(0xff313131),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Execução",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Image.network(exercise["video"], loadingBuilder:
                      (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Carregando exercício: ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: "Gotham"),
                            ),
                            Text(
                              "${_calculateProgress(loadingProgress).toStringAsFixed(2)}%",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 20,
                                  fontFamily: "Gotham"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.amber,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            value: (_calculateProgress(loadingProgress) * 0.01),
                          ),
                        ),
                      ],
                    ));
                  }, fit: BoxFit.contain),
                ),
              ),
              Divider(
                height: 5,
                thickness: 2,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.23,
                      child: TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(signed: false),
                        controller: _seriesController,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(
                            labelText: "Séries",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey[300].withOpacity(0.3))),
                        // ignore: missing_return
                        validator: (text) {
                          if (text.isEmpty) return "Vazio";
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.23,
                      child: TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(signed: false),
                        controller: _repsController,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(
                            labelText: "Repetições",
                            labelStyle:
                                TextStyle(color: Colors.white, fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey[300].withOpacity(0.3))),
                        // ignore: missing_return
                        validator: (text) {
                          if (text.isEmpty) return "Vazio";
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.23,
                      child: TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(signed: false),
                        controller: _pesoController,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(
                            labelText: "Carga",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: "Kg",
                            hintStyle: TextStyle(
                                color: Colors.grey[300].withOpacity(0.3))),
                        // ignore: missing_return
                        validator: (text) {
                          if (text.isEmpty) return "Vazio";
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: TextField(
                  maxLength: 150,
                  maxLines: null,
                  enableInteractiveSelection: true,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  decoration: InputDecoration(
                    labelText: "Observação adicional",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  controller: _observTextController,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.3),
                height: 50,
                child: InkWell(
                  onTap: () async {
                    if (_formKey.currentState.validate()) {
                      String cargaTemp = _pesoController.text
                          .replaceAll(new RegExp(r'[^0-9]'), '');
                      int cargaTempInt = int.parse(cargaTemp);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool adSeen = prefs.getBool('ad_seen');

                      if (_isInterstitialAdReady &&
                          !_isInterstitialAdShow &&
                          !adSeen) {
                        await prefs.setBool('ad_seen', true);
                        interstitialAdMuscle.show();
                        _isInterstitialAdShow = true;
                      } else {
                        await prefs.setBool('ad_seen', false);
                        if (set == 0) {
                          _addExercicio(
                              muscleId: exercise["muscleId"],
                              title: exercise["title"],
                              video: exercise["video"],
                              planilhaId: treinoId,
                              userId: authId,
                              id: exercise.id,
                              obs: _observTextController.text.isNotEmpty
                                  ? _observTextController.text
                                  : "",
                              series: _seriesController.text,
                              reps: _repsController.text,
                              carga: cargaTempInt,
                              pos: qntdExe);
                        } else if (set == 1) {
                          _addBiSetExercicio(
                              muscleId: exercise["muscleId"],
                              title: exercise["title"],
                              video: exercise["video"],
                              planilhaId: treinoId,
                              exeId: exeId,
                              userId: authId,
                              id: exercise.id,
                              obs: _observTextController.text.isNotEmpty
                                  ? _observTextController.text
                                  : "",
                              series: _seriesController.text,
                              reps: _repsController.text,
                              carga: cargaTempInt,
                              pos: qntdExe);
                        }
                      }
                    }
                  },
                  child: Center(
                    child: Text(
                      set == 0
                          ? "Adicionar"
                          : exeId == null
                              ? "Adicionar primeiro exercício"
                              : "Adicionar segundo exercício",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamBook",
                          fontSize: set == 0 ? 18 : 14),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 6,
                          blurRadius: 8,
                          offset: Offset(0, 3))
                    ]),
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
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
}
