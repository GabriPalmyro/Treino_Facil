import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class TokenScreen extends StatefulWidget {
  UserModel model;
  final double padding;
  TokenScreen(this.model, this.padding);
  @override
  _TokenScreenState createState() => _TokenScreenState(model, padding);
}

class _TokenScreenState extends State<TokenScreen> {
  UserModel model;
  final double padding;
  _TokenScreenState(this.model, this.padding);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  String _showNumber(String number) {
    var ddd = number.substring(2, 4);
    var numberPhone1 = number.substring(4, 9);
    var numberPhone2 = number.substring(9, 13);
    return "(" + ddd + ")" + " " + numberPhone1 + "-" + numberPhone2;
  }

  _sendWhatsAppMessage({@required String phone}) async {
    String message = "Olá, estou com dúvidas, você pode me ajudar?";
    //var whatsappUrl = "whatsapp://send?phone=$phone=$message";
    String url() {
      if (Platform.isAndroid) {
        // add the [https]
        return "https://wa.me/$phone/?text=${Uri.parse(message)}"; // new line
      } else {
        // add the [https]
        return "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}"; // new line
      }
    }

    await canLaunch(url())
        ? launch(url())
        :
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            padding: EdgeInsets.only(bottom: 60),
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Não há nenhuma aplicação dis"),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
  }

