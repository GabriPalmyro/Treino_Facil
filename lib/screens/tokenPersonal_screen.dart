import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/tabs/planilha_tab.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';

// ignore: must_be_immutable
class TokenPersonalScreen extends StatefulWidget {
  UserModel model;
  TokenPersonalScreen(this.model);
  @override
  _TokenPersonalScreenState createState() => _TokenPersonalScreenState(model);
}

class _TokenPersonalScreenState extends State<TokenPersonalScreen> {
  UserModel model;
  _TokenPersonalScreenState(this.model);

  FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _clientController = TextEditingController();
  bool _isSending = false;
  String clientId;

  Future<void> _sendClientRequest() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: _clientController.text)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          padding: EdgeInsets.only(bottom: 60),
          content: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Não há nenhum usuário com esse email"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      } else {
        setState(() {
          _isSending = true;
        });
        clientId = value.docs[0].id;
        await FirebaseFirestore.instance
            .collection("users")
            .doc(clientId)
            .collection("request_list")
            .add({
          "personal_Id": model.firebaseUser.uid,
          "personal_name":
              model.userData["name"] + " " + model.userData["last_name"],
          "personal_email": model.userData["email"],
          "personal_photo": model.userData["photoURL"],
          "personal_phoneNumber": model.userData["phone_number"]
        }).then((value) {
          setState(() {
            _isSending = false;
          });
          // ignore: deprecated_member_use
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            padding: EdgeInsets.only(bottom: 60),
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Pedido enviado com sucesso"),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
        }).catchError((_) {
          setState(() {
            _isSending = false;
          });
          // ignore: deprecated_member_use
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            padding: EdgeInsets.only(bottom: 60),
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Pedido não enviado"),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(3),
        appBar: AppBar(
          title: Text(
            "Meus Alunos",
            style: TextStyle(fontFamily: "GothamBold", fontSize: 24),
          ),
          centerTitle: true,
        ),
        backgroundColor: Color(0xff313131),
        body: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(_auth.currentUser.uid)
                .collection("alunos")
                .orderBy("client_name")
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || _isSending == true)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.height * 0.7,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
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
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Alunos conectados".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[850],
                                fontFamily: "Gotham",
                                fontSize: 20),
                          ),
                          Divider(
                            thickness: 0.8,
                            color: Colors.grey[900].withOpacity(0.7),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.all(5),
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
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
                                                      BorderRadius.circular(50),
                                                  child: Container(
                                                    height: 45,
                                                    width: 45,
                                                    decoration:
                                                        new BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 3,
                                                          offset: Offset(0,
                                                              2), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Image.network(
                                                        snapshot.data
                                                                .docs[index]
                                                            ["client_photo"]),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AutoSizeText(
                                                        snapshot.data
                                                                .docs[index]
                                                            ["client_name"],
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Gotham",
                                                            fontSize: 15),
                                                      ),
                                                      AutoSizeText(
                                                        snapshot.data
                                                                .docs[index]
                                                            ["client_email"],
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "GothamThin",
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                TextButton(
                                                    style: ButtonStyle(
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.3)),
                                                    ),
                                                    onPressed: () {
                                                      print(
                                                          "${snapshot.data.docs[index]["client_Id"]}");
                                                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                          settings: RouteSettings(
                                                              name:
                                                                  "/planilhas"),
                                                          builder: (context) => PlanilhaScreen(
                                                              snapshot.data
                                                                          .docs[
                                                                      index]
                                                                  ["client_Id"],
                                                              snapshot.data
                                                                          .docs[
                                                                      index][
                                                                  "client_name"])));
                                                    },
                                                    child: Text(
                                                      "Acessar Planilhas",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[700]),
                                                    ))
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
                              }),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.height * 0.7,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(new Radius.circular(10.0)),
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Conecte-se a um aluno".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[850],
                                  fontFamily: "GothamBold",
                                  fontSize: 20),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _clientController,
                                style: TextStyle(
                                  color: Colors.grey[900],
                                  fontSize: 18,
                                  fontFamily: "GothamBook",
                                ),
                                enableInteractiveSelection: true,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey[900]
                                              .withOpacity(0.8)),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    hintText: "E-mail do aluno",
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5),
                                        fontFamily: "GothamBook",
                                        fontSize: 15)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "Apagar",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.red),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _clientController.text = "";
                                      });
                                    }),
                                TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "Enviar",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.green),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _sendClientRequest();
                                        _clientController.text = "";
                                      });
                                    })
                              ],
                            )
                          ],
                        )),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                );
              }
            }));
  }
}
