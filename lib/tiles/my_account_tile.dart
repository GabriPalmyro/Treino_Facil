import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/tabs/home_tab.dart';
import 'package:image_picker/image_picker.dart';

class MyAccount extends StatefulWidget {
  final Map<String, dynamic> userData;
  MyAccount(this.userData);
  @override
  _MyAccountState createState() => _MyAccountState(userData);
}

class _MyAccountState extends State<MyAccount> {
  Map<String, dynamic> userData;
  _MyAccountState(this.userData);

  //text controllers
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _passController = TextEditingController();
  String _image;
  bool _obscureTextPass = true;
  int _passLenght = 0;
  bool isLoading = false;

  //authUser
  //FirebaseAuth _auth = FirebaseAuth.instance;

  //keys
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _image = userData["photoURL"];
    _nameController.text = userData["name"];
    _lastNameController.text = userData["last_name"];
    _emailController.text = userData["email"];
    _numberController.text = userData["number"];
  }

  File _image2;
  final picker = ImagePicker();

  Future getImage() async {
    // ignore: deprecated_member_use
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    setState(() {
      if (pickedFile != null) {
        _image2 = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

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
            "Editar Perfil",
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
          if (model.userData["name"] == null || isLoading)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Form(
              key: _formKey,
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 30, left: 40, right: 40),
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: new BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 4), // changes position of shadow
                              ),
                            ],
                          ),
                          child: _image2 == null
                              ? Image.network(
                                  _image,
                                  fit: BoxFit.fitWidth,
                                )
                              : Image.file(
                                  _image2,
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 1,
                        right: 1,
                        child: IconButton(
                            icon: Icon(
                              Icons.image_search,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              getImage();
                            }),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          maxLength: 15,
                          decoration: InputDecoration(
                              labelText: "Confirmar nome",
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Theme.of(context).primaryColor,
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
                              hintText: "Nome",
                              hintStyle: TextStyle(
                                  color: Colors.grey[300].withOpacity(0.3))),
                          // ignore: missing_return
                          validator: (text) {
                            if (text.isEmpty) return "Nome Inválido!";
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _lastNameController,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          maxLength: 20,
                          decoration: InputDecoration(
                              labelText: "Confirmar sobrenome",
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
                              hintText: "Sobrenome",
                              hintStyle: TextStyle(
                                  color: Colors.grey[300].withOpacity(0.3))),
                          // ignore: missing_return
                          validator: (text) {
                            if (text.isEmpty) return "Sobrenome Inválido!";
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          labelText: "Confirmar e-mail",
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
                          hintText: "E-mail",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty || !text.contains("@"))
                          return "E-mail Inválido!";
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _numberController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          labelText: "Confirmar número",
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
                          hintText: "Número",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty || text.length < 13)
                          return "Número Inválido!";
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _passController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                _obscureTextPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _obscureTextPass
                                    ? Colors.grey[700].withOpacity(0.5)
                                    : Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureTextPass = !_obscureTextPass;
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
                          hintText: "Confirme sua senha",
                          hintStyle: TextStyle(
                              color: Colors.grey[300].withOpacity(0.3))),
                      obscureText: _obscureTextPass,
                      onChanged: (text) {
                        setState(() {
                          _passLenght = text.length;
                        });
                      },
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty || text.length < 8)
                          return "Senha Inválida!";
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      print(_image2);
                      setState(() {
                        isLoading = true;
                      });
                      if (_formKey.currentState.validate()) {}
                      //Navigator.pop(context);
                      //CONFIRMAÇÃO E FUNÇÃO DE SALVAR NOVOS ATUALIZAÇÃO DE PERFIL
                      Map<String, dynamic> newUserData = {
                        "name": _nameController.text,
                        "last_name": _lastNameController.text,
                        "email": _emailController.text,
                        "phone": _numberController.text,
                        "photoURL": userData["photoURL"],
                        "password": _passController.text
                      };
                      model
                          .changeUserInfos(
                              newUserData: newUserData, newImage: _image2)
                          .then((value) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) => HomeTab()),
                            (Route<dynamic> route) => false);
                      }).catchError((onError) {
                        print(onError);
                        setState(() {
                          isLoading = false;
                        });
                        // ignore: deprecated_member_use
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          padding: EdgeInsets.only(bottom: 60),
                          content: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Erro ao atualizar perfil",
                                style: TextStyle(color: Colors.white)),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ));
                      });
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
                          color: _passLenght >= 8
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
