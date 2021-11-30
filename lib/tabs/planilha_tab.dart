import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tabela_treino/ads/ads_model.dart';
import 'package:tabela_treino/screens/meuTreino_screen.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';

import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import 'dart:async';

// ignore: must_be_immutable
class PlanilhaScreen extends StatefulWidget {
  final double padding;
  final String authId;
  final String name;
  PlanilhaScreen(this.authId, this.name, this.padding);
  @override
  _PlanilhaScreenState createState() =>
      _PlanilhaScreenState(authId, name, padding);
}

class _PlanilhaScreenState extends State<PlanilhaScreen> {
  final double padding;
  String authId;
  String name;
  _PlanilhaScreenState(this.authId, this.name, this.padding);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleController = TextEditingController();
  final _descriController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> _lenghtPlan() async {
    int lenght;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .get()
        .then((value) {
      lenght = value.docs.length;
    });
    return lenght;
  }

  Future<void> _displayModalBottom(BuildContext context) async {
    return showModalBottomSheet(
        backgroundColor: Colors.grey[850],
        context: context,
        builder: (context) {
          return ListView(
            children: [
              Container(
                color: Colors.grey[850],
                height: MediaQuery.of(context).size.height * 0.4,
                margin: EdgeInsets.all(20),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Text(
                      "Criar novo treino: ",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Gotham",
                          fontSize: 25),
                      textAlign: TextAlign.start,
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    TextField(
                      enableInteractiveSelection: true,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey[400].withOpacity(0.2)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.6)),
                          ),
                          hintText: "Título do treino",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      controller: _titleController,
                    ),
                    TextField(
                      maxLength: 50,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      maxLines: 2,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey[400].withOpacity(0.2)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6)),
                        ),
                        hintText: "Descrição do treino",
                        hintStyle:
                            TextStyle(color: Colors.grey[300].withOpacity(0.3)),
                      ),
                      controller: _descriController,
                    ),
                    // ignore: deprecated_member_use
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.red.withOpacity(0.5);
                              return null; // Use the component's default.
                            },
                          )),
                          child: Text(
                            'CANCELAR',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _titleController.text = "";
                              _descriController.text = "";
                              Navigator.pop(context);
                            });
                          },
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.green.withOpacity(0.5);
                              return null; // Use the component's default.
                            },
                          )),
                          child: Text(
                            'CRIAR',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            int planLenght = await _lenghtPlan();
                            if (planLenght < 7) {
                              setState(() {
                                _createNew(
                                    title: _titleController.text,
                                    description: _descriController.text);
                                _titleController.text = "";
                                _descriController.text = "";
                                Navigator.pop(context);
                              });
                            } else {
                              Navigator.pop(context);
                              // ignore: deprecated_member_use

                              // ignore: deprecated_member_use
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                padding: EdgeInsets.only(bottom: 60),
                                content: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                      "Você atingiu o limite de criação de planilhas",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ));
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  Future<void> _displayEditModalBottom(
      BuildContext context, QueryDocumentSnapshot doc) async {
    _titleController.text = doc["title"];
    _descriController.text = doc["description"];
    return showModalBottomSheet(
        backgroundColor: Colors.grey[850],
        context: context,
        builder: (context) {
          return ListView(
            children: [
              Container(
                color: Colors.grey[850],
                height: MediaQuery.of(context).size.height * 0.4,
                margin: EdgeInsets.all(20),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Text(
                      "Editar Treino: ",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Gotham",
                          fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    TextField(
                      enableInteractiveSelection: true,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey[400].withOpacity(0.2)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.6)),
                          ),
                          hintText: "Título do treino",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      controller: _titleController,
                    ),
                    TextField(
                      maxLength: 50,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      maxLines: 2,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey[400].withOpacity(0.2)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6)),
                        ),
                        hintText: "Descrição do treino",
                        hintStyle:
                            TextStyle(color: Colors.grey[300].withOpacity(0.3)),
                      ),
                      controller: _descriController,
                    ),
                    // ignore: deprecated_member_use
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.amber.withOpacity(0.5)),
                          ),
                          child: Text(
                            'CANCELAR',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _titleController.text = "";
                              _descriController.text = "";
                              Navigator.pop(context);
                            });
                          },
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.green.withOpacity(0.5)),
                          ),
                          child: Text(
                            'EDITAR',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _editTrainPlan(_titleController.text,
                                  _descriController.text, doc.id);
                              _titleController.text = "";
                              _descriController.text = "";
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  // ignore: missing_return
  Future<Null> _createNew(
      {@required String title, @required String description}) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .add({"title": title, "description": description}).then((_) {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Treino adicionado com sucesso!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ));
      print("Treino criada com sucesso");
    }).catchError((_) {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Ocorreu um erro!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      print("Ocorreu um erro");
    });
  }

  _editTrainPlan(String title, String desc, String id) async {
    Map<String, dynamic> plan = {
      "title": title,
      "description": desc,
    };
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authId)
        .collection("planilha")
        .doc(id)
        .update(plan)
        .then((value) {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        padding: EdgeInsets.only(bottom: 60),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("Planilha atualizada com sucesso"),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    });
  }

  String title;
  String description;
  bool payApp = false;

  //rewardedAd
  bool isRewardedReady = false;

  //nativa BANNER SCRIPT
  // ignore: unused_field
  AdmobBanner _admobBanner;
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
        break;

      case AdLoadState.loadCompleted:
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
          child: CircularProgressIndicator(),
        );
      return Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: Scaffold(
          key: _scaffoldKey,
          drawer:
              authId != _auth.currentUser.uid ? null : CustomDrawer(1, padding),
          appBar: AppBar(
            toolbarHeight: 70,
            shadowColor: Colors.grey[850],
            elevation: 25,
            centerTitle: true,
            title: AutoSizeText(
              authId == _auth.currentUser.uid
                  ? "Planilhas"
                  : "Planilhas de $name",
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[850],
                  fontFamily: "GothamBold",
                  fontSize: authId == _auth.currentUser.uid ? 30 : 20),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Container(
              height: 60.0,
              width: 55.0,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _displayModalBottom(context);
                    });
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          backgroundColor: Color(0xff313131),
          body: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(authId)
                .collection("planilha")
                .orderBy("title")
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else if (snapshot.data.docs.length <= 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Você não possui nenhuma\nplanilha ainda",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "GothamThin",
                              fontSize: 20)),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Clique no botão flutuante\npara adicionar uma",
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
                  child: ListView(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(5),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                index != 0 &&
                                        index % 2 == 0 &&
                                        index != snapshot.data.docs.length
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        height: 80,
                                        child: NativeAdmob(
                                          adUnitID: nativeAdUnitId(),
                                          loading: Container(),
                                          error: Text("Failed to load the ad"),
                                          controller: _nativeAdController,
                                          type: NativeAdmobType.banner,
                                        ),
                                      )
                                    : Container(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            settings:
                                                RouteSettings(name: "/treino"),
                                            builder: (context) => TreinoScreen(
                                                snapshot.data.docs[index]
                                                    ["title"],
                                                snapshot.data.docs[index].id,
                                                authId,
                                                padding)));
                                  },
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(10),
                                            height: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  new Radius.circular(12.0)),
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
                                                    snapshot.data
                                                        .docs[index]["title"]
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontFamily:
                                                            "GothamBold"),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    snapshot.data.docs[index]
                                                        ["description"],
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontFamily:
                                                            "GothamBook"),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                              ),
                                              splashRadius: 1,
                                              iconSize: 20,
                                              onPressed: () {
                                                _displayEditModalBottom(context,
                                                    snapshot.data.docs[index]);
                                              })),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      );
    });
  }
}
