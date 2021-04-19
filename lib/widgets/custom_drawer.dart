import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/screens/login_screen.dart';
import 'package:tabela_treino/screens/musclesList_screen.dart';
import 'package:tabela_treino/screens/tokenPersonal_screen.dart';
import 'package:tabela_treino/screens/tokenUser_screen.dart';
import 'package:tabela_treino/tabs/home_tab.dart';
import 'package:tabela_treino/tabs/planilha_tab.dart';
import 'package:tabela_treino/tabs/profile_tab.dart';
import 'package:tabela_treino/transition/transitions.dart';

// ignore: must_be_immutable
class CustomDrawer extends StatelessWidget {
  final double padding;
  final int pageNow;
  CustomDrawer(this.pageNow, this.padding);

  bool isLoading = false;

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
              'Deseja mesmo\ndesconectar da conta?',
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
                  isLoading = true;
                  Navigator.pop(context);
                  model.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              LoginScreen(padding)),
                      (Route<dynamic> route) => false);
                  isLoading = false;
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Drawer(child:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
            return Container(
              color: Colors.grey[900],
              child: ListView(shrinkWrap: true, children: [
                Container(
                  child: model.userData["photoURL"] != null
                      ? GestureDetector(
                          onTap: () {
                            if (pageNow != 4) {
                              Navigator.push(context,
                                  SlideLeftRoute(page: ProfileTab(padding)));
                              print("perfil");
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: DrawerHeader(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: new BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          decoration: new BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Image.network(
                                              model.userData["photoURL"],
                                              fit: BoxFit.fitWidth,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "${model.userData["name"].toString().toUpperCase()} ${model.userData["last_name"].toString().toUpperCase()}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "GothamBook",
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 3),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      model.userData["personal_type"]
                                          ? "Personal Trainer"
                                          : "Aluno",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "GothamThin",
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 1,
                                  right: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      _signOutDialog(context, model);
                                    },
                                    icon: Icon(
                                      Icons.exit_to_app_rounded,
                                      color: Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 30),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (pageNow != 0) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    settings: RouteSettings(name: "/home"),
                                    builder: (context) => HomeTab(padding)));
                            print("home");
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 35,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 32),
                              Text(
                                "Página inicial",
                                style: TextStyle(
                                  fontFamily: "GothamThin",
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          if (pageNow != 1) {
                            Navigator.of(context);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    settings: RouteSettings(name: "/planilhas"),
                                    builder: (context) => PlanilhaScreen(
                                        model.firebaseUser.uid,
                                        model.userData["name"],
                                        padding)));
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.list_outlined,
                                size: 35,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 32),
                              Text(
                                "Minha Planilha\nde Treino",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "GothamThin",
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          if (pageNow != 2) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => MuscleListScreen(
                                        false,
                                        0,
                                        null,
                                        null,
                                        0,
                                        model.firebaseUser.uid,
                                        null,
                                        padding)));
                            print("musculos");
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.line_weight,
                                size: 35,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 32),
                              Text(
                                "Biblioteca de\nexercícios",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "GothamThin",
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          if (pageNow != 3) {
                            if (model.userData["personal_type"]) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      TokenPersonalScreen(model, padding)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      TokenScreen(model, padding)));
                            }
                            print("personal");
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                !model.userData["personal_type"]
                                    ? Icons.live_help
                                    : Icons.people_rounded,
                                size: 35,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 32),
                              Text(
                                !model.userData["personal_type"]
                                    ? "Meu Personal\nTrainer"
                                    : "Controle de\nalunos",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "GothamThin",
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          if (pageNow != 4) {
                            Navigator.push(context,
                                SlideLeftRoute(page: ProfileTab(padding)));
                            print("perfil");
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 35,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 32),
                              Text(
                                "Meu Perfil",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "GothamThin",
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            );
          }));
  }
}
