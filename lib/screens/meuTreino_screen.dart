import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tabela_treino/tabs/home_tab.dart';
import 'package:tabela_treino/transition/transitions.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'editExercise_screen.dart';
import 'musclesList_screen.dart';

// ignore: must_be_immutable
class TreinoScreen extends StatefulWidget {
  final double padding;
  final String authId;
  final String treinoId;
  final String title;
  TreinoScreen(this.title, this.treinoId, this.authId, this.padding);

  @override
  _TreinoScreenState createState() =>
      _TreinoScreenState(title, treinoId, authId, padding);
}

class _TreinoScreenState extends State<TreinoScreen> {
  final double padding;
  final String authId;
  final String treinoId;
  final String title;
  bool payApp = false;
  _TreinoScreenState(this.title, this.treinoId, this.authId, this.padding);

  final db = FirebaseFirestore.instance;
  int planLenght;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double padBottom = 60; //payApp
  bool _isChanging = false;

  Future<void> _deleteAlertDialog(
      BuildContext context, DocumentReference idTreino) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Color(0xff313131),
            title: Text(
              'Você tem certeza que deseja apagar esse treino?',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Gotham",
                  letterSpacing: 0.5),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.white,
                textColor: Colors.black,
                child: Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.red,
                textColor: Colors.black,
                child: Text(
                  'APAGAR',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await idTreino.delete().then((value) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomeTab(padding)),
                        (Route<dynamic> route) => false);
                  }).catchError((e) {
                    print("Erro ao apagar");
                  });
                },
              ),
            ],
          );
        });
  }

  //REORGANIZAR AO APAGAR
  _reorderAfterDelete(int index) async {
    Map<String, dynamic> exe;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .doc(treinoId)
        .collection("exercícios")
        .orderBy("pos")
        .get()
        .then((value) async {
      for (var snapshot in value.docs) {
        if (snapshot["set_type"] == "uniset") {
          exe = {
            "title": snapshot["title"],
            "id": snapshot["id"],
            "muscleId": snapshot["muscleId"],
            "obs": snapshot["obs"],
            "peso": snapshot["peso"],
            "series": snapshot["series"],
            "pos": snapshot["pos"]
          };
        } else if (snapshot["set_type"] == "biset") {
          exe = {
            "set_type": "biset",
            "pos": snapshot["pos"],
            "title1": snapshot["title1"],
            "title2": snapshot["title2"]
          };
        }
        if (exe["pos"] > (index + 1)) {
          exe["pos"] = exe["pos"] - 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .doc(snapshot.id)
              .update(exe);
        }
      }
    });
  }

  Future<void> _deleteExercise(
      BuildContext context, DocumentReference idTreino, int index) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Color(0xff313131),
            title: Text(
              'Você tem certeza que deseja apagar esse exercício?',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Gotham",
                  letterSpacing: 0.5),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.white,
                textColor: Colors.black,
                child: Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.red,
                textColor: Colors.black,
                child: Text(
                  'APAGAR',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await idTreino.delete().then((value) {
                    _reorderAfterDelete(index);
                    // ignore: deprecated_member_use
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      padding: EdgeInsets.only(bottom: 60),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Exercício apagado com sucesso"),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }).catchError((e) {
                    // ignore: deprecated_member_use
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      padding: EdgeInsets.only(bottom: 60),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Erro ao apagar exercício"),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ));
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<int> _lenghtExe() async {
    int lenght;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .doc(treinoId)
        .collection("exercícios")
        .get()
        .then((value) {
      lenght = value.docs.length;
    });
    return lenght;
  }

  Future<void> _changePositionUp(int index1, int index2) async {
    Map<String, dynamic> exe;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .doc(treinoId)
        .collection("exercícios")
        .orderBy("pos")
        .get()
        .then((value) async {
      setState(() {
        _isChanging = true;
      });
      for (var snapshot in value.docs) {
        if (snapshot["set_type"] == "uniset") {
          exe = {
            "title": snapshot["title"],
            "id": snapshot["id"],
            "muscleId": snapshot["muscleId"],
            "obs": snapshot["obs"],
            "peso": snapshot["peso"],
            "series": snapshot["series"],
            "pos": snapshot["pos"]
          };
        } else if (snapshot["set_type"] == "biset") {
          exe = {
            "set_type": "biset",
            "pos": snapshot["pos"],
            "title1": snapshot["title1"],
            "title2": snapshot["title2"]
          };
        }
        if (exe["pos"] == index1 + 1) {
          exe["pos"] = exe["pos"] - 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .doc(snapshot.id)
              .update(exe);
        } else if (exe["pos"] == index2 + 1) {
          exe["pos"] = exe["pos"] + 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .doc(snapshot.id)
              .update(exe)
              .then((value) {
            setState(() {
              _isChanging = false;
            });
          });
        }
        if (snapshot["pos"] > index1) break;
      }
    });
  }

  Future<void> _changePositionDown(int index1, int index2) async {
    Map<String, dynamic> exe;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .doc(treinoId)
        .collection("exercícios")
        .orderBy("pos")
        .get()
        .then((value) async {
      setState(() {
        _isChanging = true;
      });
      for (var snapshot in value.docs) {
        if (snapshot["set_type"] == "uniset") {
          exe = {
            "title": snapshot["title"],
            "id": snapshot["id"],
            "muscleId": snapshot["muscleId"],
            "obs": snapshot["obs"],
            "peso": snapshot["peso"],
            "series": snapshot["series"],
            "pos": snapshot["pos"]
          };
        } else if (snapshot["set_type"] == "biset") {
          exe = {
            "set_type": "biset",
            "pos": snapshot["pos"],
            "title1": snapshot["title1"],
            "title2": snapshot["title2"]
          };
        }
        if (exe["pos"] == index1 + 1) {
          exe["pos"] = exe["pos"] + 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .doc(snapshot.id)
              .update(exe);
        } else if (exe["pos"] == index2 + 1) {
          exe["pos"] = exe["pos"] - 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .doc(snapshot.id)
              .update(exe)
              .then((value) {
            setState(() {
              _isChanging = false;
            });
          });
        }
        if (snapshot["pos"] > index2) break;
      }
    });
  }

  String _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
            loadingProgress.expectedTotalBytes)
        .toStringAsFixed(2);
  }

  Future<void> _displayExerciseModalBottom(
      BuildContext context, String exerciseVideo, String obs) async {
    return showModalBottomSheet(
        backgroundColor: Colors.grey[850],
        context: context,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 500,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: ListView(
                children: [
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: Image.network(exerciseVideo, loadingBuilder:
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
                  Divider(
                    thickness: 1.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: AutoSizeText("Observação:\n" + obs,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.1,
                                color: Colors.white,
                                fontFamily: "GothamBook",
                                fontSize: 18))),
                  ),
                  SizedBox(height: 22),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          foregroundColor: Colors.white,
          elevation: 5,
          backgroundColor: Colors.grey[700],
          overlayColor: Colors.grey[850],
          marginBottom: 70,
          children: [
            SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(
                Icons.exposure_plus_1_rounded,
              ),
              label: 'Uni-Set',
              labelBackgroundColor: Colors.amber,
              onTap: () async {
                planLenght = await _lenghtExe();
                Navigator.of(context).push(MaterialPageRoute(
                    settings: RouteSettings(name: "/musculos"),
                    builder: (context) => MuscleListScreen(true, 0, treinoId,
                        null, planLenght, authId, title, padding)));
              },
            ),
            SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.exposure_plus_2_rounded),
              label: 'Bi-Set',
              labelBackgroundColor: Colors.amber,
              onTap: () async {
                planLenght = await _lenghtExe();
                Navigator.of(context).push(MaterialPageRoute(
                    settings: RouteSettings(name: "/musculos"),
                    builder: (context) => MuscleListScreen(true, 1, treinoId,
                        null, planLenght, authId, title, padding)));
              },
            ),
          ],
        ),
        appBar: AppBar(
          title: Text(
            "${title.toUpperCase()}",
            style: TextStyle(fontSize: 25, fontFamily: "GothamBold"),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          TreinoScreen(title, treinoId, authId, padding)));
                }),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              splashColor: Colors.black,
              splashRadius: 30,
              iconSize: 25,
              onPressed: () {
                DocumentReference dR = FirebaseFirestore.instance
                    .collection("users")
                    .doc(authId)
                    .collection("planilha")
                    .doc(treinoId);
                _deleteAlertDialog(context, dR);
              },
            )
          ],
        ),
        backgroundColor: Color(0xff313131),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(authId)
              .collection("planilha")
              .doc(treinoId)
              .collection("exercícios")
              .orderBy("pos")
              .get(),
          builder: (context, snapshot) {
            var doc = snapshot.data;
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else if (doc.docs.length <= 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Você não possui nenhum\nexercício ainda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "GothamThin",
                            fontSize: 20)),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Clique no botão flutuante\npara adicionar um",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "GothamThin",
                            fontSize: 20)),
                  ],
                ),
              );
            } else {
              return SafeArea(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(2),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment(-0.9, 0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                            onDismissed: (direction) {
                              var dR = db
                                  .collection("users")
                                  .doc(authId)
                                  .collection("planilha")
                                  .doc(treinoId)
                                  .collection("exercícios")
                                  .doc(snapshot.data.docs[index].id);
                              _deleteExercise(context, dR, index);
                            },
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    index != 0
                                        ? IconButton(
                                            icon: Icon(
                                                Icons.arrow_upward_rounded),
                                            splashColor: Colors.transparent,
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              if (_isChanging == false) {
                                                _changePositionUp(
                                                    index, index - 1);
                                              }
                                            })
                                        : IconButton(
                                            icon: Icon(
                                                Icons.arrow_upward_rounded),
                                            splashColor: Colors.transparent,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            onPressed: () {}),
                                    SizedBox(
                                      height: snapshot.data.docs[index]
                                                  ["set_type"] ==
                                              "biset"
                                          ? 0
                                          : 20,
                                    ),
                                    index == snapshot.data.docs.length - 1
                                        ? IconButton(
                                            icon: Icon(
                                                Icons.arrow_downward_rounded),
                                            splashColor: Colors.transparent,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            onPressed: () {})
                                        : IconButton(
                                            icon: Icon(
                                                Icons.arrow_downward_rounded),
                                            splashColor: Colors.transparent,
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              if (_isChanging == false) {
                                                _changePositionDown(
                                                    index, index + 1);
                                              }
                                            }),
                                  ],
                                ),
                                snapshot.data.docs[index]["set_type"] != "biset"
                                    ? InkWell(
                                        onTap: () {
                                          _displayExerciseModalBottom(
                                              context,
                                              snapshot.data.docs[index]
                                                  ["video"],
                                              snapshot.data.docs[index]["obs"]);
                                        },
                                        splashColor: Colors.grey[900],
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(10.0)),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          height: 150,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(20.0)),
                                            color:
                                                Theme.of(context).primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: 4,
                                                blurRadius: 2,
                                                offset: Offset(1,
                                                    5), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: _isChanging
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.grey[850]),
                                                  ),
                                                )
                                              : Stack(
                                                  children: [
                                                    Positioned(
                                                        right: -5,
                                                        child: IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.6),
                                                            ),
                                                            iconSize: 20,
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  SlideLeftRoute(
                                                                      page: EditExercise(
                                                                          treinoId,
                                                                          title,
                                                                          snapshot
                                                                              .data
                                                                              .docs[index],
                                                                          1,
                                                                          authId,
                                                                          padding)));
                                                            })),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        30),
                                                            child: AutoSizeText(
                                                              snapshot
                                                                  .data
                                                                  .docs[index]
                                                                      ["title"]
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              maxLines: 3,
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      "GothamBold"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text("Séries",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              "Gotham")),
                                                                  SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  Text(
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          "series"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              "GothamBook")),
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                      "Repetições",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              "Gotham")),
                                                                  SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  Text(
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          "reps"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              "GothamBook")),
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text("Carga",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              "Gotham")),
                                                                  SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  Text(
                                                                      "${snapshot.data.docs[index]["peso"].toString()}kg",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              "GothamBook")),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(authId)
                                                  .collection("planilha")
                                                  .doc(treinoId)
                                                  .collection("exercícios")
                                                  .doc(snapshot
                                                      .data.docs[index].id)
                                                  .collection("sets")
                                                  .get()
                                                  .then((snapshot) {
                                                _displayExerciseModalBottom(
                                                    context,
                                                    snapshot.docs[1]["video"],
                                                    snapshot.docs[1]["obs"]);
                                              });
                                            },
                                            radius: 20,
                                            borderRadius: const BorderRadius
                                                    .all(
                                                const Radius.circular(10.0)),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 10),
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        const Radius.circular(
                                                            10.0)),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    spreadRadius: 2,
                                                    blurRadius: 4,
                                                    offset: Offset(1,
                                                        5), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: _isChanging
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .grey[850]),
                                                      ),
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Positioned(
                                                            top: -15,
                                                            right: -15,
                                                            child: IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .edit_outlined,
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                                splashRadius:
                                                                    20,
                                                                iconSize: 15,
                                                                onPressed:
                                                                    () async {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(
                                                                          authId)
                                                                      .collection(
                                                                          "planilha")
                                                                      .doc(
                                                                          treinoId)
                                                                      .collection(
                                                                          "exercícios")
                                                                      .doc(snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .id)
                                                                      .collection(
                                                                          "sets")
                                                                      .get()
                                                                      .then(
                                                                          (snapshot) {
                                                                    Navigator.push(
                                                                        context,
                                                                        SlideLeftRoute(
                                                                            page: EditExercise(
                                                                                treinoId,
                                                                                title,
                                                                                snapshot.docs[1],
                                                                                2,
                                                                                authId,
                                                                                padding)));
                                                                  });
                                                                })),
                                                        Center(
                                                          child: AutoSizeText(
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                    ["title1"]
                                                                .toString()
                                                                .toUpperCase(),
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                                height: 1.1,
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    "GothamBold"),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                          Text(
                                            "+",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "GothamBold",
                                                fontSize: 30),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(authId)
                                                  .collection("planilha")
                                                  .doc(treinoId)
                                                  .collection("exercícios")
                                                  .doc(snapshot
                                                      .data.docs[index].id)
                                                  .collection("sets")
                                                  .get()
                                                  .then((snapshot) {
                                                _displayExerciseModalBottom(
                                                    context,
                                                    snapshot.docs[0]["video"],
                                                    snapshot.docs[0]["obs"]);
                                              });
                                            },
                                            radius: 20,
                                            borderRadius: const BorderRadius
                                                    .all(
                                                const Radius.circular(10.0)),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 10),
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(10.0)),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    spreadRadius: 3,
                                                    blurRadius: 7,
                                                    offset: Offset(2,
                                                        5), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: _isChanging
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .grey[850]),
                                                      ),
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Positioned(
                                                            top: -15,
                                                            right: -15,
                                                            child: IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .edit_outlined,
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                                splashRadius:
                                                                    20,
                                                                iconSize: 15,
                                                                onPressed:
                                                                    () async {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(
                                                                          authId)
                                                                      .collection(
                                                                          "planilha")
                                                                      .doc(
                                                                          treinoId)
                                                                      .collection(
                                                                          "exercícios")
                                                                      .doc(snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .id)
                                                                      .collection(
                                                                          "sets")
                                                                      .get()
                                                                      .then(
                                                                          (snapshot) {
                                                                    Navigator.push(
                                                                        context,
                                                                        SlideLeftRoute(
                                                                            page: EditExercise(
                                                                                treinoId,
                                                                                title,
                                                                                snapshot.docs[0],
                                                                                2,
                                                                                authId,
                                                                                padding)));
                                                                  });
                                                                })),
                                                        Center(
                                                          child: AutoSizeText(
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                    ["title2"]
                                                                .toString()
                                                                .toUpperCase(),
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                                height: 1.1,
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    "GothamBold"),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          index + 1 == snapshot.data.docs.length
                              ? SizedBox(
                                  height: 60,
                                )
                              : SizedBox(
                                  height: 0,
                                )
                        ],
                      );
                    }),
              );
            }
          },
        ),
      ),
    );
  }
}
