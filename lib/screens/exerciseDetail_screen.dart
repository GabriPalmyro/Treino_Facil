import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
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

  ExerciseDetail(this.exercise, this.set, this.addMode, this.qntdExe,
      this.treinoId, this.exeId, this.authId);

  @override
  _ExerciseDetailState createState() => _ExerciseDetailState(
      exercise, set, addMode, qntdExe, treinoId, exeId, authId);
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  final String authId;
  final DocumentSnapshot exercise;
  final bool addMode;
  final int qntdExe;
  final String treinoId;
  final String exeId;
  final int set;

  _ExerciseDetailState(this.exercise, this.set, this.addMode, this.qntdExe,
      this.treinoId, this.exeId, this.authId);

  //adicionar a planilha

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Color _color1 = Color(0xfffcd103);
  Color _color2 = Color(0xFFffdb30);
  Color _color3 = Color(0xffffe87a);

  int _series = 4;
  int _reps = 12;
  int _carga = 25;

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
              series: _series.toString(),
              reps: _reps.toString(),
              carga: _carga,
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
              series: _series.toString(),
              reps: _reps.toString(),
              carga: _carga,
              pos: qntdExe);
        }
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
    print("$pos posição");
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
        print("EXERCICIO ADICIONADO");
        Navigator.pop(context);
        _notifyAddMore(context);
      }).catchError((_) {
        print("EXERCICIO NÃO ADICIONADO");
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
    print("$pos posição");
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
          print("EXERCICIO 1 ADICIONADO");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MuscleListScreen(
                  addMode, set, treinoId, idExe, qntdExe, authId)));
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
            print("EXERCICIO 2 ADICIONADO");
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      });
    }
  }

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
  }

  String _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
            loadingProgress.expectedTotalBytes)
        .toStringAsFixed(2);
  }

  final _observTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ? Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _series = 4;
                            _reps = 12;
                            _carga = 25;
                            _observTextController.clear();
                          });
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.grey[850],
                        ),
                        onPressed: () {
                          if (_isInterstitialAdReady &&
                              !_isInterstitialAdShow) {
                            interstitialAdMuscle.show();
                            _isInterstitialAdShow = true;
                          } else {
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
                                  series: _series.toString(),
                                  reps: _reps.toString(),
                                  carga: _carga,
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
                                  series: _series.toString(),
                                  reps: _reps.toString(),
                                  carga: _carga,
                                  pos: qntdExe);
                            }
                          }
                        }),
                  ],
                )
              : Container(),
        ],
      ),
      backgroundColor: Color(0xff313131),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Execução",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Gotham",
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AspectRatio(
              aspectRatio: 1.5,
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
                          "${_calculateProgress(loadingProgress)}%",
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
                      child: LinearProgressIndicator(),
                    ),
                  ],
                ));
              }, fit: BoxFit.contain),
            ),
          ),
          Divider(
            height: 5,
            thickness: 3,
            color: Theme.of(context).primaryColor,
          ),
          //addinfos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Séries",
                    style: TextStyle(
                        color: _color1, fontFamily: "GothamBook", fontSize: 20),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                          minWidth: 5,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (_series - 10 >= 1) {
                              setState(() {
                                _series = _series - 10;
                              });
                            }
                          },
                          child: Text("-10")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color2,
                          onPressed: () {
                            if (_series - 5 >= 1) {
                              setState(() {
                                _series = _series - 5;
                              });
                            }
                          },
                          child: Text("-5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color3,
                          onPressed: () {
                            if (_series - 1 >= 1) {
                              setState(() {
                                _series = _series - 1;
                              });
                            }
                          },
                          child: Text("-1")),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "$_series",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontFamily: "GothamBold"),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: Color(0xffffe87a),
                          onPressed: () {
                            setState(() {
                              _series = _series + 1;
                            });
                          },
                          child: Text("+1")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: Color(0xFFffdb30),
                          onPressed: () {
                            setState(() {
                              _series = _series + 5;
                            });
                          },
                          child: Text("+5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            setState(() {
                              _series = _series + 10;
                            });
                          },
                          child: Text("+10")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Repetições",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: "GothamBook",
                        fontSize: 20),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                          minWidth: 5,
                          color: _color1,
                          onPressed: () {
                            if (_reps - 10 >= 1) {
                              setState(() {
                                _reps = _reps - 10;
                              });
                            }
                          },
                          child: Text("-10")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color2,
                          onPressed: () {
                            if (_reps - 5 >= 1) {
                              setState(() {
                                _reps = _reps - 5;
                              });
                            }
                          },
                          child: Text("-5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color3,
                          onPressed: () {
                            if (_reps - 1 >= 1) {
                              setState(() {
                                _reps = _reps - 1;
                              });
                            }
                          },
                          child: Text("-1")),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "$_reps",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontFamily: "GothamBold"),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color3,
                          onPressed: () {
                            setState(() {
                              _reps = _reps + 1;
                            });
                          },
                          child: Text("+1")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color2,
                          onPressed: () {
                            setState(() {
                              _reps = _reps + 5;
                            });
                          },
                          child: Text("+5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color1,
                          onPressed: () {
                            setState(() {
                              _reps = _reps + 10;
                            });
                          },
                          child: Text("+10")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Carga",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: "GothamBook",
                        fontSize: 20),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                          minWidth: 5,
                          color: _color1,
                          onPressed: () {
                            if (_carga - 10 >= 0) {
                              setState(() {
                                _carga = _carga - 10;
                              });
                            }
                          },
                          child: Text("-10")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color2,
                          onPressed: () {
                            if (_carga - 5 >= 0) {
                              setState(() {
                                _carga = _carga - 5;
                              });
                            }
                          },
                          child: Text("-5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color3,
                          onPressed: () {
                            if (_carga - 1 >= 0) {
                              setState(() {
                                _carga = _carga - 1;
                              });
                            }
                          },
                          child: Text("-1")),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "$_carga",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontFamily: "GothamBold"),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color3,
                          onPressed: () {
                            setState(() {
                              _carga = _carga + 1;
                            });
                          },
                          child: Text("+1")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color2,
                          onPressed: () {
                            setState(() {
                              _carga = _carga + 5;
                            });
                          },
                          child: Text("+5")),
                      SizedBox(
                        width: 5,
                      ),
                      FlatButton(
                          minWidth: 5,
                          color: _color1,
                          onPressed: () {
                            setState(() {
                              _carga = _carga + 10;
                            });
                          },
                          child: Text("+10")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              maxLength: 150,
              maxLines: 3,
              enableInteractiveSelection: true,
              style: TextStyle(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[400].withOpacity(0.2)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.6)),
                  ),
                  hintText: "Observação adicional ao exercício",
                  hintStyle:
                      TextStyle(color: Colors.grey[300].withOpacity(0.3))),
              controller: _observTextController,
            ),
          ),
          SizedBox(
            height: 70,
          )
        ],
      ),
    );
  }
}
