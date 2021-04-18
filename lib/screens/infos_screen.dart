import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final double padding;
  InfoScreen(this.padding);

  final String text =
      "O “Treino Fácil” é uma aplicação que permite ao usuário organizar e montar suas planilhas e rotinas de treino com ou sem um profissional qualificado.";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Informações Úteis",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Gotham",
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Color(0xff313131),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "GothamBook",
                        fontSize: 18,
                        height: 1.2),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
