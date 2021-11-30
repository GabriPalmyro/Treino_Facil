import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/tabs/home_tab.dart';

class RegisterScreen extends StatefulWidget {
  final double padding;
  RegisterScreen(this.padding);
  @override
  _RegisterScreenState createState() => _RegisterScreenState(padding);
}

class _RegisterScreenState extends State<RegisterScreen> {
  final double padding;
  _RegisterScreenState(this.padding);

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryIdController = TextEditingController();
  final _dddIdController = TextEditingController();
  final _numberController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscureTextPass = true;
  bool _obscureTextPassConf = true;
  int sexo = 0;
  int personal = 1;

  // ignore: unused_element
  void _mudarObscure(bool obscureText) {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  void initState() {
    super.initState();

    _countryIdController.text = "55";
  }

  File _image2;
  final picker = ImagePicker();

  Future getImage() async {
    // ignore: deprecated_member_use
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        _image2 = File(pickedFile.path);
      } else {
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          padding: EdgeInsets.only(bottom: 60),
          content: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Erro ao entrar procurar foto"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));

        print('No image selected.');
        throw Exception('File is not available');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color colorPrincipal = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: AppBar(
              toolbarHeight: 100,
              shadowColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(200, 50),
                ),
              ),
              elevation: 20,
              centerTitle: true,
              title: Text(
                "Registrar\nnova conta",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[850],
                    fontFamily: "GothamBold",
                    fontSize: 30),
              ),
              backgroundColor: colorPrincipal,
            ),
          ),
          backgroundColor: Color(0xff313131),
          body: ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              if (model.isLoading)
                return Center(
                  child: CircularProgressIndicator(),
                );
              return Form(
                  key: _formKey,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 20.0, left: 30, right: 30),
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
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: _image2 == null
                                  ? Image.asset(
                                      "images/blank-profile-picture.png",
                                      fit: BoxFit.contain,
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
                                onPressed: () async {
                                  await getImage();
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _nameController,
                              style: TextStyle(color: colorPrincipal),
                              showCursor: true,
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                labelText: "Nome",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty)
                                  return "Nome vazio";
                                else if (text.length > 30)
                                  return "Máximo de 15 palavras";
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            width: 140,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _lastNameController,
                              style: TextStyle(color: colorPrincipal),
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                labelText: "Sobrenome",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty)
                                  return "Sobrenome vazio";
                                else if (text.length > 30)
                                  return "Máximo de 25 palavras";
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            margin: EdgeInsets.symmetric(vertical: 30),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              style: TextStyle(color: colorPrincipal),
                              enableSuggestions: true,
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                labelText: "E-mail",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty)
                                  return "E-mail Vazio!";
                                else if (!text.contains("@"))
                                  return "E-mail Incompleto!";
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _countryIdController,
                              style: TextStyle(color: colorPrincipal),
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                  labelText: "COD",
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
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2.0),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  hintText: "55",
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.grey[300].withOpacity(0.3))),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty || text.length > 2)
                                  return "Inválido!";
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _numberController,
                              style: TextStyle(color: colorPrincipal),
                              enableInteractiveSelection: true,
                              inputFormatters: [
                                // obrigatório
                                FilteringTextInputFormatter.digitsOnly,
                                TelefoneInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: "Número",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty)
                                  return "Número Vazio!";
                                else if (text.length < 11)
                                  return "Número pequeno";
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.security, color: Colors.white),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _passController,
                              style: TextStyle(color: colorPrincipal),
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
                                labelText: "Senha",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.contains(" "))
                                  return "Senha não pode conter espaço";
                                if (text.isEmpty) return "Senha Inválida!";
                                if (text.length < 8)
                                  return "Senha menor que 8 caracteres!";
                              },
                              obscureText: _obscureTextPass,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.flip, color: Colors.white),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              toolbarOptions: ToolbarOptions(copy: false),
                              controller: _passConfirmController,
                              style: TextStyle(color: colorPrincipal),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureTextPassConf
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: _obscureTextPassConf
                                          ? Colors.grey[700].withOpacity(0.5)
                                          : Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureTextPassConf =
                                            !_obscureTextPassConf;
                                      });
                                    }),
                                labelText: "Confirmar senha",
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              // ignore: missing_return
                              validator: (text) {
                                if (text.isEmpty)
                                  return "Senha não confirmada!";
                                else if (text != _passController.text)
                                  return "Senhas não conferem";
                              },
                              obscureText: _obscureTextPassConf,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        height: 120,
                        child: Column(
                          children: [
                            Text(
                              "Gênero",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 25,
                                fontFamily: "GothamLight",
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          sexo = 0;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        width: 130,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: sexo == 0
                                              ? colorPrincipal
                                              : Color(0xff313131),
                                          boxShadow: sexo == 0
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 4))
                                                ]
                                              : [
                                                  BoxShadow(
                                                      color: Colors.transparent)
                                                ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Masculino",
                                            style: TextStyle(
                                                color: sexo == 0
                                                    ? Color(0xff313131)
                                                    : colorPrincipal,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          sexo = 1;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        width: 130,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          boxShadow: sexo == 1
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 4))
                                                ]
                                              : [
                                                  BoxShadow(
                                                      color: Colors.transparent)
                                                ],
                                          color: sexo == 1
                                              ? colorPrincipal
                                              : Color(0xff313131),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Feminino",
                                            style: TextStyle(
                                                color: sexo == 1
                                                    ? Color(0xff313131)
                                                    : colorPrincipal,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(
                              "Você é Personal Trainer?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 25,
                                fontFamily: "GothamLight",
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          personal = 0;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        width: 130,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: personal == 0
                                              ? colorPrincipal
                                              : Color(0xff313131),
                                          boxShadow: personal == 0
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 4))
                                                ]
                                              : [
                                                  BoxShadow(
                                                      color: Colors.transparent)
                                                ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Sim",
                                            style: TextStyle(
                                                color: personal == 0
                                                    ? Color(0xff313131)
                                                    : colorPrincipal,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          personal = 1;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        width: 130,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          boxShadow: personal == 1
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 4))
                                                ]
                                              : [
                                                  BoxShadow(
                                                      color: Colors.transparent)
                                                ],
                                          color: personal == 1
                                              ? colorPrincipal
                                              : Color(0xff313131),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Não",
                                            style: TextStyle(
                                                color: personal == 1
                                                    ? Color(0xff313131)
                                                    : colorPrincipal,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            if (_countryIdController.text.isEmpty)
                              _countryIdController.text = "55";

                            String phone_number =
                                UtilBrasilFields.removeCaracteres(
                                    _countryIdController.text.trim() +
                                        _numberController.text.trim());

                            Map<String, dynamic> userData = {
                              "name":
                                  _nameController.text[0].trim().toUpperCase() +
                                      _nameController.text.trim().substring(1),
                              "last_name": _lastNameController.text[0]
                                      .trim()
                                      .toUpperCase() +
                                  _lastNameController.text.trim().substring(1),
                              "email": _emailController.text.trim(),
                              "sexo": sexo == 0 ? "Masculino" : "Feminino",
                              "phone_number": "+" + phone_number,
                              "payApp": false,
                              "data_criado": DateTime.now(),
                              "personal_type":
                                  personal == 0 ? true : false, //personal_type
                              "photoURL":
                                  "https://firebasestorage.googleapis.com/v0/b/treino-facil-22856.appspot.com/o/perfil_photosURL%2Fblank-profile-picture.png?alt=media&token=698f7a33-6170-4c8d-b0b6-d65ffe052010"
                            };
                            model.singUp(
                                userData: userData,
                                pass: _passController.text,
                                onSucess: _onSucess,
                                onFailed: _onFailed,
                                newImage: _image2);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 60,
                          child: Center(
                            child: Text(
                              "Registrar",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.amber, width: 1),
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
                      ),
                    ],
                  ));
            },
          )),
    );
  }

  void _onSucess() {
    // ignore: deprecated_member_use
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => HomeTab(padding)),
        (Route<dynamic> route) => false);
  }

  void _onFailed() {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      padding: EdgeInsets.only(bottom: 60),
      content: Padding(
        padding: const EdgeInsets.only(left: 10),
        child:
            Text("Erro ao entrar, verifique seu email ou sua senha novamente"),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ));
    print("ERROR");
  }
}
