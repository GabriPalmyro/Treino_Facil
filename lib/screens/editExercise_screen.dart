import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EditExercise extends StatefulWidget {
  final String authId;
  final String treinoId;
  final String title;
  final int set_type;
  final QueryDocumentSnapshot exercise;
  EditExercise(
      this.treinoId, this.title, this.exercise, this.set_type, this.authId);

  @override
  _EditExerciseState createState() =>
      _EditExerciseState(treinoId, exercise, title, set_type, authId);
}

class _EditExerciseState extends State<EditExercise> {
  final String authId;
  final String treinoId;
  final String title;
  final int set_type;
  final QueryDocumentSnapshot exercise;
  _EditExerciseState(
      this.treinoId, this.exercise, this.title, this.set_type, this.authId);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Color _color1 = Color(0xfffcd103);
  Color _color2 = Color(0xFFffdb30);
  Color _color3 = Color(0xffffe87a);

  int _series;
  int _reps;
  int _peso;

  @override
  void initState() {
    super.initState();
    _series = int.parse(exercise["series"]);
    _reps = int.parse(exercise["reps"]);
    _peso = exercise["peso"];
  }

  _onRefresh() {
    setState(() {
      _series = int.parse(exercise["series"]);
      _reps = int.parse(exercise["reps"]);
      _peso = exercise["peso"];
    });
  }

  _updateExe() async {
    Map<String, dynamic> exe = {
      "title": exercise["title"],
      "description": exercise["description"],
      "muscleId": exercise["muscleId"],
      "obs": exercise["obs"],
      "id": exercise["id"],
      "peso": _peso,
      "series": _series.toString(),
      "reps": _reps.toString(),
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "EDITAR EXERCÍCIO",
          style: TextStyle(fontSize: 22, fontFamily: "GothamBold"),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.check_box),
              color: Colors.green,
              iconSize: 30,
              onPressed: () {
                _updateExe();
              })
        ],
      ),
      backgroundColor: Color(0xff313131),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: AutoSizeText(
              "${exercise["title"]}: ",
              maxFontSize: 15,
              style: TextStyle(
                  color: Colors.white, fontFamily: "Gotham", fontSize: 25),
              textAlign: TextAlign.start,
            ),
          ),
          Divider(
            color: Colors.white,
          ),
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
                      setState(() {
                        _series = _series - 10;
                        print(_series.isEven);
                      });
                    },
                    child: Text("-10")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color2,
                    onPressed: () {
                      setState(() {
                        _series = _series - 5;
                      });
                    },
                    child: Text("-5")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color3,
                    onPressed: () {
                      setState(() {
                        _series = _series - 1;
                      });
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
                      setState(() {
                        _reps = _reps - 10;
                      });
                    },
                    child: Text("-10")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color2,
                    onPressed: () {
                      setState(() {
                        _reps = _reps - 5;
                      });
                    },
                    child: Text("-5")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color3,
                    onPressed: () {
                      setState(() {
                        _reps = _reps - 1;
                      });
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
                      setState(() {});
                      _reps = _reps + 5;
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
                      setState(() {});
                      _peso = _peso - 10;
                    },
                    child: Text("-10")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color2,
                    onPressed: () {
                      setState(() {
                        _peso = _peso - 5;
                      });
                    },
                    child: Text("-5")),
                SizedBox(
                  width: 5,
                ),
                FlatButton(
                    minWidth: 5,
                    color: _color3,
                    onPressed: () {
                      setState(() {
                        _peso = _peso - 1;
                      });
                    },
                    child: Text("-1")),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "$_peso",
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
                        _peso = _peso + 1;
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
                        _peso = _peso + 5;
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
                        _peso = _peso + 10;
                      });
                    },
                    child: Text("+10")),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          // ignore: deprecated_member_use
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 20,
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Theme.of(context).primaryColor.withOpacity(0.5);
                    return null; // Use the component's default.
                  },
                )),
                child: Text(
                  'REFRESH',
                  style: TextStyle(color: Colors.amber, fontSize: 20),
                ),
                onPressed: () {
                  _onRefresh();
                },
              ),
              SizedBox(
                width: 20,
              ), // ignore: deprecated_member_use
            ],
          ),
        ],
      ),
    );
  }
}
