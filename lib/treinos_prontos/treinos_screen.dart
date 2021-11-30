import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:tabela_treino/ads/ads_model.dart';
import 'package:tabela_treino/treinos_prontos/visualizarExe.dart';

class TreinosProntos extends StatefulWidget {
  final String level;
  final String idLevel;
  final String idPlanilha;
  final String planilhaTitle;
  TreinosProntos(this.level, this.idLevel, this.idPlanilha, this.planilhaTitle);

  @override
  _TreinosProntosState createState() => _TreinosProntosState();
}

class _TreinosProntosState extends State<TreinosProntos> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.planilhaTitle,
          minFontSize: 24,
          style: TextStyle(fontFamily: "Gotham", color: Colors.grey[900]),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xff313131),
      body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("tfaceis")
              .doc(widget.idLevel)
              .collection("masculino")
              .doc(widget.idPlanilha)
              .collection("exercicios")
              .orderBy('pos')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 24,
                    ),
                    Text("Carregando exercícios...",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: "GothamBook",
                            color: Theme.of(context).primaryColor))
                  ],
                ),
              );
            } else if (snapshot.data.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text("Planilha vazia ou não existe",
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Gotham",
                          color: Theme.of(context).primaryColor)),
                ),
              );
            } else
              return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return exercicioContainerUni(context, snapshot, index);
                  });
          }),
    );
  }

  InkWell exercicioContainerUni(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return InkWell(
      onTap: () async {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => VisualizarExeP(
                snapshot.data.docs[index]["video"],
                snapshot.data.docs[index]["series"],
                snapshot.data.docs[index]["reps"]));
      },
      splashColor: Colors.grey[900],
      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
      child: Container(
        margin: EdgeInsets.only(
            top: index == 0 ? 20 : 10,
            bottom: index + 1 == snapshot.data.docs.length ? 65 : 10,
            left: 20,
            right: 20),
        height: 150,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(12.0)),
          color: Theme.of(context).primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 4,
              blurRadius: 4,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
                left: 15,
                top: 15,
                child: Text(
                  (index + 1).toString() + 'º',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "GothamBold",
                  ),
                )),
            Positioned(
                right: 10,
                top: 10,
                child: Icon(
                  Icons.remove_red_eye,
                  size: 18,
                  color: Colors.black.withOpacity(0.6),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: AutoSizeText(
                      snapshot.data.docs[index]["title"]
                          .toString()
                          .toUpperCase(),
                      maxLines: 3,
                      style: TextStyle(fontSize: 20, fontFamily: "GothamBold"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("Séries",
                              style: TextStyle(
                                  fontSize: 22, fontFamily: "Gotham")),
                          SizedBox(
                            height: 5,
                          ),
                          Text(snapshot.data.docs[index]["series"],
                              style: TextStyle(
                                  fontSize: 20, fontFamily: "GothamBook")),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Repetições",
                              style: TextStyle(
                                  fontSize: 22, fontFamily: "Gotham")),
                          SizedBox(
                            height: 5,
                          ),
                          Text(snapshot.data.docs[index]["reps"],
                              style: TextStyle(
                                  fontSize: 20, fontFamily: "GothamBook")),
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
    );
  }
}
