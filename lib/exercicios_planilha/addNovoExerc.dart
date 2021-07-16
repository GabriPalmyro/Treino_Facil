import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/ads/ads_model.dart';

class AddNovoExercUniSet extends StatefulWidget {
  final String authId;
  final String treinoId;
  final String exeId;
  final DocumentSnapshot exercise;
  final bool addMode;
  final int qntdExe;
  final int set;
  final String titleId;
  final double padding;
  AddNovoExercUniSet(this.exercise, this.set, this.addMode, this.qntdExe,
      this.treinoId, this.exeId, this.authId, this.titleId, this.padding);

  @override
  _AddNovoExercUniSetState createState() => _AddNovoExercUniSetState(exercise,
      set, addMode, qntdExe, treinoId, exeId, authId, titleId, padding);
}

class _AddNovoExercUniSetState extends State<AddNovoExercUniSet> {
  final String authId;
  final DocumentSnapshot exercise;
  final bool addMode;
  final int qntdExe;
  final String treinoId;
  final String exeId;
  final int set;
  final String titleId;
  final double padding;
  _AddNovoExercUniSetState(this.exercise, this.set, this.addMode, this.qntdExe,
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

  void _loadInterstitialAd() {
    interstitialAdMuscle.load();
  }

  @override
  void initState() {
    super.initState();
    _isInterstitialAdReady = false;

    interstitialAdMuscle = InterstitialAd(
      adUnitId: interstitialAdUnitId(),
      listener: _onInterstitialAdEvent,
    );
    _loadInterstitialAd();
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
        break;
      default:
      // do nothing
    }
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

  double _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
        loadingProgress.expectedTotalBytes);
  }

  final _observTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff313131),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_downward_sharp,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              AutoSizeText(
                "${exercise["title"].toString().toUpperCase()}",
                style: TextStyle(
                    fontFamily: "GothamBold",
                    color: Colors.white,
                    fontSize: 24),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
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
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
              SizedBox(
                height: 12,
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
                      }
                    }
                  },
                  child: Center(
                    child: Text(
                      "Adicionar",
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
                          spreadRadius: 5,
                          blurRadius: 8,
                          offset: Offset(0, 3))
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