  //delete conection do request
  _deletePersonalRequest(String requestId) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(model.firebaseUser.uid)
        .collection("request_list")
        .doc(requestId)
        .delete()
        .then((value) {
      setState(() {
        isLoading = false;
      });
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        padding: EdgeInsets.only(bottom: 60),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("Pedido excluído com sucesso"),
        ),
        backgroundColor: Colors.amber,
        duration: Duration(seconds: 2),
      ));
    }).catchError((_) {
      setState(() {
        isLoading = false;
      });
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        padding: EdgeInsets.only(bottom: 60),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("Falha ao excluir pedido"),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    });
  }

  _acceptPersonalRequest(DocumentSnapshot personalData) async {
    bool activePers;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(model.firebaseUser.uid)
        .collection("personal")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty)
        activePers = true;
      else
        activePers = false;
    });
    if (!activePers) {
      setState(() {
        isLoading = true;
      });
      //adicionar personal ao aluno
      await FirebaseFirestore.instance
          .collection("users")
          .doc(model.firebaseUser.uid)
          .collection("personal")
          .add({
        "personal_name": personalData["personal_name"],
        "personal_email": personalData["personal_email"],
        "personal_phoneNumber": personalData["personal_phoneNumber"],
        "personal_photo": personalData["personal_photo"],
        "personal_Id": personalData["personal_Id"],
        "connection_date": DateTime.now().toString()
      }).then((value) async {
        //adiciona o aluno ao personal
        await FirebaseFirestore.instance
            .collection("users")
            .doc(personalData["personal_Id"])
            .collection("alunos")
            .add({
          "client_Id": model.firebaseUser.uid,
          "client_name":
              model.userData["name"] + " " + model.userData["last_name"],
          "client_email": model.userData["email"],
          "client_phoneNumber": model.userData["phone_number"],
          "client_photo": model.userData["photoURL"],
        }).then((value) async {
          print("DEU CERTO CARAIO");
          await FirebaseFirestore.instance
              .collection("users")
              .doc(model.firebaseUser.uid)
              .collection("request_list")
              .get()
              .then((value) {
            for (var snapshot in value.docs) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(model.firebaseUser.uid)
                  .collection("request_list")
                  .doc(snapshot.id)
                  .delete();
            }
          });
          setState(() {
            isLoading = false;
          });
          // ignore: deprecated_member_use
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            padding: EdgeInsets.only(bottom: 60),
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Novo Personal Trainer adicionado!"),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
        });
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          padding: EdgeInsets.only(bottom: 60),
          content: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Falha ao adicionar novo Personal Trainer"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      });
    } else {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        padding: EdgeInsets.only(bottom: 60),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("Você já possui um Personal Trainer ativo"),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  _deletePersonal(String personalId) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(model.firebaseUser.uid)
        .collection("personal")
        .get()
        .then((value) async {
      for (var snapshot in value.docs) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(model.firebaseUser.uid)
            .collection("personal")
            .doc(snapshot.id)
            .delete();
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(personalId)
          .collection("alunos")
          .get()
          .then((value) async {
        for (var snapshot in value.docs) {
          if (snapshot["client_Id"] == model.firebaseUser.uid) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(personalId)
                .collection("alunos")
                .doc(snapshot.id)
                .delete()
                .then((value) {
              // ignore: deprecated_member_use
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                padding: EdgeInsets.only(bottom: 60),
                content: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("Desconectado com sucesso!"),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ));
            });
            break;
          }
        }
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  int _calcTime(String connectDate) {
    DateTime dateTime = DateTime.parse(connectDate);
    return DateTime.now().difference(dateTime).inDays;
  }

  Future<void> _personalDisconect(BuildContext context, String pId) async {
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
              'Deseja mesmo desconectar\ndesse Personal?',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 18,
                  height: 1.1),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              TextButton(
                child: Text(
                  'CANCELAR',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text(
                  'DESCONECTAR',
                ),
                onPressed: () {
                  setState(() {
                    _deletePersonal(pId);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: Scaffold(
              key: _scaffoldKey,
              drawer: CustomDrawer(3, padding),
              appBar: AppBar(
                title: Text(
                  "Meu Personal",
                  style: TextStyle(fontFamily: "GothamBold", fontSize: 20),
                ),
                centerTitle: true,
                bottom: TabBar(indicatorColor: Colors.white, tabs: [
                  Tab(
                    icon: Icon(
                      Icons.person_outline,
                      size: 30,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.list,
                      size: 30,
                    ),
                  )
                ]),
              ),
              backgroundColor: Color(0xff313131),
              body: TabBarView(
                children: [
                  //tab 1
                  FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(model.firebaseUser.uid)
                          .collection("personal")
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        if (snapshot.data.docs.length <= 0) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sentiment_dissatisfied_rounded,
                                  size: 40, color: Colors.amber),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Você não possui nenhum\nPersonal Trainer ativo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "GothamBook",
                                    color: Colors.white,
                                    height: 1.2),
                              ),
                            ],
                          );
                        }
                        return ListView(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              decoration:
                                  BoxDecoration(color: Colors.grey[900]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      height: 90,
                                      width: 90,
                                      decoration: new BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Image.network(
                                          snapshot.data.docs[0]
                                              ["personal_photo"],
                                          fit: BoxFit.fitWidth,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    snapshot.data.docs[0]["personal_name"],
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "GothamThin",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Vocês estão conectados há",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "GothamThin",
                                            fontSize: 18),
                                      ),
                                      Text(
                                        " ${_calcTime(snapshot.data.docs[0]["connection_date"])} dias",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontFamily: "GothamThin",
                                            fontSize: 18),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  Text(
                                    "E-mail",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: "Gotham",
                                        fontSize: 25),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    snapshot.data.docs[0]["personal_email"],
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "GothamThin",
                                        fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  Text(
                                    "Número",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: "Gotham",
                                        fontSize: 25),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _showNumber(snapshot.data.docs[0]
                                        ["personal_phoneNumber"]),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "GothamThin",
                                        fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _sendWhatsAppMessage(
                                        phone: snapshot.data.docs[0]
                                            ["personal_phoneNumber"]);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 30),
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        "Enviar Mensagem",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "GothamBook",
                                            fontSize: 12),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 3,
                                              blurRadius: 2,
                                              offset: Offset(0, 4))
                                        ]),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _personalDisconect(context,
                                        snapshot.data.docs[0]["personal_Id"]);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 30),
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        "Desconectar",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "GothamBook",
                                            fontSize: 12),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 3,
                                              blurRadius: 2,
                                              offset: Offset(0, 4))
                                        ]),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }),
                  //tab 2
                  FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(model.firebaseUser.uid)
                          .collection("request_list")
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        return ListView(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Pedidos de conexão".toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontFamily: "Gotham",
                                  fontSize: 25,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 0.0,
                                      color: Colors.grey[900],
                                      offset: Offset(0, 2),
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            snapshot.data.docs.isEmpty
                                ? Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                            Icons
                                                .sentiment_dissatisfied_rounded,
                                            size: 40,
                                            color: Colors.amber),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Você não possui nenhum\npedido de conexão",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "GothamBook",
                                              color: Colors.white,
                                              height: 1.2),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.all(7),
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      print(snapshot.data.docs[index]
                                          ["personal_email"]);
                                      return Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(5),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration:
                                                              new BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 1,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0,
                                                                    2), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          child: Image.network(
                                                              snapshot.data
                                                                      .docs[0][
                                                                  "personal_photo"],
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                              loadingBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      Widget
                                                                          child,
                                                                      ImageChunkEvent
                                                                          loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          }),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: Column(
                                                          children: [
                                                            AutoSizeText(
                                                              snapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          "personal_name"]
                                                                          [0]
                                                                      .toUpperCase() +
                                                                  snapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          "personal_name"]
                                                                      .substring(
                                                                          1),
                                                              maxFontSize: 20,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      "Gotham",
                                                                  fontSize: 15),
                                                            ),
                                                            AutoSizeText(
                                                              snapshot.data
                                                                          .docs[
                                                                      index][
                                                                  "personal_email"],
                                                              maxFontSize: 18,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      "GothamThin",
                                                                  fontSize: 13),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                overlayColor: MaterialStateProperty.all<
                                                                        Color>(
                                                                    Colors.red
                                                                        .withOpacity(
                                                                            0.3)),
                                                              ),
                                                              onPressed: () {
                                                                _deletePersonalRequest(
                                                                    snapshot
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .id);
                                                              },
                                                              child: Text(
                                                                "Excluir",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .red),
                                                              )),
                                                          TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                overlayColor: MaterialStateProperty.all<
                                                                        Color>(
                                                                    Colors.green
                                                                        .withOpacity(
                                                                            0.3)),
                                                              ),
                                                              onPressed: () {
                                                                _acceptPersonalRequest(
                                                                    snapshot.data
                                                                            .docs[
                                                                        index]);
                                                              },
                                                              child: Text(
                                                                "Aceitar",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .green),
                                                              )),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.grey[900],
                                                    thickness: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                          ],
                        );
                      })
                ],
              )),
        ));
  }
}
