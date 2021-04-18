import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tabela_treino/models/user_model.dart';
import 'package:tabela_treino/screens/register_screen.dart';
import 'package:tabela_treino/tabs/home_tab.dart';

class LoginScreen extends StatefulWidget {
  final double padding;
  LoginScreen(this.padding);
  @override
  _LoginScreenState createState() => _LoginScreenState(padding);
}

class _LoginScreenState extends State<LoginScreen> {
  final double padding;
  _LoginScreenState(this.padding);

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscureTextPass = true;

  @override
  Widget build(BuildContext context) {
    final Color colorPrincipal = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(130),
            child: AppBar(
              toolbarHeight: 120,
              shadowColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(300, 50),
                ),
              ),
              elevation: 25,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.png',
                    height: 100,
                  ),
                  Text(
                    "Treino Fácil!",
                    style: TextStyle(
                        color: Colors.grey[850],
                        fontFamily: "GothamBold",
                        fontSize: 30),
                  ),
                ],
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
                    padding: EdgeInsets.only(top: 40.0, left: 40, right: 40),
                    children: [
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          style: TextStyle(color: colorPrincipal),
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
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
                            if (text.isEmpty || !text.contains("@"))
                              return "E-mail Inválido!";
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 0, right: 0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _passController,
                          style: TextStyle(color: colorPrincipal),
                          enableInteractiveSelection: true,
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
                            prefixIcon:
                                Icon(Icons.security, color: Colors.white),
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
                            if (text.isEmpty || text.length < 8)
                              return "Senha Inválido!";
                          },
                          obscureText: _obscureTextPass,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            if (_emailController.text.isEmpty) {
                              // ignore: deprecated_member_use
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                padding: EdgeInsets.only(bottom: 60),
                                content: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                      "Insira seu e-mail para recuperação!"),
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: Duration(seconds: 2),
                              ));
                            } else if (_emailController.text.isNotEmpty ||
                                _emailController.text.contains("@")) {
                              {
                                model.resetPassword(_emailController.text);
                                // ignore: deprecated_member_use
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  padding: EdgeInsets.only(bottom: 60),
                                  content: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("Confira seu e-mail!",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ));
                              }
                            }
                          },
                          child: Text(
                            "Esqueci minha senha",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: colorPrincipal.withOpacity(0.8),
                                fontFamily: "GothamBook"),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {}
                          model.signIn(
                              email: _emailController.text,
                              pass: _passController.text,
                              onSucess: _onSucess,
                              onFailed: _onFailed);

                          //container animation
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 60,
                          child: Center(
                            child: Text(
                              "Entrar",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                        height: 40,
                      ),
                      Column(
                        children: [
                          Text(
                            "Não tem cadastro?",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "GothamLight",
                                fontSize: 15),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterScreen(padding)));
                              },
                              child: Text(
                                "Registre-se",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "GothamBold",
                                    fontSize: 38),
                              )),
                          SizedBox(height: 30),
                          /*GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage("images/google_logo.png"),
                                    height: 40,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Entre com a sua conta Google")
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 2,
                                        offset: Offset(0, 4))
                                  ]),
                            ),
                          ),*/
                          SizedBox(height: 100)
                        ],
                      )
                    ],
                  ));
            },
          )),
    );
  }

  void _onSucess() {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      padding: EdgeInsets.only(bottom: 60),
      content: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text("Vamos lá!"),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    ));
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
  }
}
