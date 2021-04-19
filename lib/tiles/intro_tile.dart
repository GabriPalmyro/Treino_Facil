import 'package:flutter/material.dart';
import 'package:tabela_treino/screens/login_screen.dart';
import 'package:tabela_treino/tabs/home_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tabela_treino/transition/transitions.dart';

class IntroScreen extends StatefulWidget {
  final double padding;
  IntroScreen(this.padding);
  @override
  _IntroScreenState createState() => _IntroScreenState(padding);
}

class _IntroScreenState extends State<IntroScreen> {
  final double padding;
  _IntroScreenState(this.padding);

  int bottomSelectedIndex = 0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Color color = const Color(0xFFDFAD16);

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        physics: BouncingScrollPhysics(),
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("images/intro_1.png",
                      alignment: Alignment.center),
                  Text("Criar Planilhas",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamBold",
                          fontSize: 24)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "Para criar novas planilhas acesse o menu \"Suas planilhas\" e clique no botão flutuante",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamThin",
                          height: 1.2,
                          fontSize: 22)),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          bottomSelectedIndex += 1;
                          pageController.animateToPage(bottomSelectedIndex,
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        },
                        child: Icon(Icons.arrow_right_alt_rounded,
                            color: Colors.grey[850], size: 38)),
                  ),
                ],
              ),
              color: color),
          Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("images/intro_2.png",
                      alignment: Alignment.center),
                  Text("Excluir exercícios",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamBold",
                          fontSize: 24)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "Para excluir exercícios da planilha, apenas deslize o exercício para direita e confirme",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamThin",
                          height: 1.2,
                          fontSize: 22)),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          bottomSelectedIndex += 1;
                          pageController.animateToPage(bottomSelectedIndex,
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        },
                        child: Icon(Icons.arrow_right_alt_rounded,
                            color: Colors.grey[850], size: 38)),
                  ),
                ],
              ),
              color: color),
          Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("images/intro_3.png",
                      alignment: Alignment.center),
                  Text("Pesquisar exercícios",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamBold",
                          fontSize: 24)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "Você também pode pesquisar por exercícios e filtrá-los por agrupamento muscular ou por aqueles que podem ser realizados em casa",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GothamThin",
                          height: 1.2,
                          fontSize: 22)),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          bottomSelectedIndex += 1;
                          pageController.animateToPage(bottomSelectedIndex,
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        },
                        child: Icon(Icons.arrow_right_alt_rounded,
                            color: Colors.grey[850], size: 38)),
                  ),
                ],
              ),
              color: color),
          SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("images/intro_4.png",
                        alignment: Alignment.center),
                    Text("Personal Trainer",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "GothamBold",
                            fontSize: 24)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                        "Caso você seja Personal Trainer, você pode se conectar com seus alunos e editar suas planilhas em tempo real",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "GothamThin",
                            height: 1.2,
                            fontSize: 22)),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                          onPressed: () {
                            _auth.currentUser == null
                                ? Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(
                                        settings: RouteSettings(name: "/login"),
                                        builder: (context) =>
                                            LoginScreen(padding)))
                                : Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(
                                        settings: RouteSettings(name: "/home"),
                                        builder: (context) =>
                                            HomeTab(padding)));
                          },
                          child: Text("Ir para o App".toUpperCase(),
                              style: TextStyle(
                                  color: Colors.grey[850],
                                  fontFamily: "GothamBook",
                                  fontSize: 24))),
                    ),
                  ],
                ),
                color: color),
          )
        ],
      ),
    );
  }
}
