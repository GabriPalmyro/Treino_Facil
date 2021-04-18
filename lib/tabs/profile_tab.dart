import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/screens/infos_screen.dart';
import 'package:tabela_treino/screens/login_screen.dart';
import 'package:tabela_treino/tiles/changePass_tile.dart';
import 'package:tabela_treino/tiles/my_account_tile.dart';
import 'package:tabela_treino/transition/transitions.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';
import 'package:share/share.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTab extends StatefulWidget {
  final double padding;
  ProfileTab(this.padding);
  @override
  _ProfileTabState createState() => _ProfileTabState(padding);
}

class _ProfileTabState extends State<ProfileTab> {
  final double padding;
  _ProfileTabState(this.padding);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _url =
      'https://www.paypal.com/donate?hosted_button_id=RBWUVA44TNKWJ';

  Future<void> _signOutDialog(BuildContext context, UserModel model) async {
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
              'Deseja mesmo sair\nda sua conta?',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 20,
                  height: 1.1),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              TextButton(
                child: Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.white),
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
                  'SAIR',
                ),
                onPressed: () {
                  Navigator.pop(context);
                  model.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              LoginScreen(padding)),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        });
  }

  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
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
            drawer: CustomDrawer(4, padding),
            appBar: AppBar(
              toolbarHeight: 70,
              shadowColor: Colors.grey[850],
              elevation: 25,
              centerTitle: true,
              title: Text(
                "Treino Fácil",
                style: TextStyle(
                    color: Colors.grey[850],
                    fontFamily: "GothamBold",
                    fontSize: 30),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            backgroundColor: Color(0xff313131),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 60,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * .9,
                        height: MediaQuery.of(context).size.height * .75,
                        decoration: BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(new Radius.circular(20.0)),
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .85,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 65),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${model.userData["name"]} ${model.userData["last_name"]}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "GothamBook",
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    model.userData["email"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "GothamBook",
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                        letterSpacing: 2),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 2,
                              height: 0,
                            ),
                            GestureDetector(
                              onTap: () {
                                Map<String, dynamic> userData = {
                                  "name": model.userData["name"],
                                  "last_name": model.userData["last_name"],
                                  "email": model.userData["email"],
                                  "number": model.userData["phone_number"],
                                  "photoURL": model.userData["photoURL"]
                                };
                                Navigator.push(
                                    context,
                                    ScaleRoute(
                                        page: MyAccount(userData, padding)));
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Minha Conta",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    ScaleRoute(
                                        page: ChangePassScreen(padding)));
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Alterar Senha",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Share.share(
                                        'Tenha suas planilhas na palma da sua mão! -> https://play.google.com/store/apps/details?id=br.com.palmyro.treino_facil',
                                        subject:
                                            'Compartilhe o app para mais pessoas!')
                                    .catchError((_) {
                                  _scaffoldKey.currentState
                                      // ignore: deprecated_member_use
                                      .showSnackBar(SnackBar(
                                    padding: EdgeInsets.only(bottom: 60),
                                    content: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("Erro  ${_.toString()}"),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ));
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Compartilhar o App",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("AVALIANDO");
                                _inAppReview.openStoreListing();
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Avaliar o App",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await launch(_url).catchError((_) {
                                  _scaffoldKey.currentState
                                      // ignore: deprecated_member_use
                                      .showSnackBar(SnackBar(
                                    padding: EdgeInsets.only(bottom: 60),
                                    content: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("ERRO  ${_.toString()}"),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ));
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Fazer uma contribuição",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            /*GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    SlideLeftRoute(page: InfoScreen(padding)));
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(left: 30, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Informações Úteis",
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          fontSize: 20,
                                          color: Colors.grey[850]
                                              .withOpacity(0.8)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey[700].withOpacity(0.6),
                                    )
                                  ],
                                ),
                              ),
                            ),*/
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 15,
                        right: MediaQuery.of(context).size.width / 2.8,
                        child: Container(
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset:
                                    Offset(0, 6), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Container(
                              height: 110,
                              width: 110,
                              child: Image.network(model.userData["photoURL"],
                                  fit: BoxFit.fitWidth, loadingBuilder:
                                      (BuildContext context, Widget child,
                                          ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                    child: CircularProgressIndicator());
                              }),
                            ),
                          ),
                        )),
                    Positioned(
                        top: 80,
                        right: MediaQuery.of(context).size.width / 1.25,
                        child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            splashRadius: 20,
                            splashColor: Colors.yellow,
                            onPressed: () {
                              Map<String, dynamic> userData = {
                                "name": model.userData["name"],
                                "last_name": model.userData["last_name"],
                                "email": model.userData["email"],
                                "number": model.userData["phone_number"],
                                "photoURL": model.userData["photoURL"]
                              };
                              Navigator.push(
                                  context,
                                  ScaleRoute(
                                      page: MyAccount(userData, padding)));
                            })),
                    Positioned(
                        top: 80,
                        right: MediaQuery.of(context).size.width / 13,
                        child: IconButton(
                            icon: Icon(
                              Icons.exit_to_app_rounded,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            splashRadius: 20,
                            splashColor: Colors.red,
                            onPressed: () {
                              _signOutDialog(context, model);
                            })),
                  ],
                ),
              ),
            )),
      );
    });
  }
}
