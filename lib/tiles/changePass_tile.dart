//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/tabs/home_tab.dart';

class ChangePassScreen extends StatefulWidget {
  @override
  _ChangePassScreenState createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  //text controllers
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _newPassConfirmController = TextEditingController();
  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureNewCPass = true;

  int _passLenght = 0;

  //authUser
  //FirebaseAuth _auth = FirebaseAuth.instance;

  //keys
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 70,
          shadowColor: Colors.grey[850],
          elevation: 25,
          centerTitle: true,
          title: Text(
            "Alterar Senha",
            style: TextStyle(
                color: Colors.grey[850],
                fontFamily: "GothamBold",
                fontSize: 30),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        backgroundColor: Color(0xff313131),
        body:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (model.userData["name"] == null)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Form(
              key: _formKey,
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 30, left: 40, right: 40),
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: _oldPassController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOldPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _obscureOldPass
                                    ? Colors.grey[700].withOpacity(0.5)
                                    : Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureOldPass = !_obscureOldPass;
                                });
                              }),
                          labelText: "Senha Antiga",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.amber, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: "Senha Antiga",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      obscureText: _obscureOldPass,
                      onChanged: (text) {
                        setState(() {
                          _passLenght = text.length;
                        });
                      },
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty) return "Senha Inválida!";
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: TextFormField(
                      controller: _newPassController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _obscureNewPass
                                    ? Colors.grey[700].withOpacity(0.5)
                                    : Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPass = !_obscureNewPass;
                                });
                              }),
                          labelText: "Nova Senha",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.amber, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: "Nova Senha",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      obscureText: _obscureNewPass,
                      onChanged: (text) {
                        setState(() {
                          _passLenght = text.length;
                        });
                      },
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty)
                          return "Senha Inválida!";
                        else if (_newPassConfirmController.text != text)
                          return "Senhas não coincidem!";
                        else if (text.length < 8)
                          return "Senhas menor que 8 caracteres!";
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 0, left: 20, right: 20, bottom: 30),
                    child: TextFormField(
                      controller: _newPassConfirmController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewCPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _obscureNewCPass
                                    ? Colors.grey[700].withOpacity(0.5)
                                    : Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewCPass = !_obscureNewCPass;
                                });
                              }),
                          labelText: "Confirmar Senha",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.amber, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: "Confirmar Senha",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      obscureText: _obscureNewCPass,
                      onChanged: (text) {
                        setState(() {
                          _passLenght = text.length;
                        });
                      },
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty)
                          return "Senha Inválida!";
                        else if (_newPassController.text != text)
                          return "Senhas não coincidem!";
                        else if (text.length < 8)
                          return "Senhas menor que 8 caracteres!";
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState.validate() &&
                          _newPassController.text ==
                              _newPassConfirmController.text &&
                          _newPassController.text.length >= 8) {}
                      //Navigator.pop(context);
                      //CONFIRMAÇÃO E FUNÇÃO DE SALVAR NOVOS ATUALIZAÇÃO DE PERFIL
                      model
                          .changePassword(
                              _oldPassController.text, _newPassController.text)
                          .then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => HomeTab()),
                              (Route<dynamic> route) => false));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      height: 60,
                      child: Center(
                        child: Text(
                          "Confirmar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: (_newPassController.text ==
                                      _newPassConfirmController.text &&
                                  _newPassController.text.length >= 8)
                              ? Theme.of(context).primaryColor
                              : Colors.grey[500],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 3,
                                blurRadius: 2,
                                offset: Offset(0, 4))
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              ));
        }));
  }
}
