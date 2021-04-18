import 'dart:ui';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'dart:async';

import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:tabela_treino/ads/ads_model.dart';

class EditExercise extends StatefulWidget {
  final String authId;
  final String treinoId;
  final String title;
  // ignore: non_constant_identifier_names
  final int set_type;
  final QueryDocumentSnapshot exercise;
  final double padding;
  EditExercise(this.treinoId, this.title, this.exercise, this.set_type,
      this.authId, this.padding);

  @override
  _EditExerciseState createState() =>
      _EditExerciseState(treinoId, exercise, title, set_type, authId, padding);
}

class _EditExerciseState extends State<EditExercise> {
  final String authId;
  final String treinoId;
  final String title;
  // ignore: non_constant_identifier_names
  final int set_type;
  final QueryDocumentSnapshot exercise;
  final double padding;
  _EditExerciseState(this.treinoId, this.exercise, this.title, this.set_type,
      this.authId, this.padding);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _seriesController = TextEditingController();
  final _repsController = TextEditingController();
  final _pesoController = TextEditingController();
  final _observTextController = TextEditingController();

  //nativa BANNER SCRIPT
  // ignore: unused_field
  AdmobBanner _admobBanner;
  final _nativeAdController = NativeAdmobController();
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();
    _seriesController.text = exercise["series"];
    _repsController.text = exercise["reps"];
    _pesoController.text = exercise["peso"].toString();
    _observTextController.text = exercise["obs"];
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
        break;

      case AdLoadState.loadCompleted:
        break;

      default:
        break;
    }
  }

  _onRefresh() {
    setState(() {
      _seriesController.text = exercise["series"];
      _repsController.text = exercise["reps"];
      _pesoController.text = exercise["peso"].toString();
      _observTextController.text = exercise["obs"];
    });
  }

  _updateExe() async {
    String cargaTemp =
        _pesoController.text.replaceAll(new RegExp(r'[^0-9]'), '');
    int cargaTempInt = int.parse(cargaTemp);
    Map<String, dynamic> exe = {
      "title": exercise["title"],
      "description": exercise["description"],
      "muscleId": exercise["muscleId"],
      "obs": _observTextController.text,
      "id": exercise["id"],
      "peso": cargaTempInt,
      "series": _seriesController.text,
      "reps": _repsController.text,
      "pos": exercise["pos"]
    };
    if (set_type == 1) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(authId)
          .collection("planilha")
          .doc(treinoId)
          .collection("exercícios")
          .doc(exercise.id)
          .update(exe)
          .then((value) {
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          padding: EdgeInsets.only(bottom: 60),
          content: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Exercício atualizado com sucesso"),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ));
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      });
    } else if (set_type == 2) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Editar Exercício",
            style: TextStyle(fontSize: 22, fontFamily: "GothamBold"),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.grey[850],
                ),
                onPressed: () {
                  _onRefresh();
                }),
          ],
        ),
        backgroundColor: Color(0xff313131),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    exercise["title"] + ":",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "GothamBook",
                        fontSize: 24),
                  )),
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
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      _updateExe();
                    }
                  },
                  child: Center(
                    child: Text(
                      "Editar exercício",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamBook",
                          fontSize: 14),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 2,
                          offset: Offset(0, 4))
                    ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                height: 300,
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
