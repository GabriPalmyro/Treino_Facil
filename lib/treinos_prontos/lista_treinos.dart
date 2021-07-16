import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/transition/transitions.dart';
import 'package:tabela_treino/treinos_prontos/treinos_screen.dart';
import 'package:menu_button/menu_button.dart';

class ListaTreinosProntos extends StatefulWidget {
  final String sexo;
  final String level;
  final String idLevel;

  const ListaTreinosProntos({Key key, this.sexo, this.level, this.idLevel})
      : super(key: key);

  @override
  _ListaTreinosProntosState createState() => _ListaTreinosProntosState();
}

class _ListaTreinosProntosState extends State<ListaTreinosProntos> {
  String selectedLevel;
  String selectedId;

  List<String> levels = <String>['Iniciante', 'Avançado'];
  List<String> levelId = <String>[
    "owNiAMA7DN9trhiK3nDp",
    "RGwqW8GwUoNwnCem1KAH"
  ];

  @override
  void initState() {
    selectedLevel = widget.level;
    selectedId = widget.idLevel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.level.toUpperCase(),
              style: TextStyle(
                  fontSize: 20, fontFamily: "Gotham", color: Colors.grey[900])),
          actions: [
            MenuButton<String>(
              child: SizedBox(
                width: 120,
                height: 40,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 11),
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Text(selectedLevel,
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(
                        width: 12,
                        height: 17,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              items: levels,
              itemBuilder: (String value) => Container(
                color: Theme.of(context).primaryColor,
                height: 40,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                child: Text(value),
              ),
              toggledChild: Container(
                color: Theme.of(context).primaryColor,
                child: SizedBox(
                  width: 93,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: Text(selectedLevel,
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(
                          width: 12,
                          height: 17,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onItemSelected: (String value) async {
                if (value == levels[0]) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  //checa se o usuario já tem um nivel escolhido
                  prefs.setString("levelChoice", levelId[0]);
                  prefs.setString("levelName", value.toLowerCase());
                  setState(() {
                    selectedId = levelId[0];
                  });
                } else {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  //checa se o usuario já tem um nivel escolhido
                  prefs.setString("levelChoice", levelId[1]);
                  prefs.setString("levelName", value.toLowerCase());
                  setState(() {
                    selectedId = levelId[1];
                  });
                }

                setState(() {
                  selectedLevel = value;
                });
              },
            )
          ],
        ),
        backgroundColor: Color(0xff313131),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("tfaceis")
              .doc(selectedId)
              .collection(widget.sexo)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 24,
                    ),
                    Text("Carregando lista de treinos...",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: "GothamBook",
                            color: Theme.of(context).primaryColor))
                  ],
                ),
              );
            } else if (snapshot.data.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_rounded,
                        size: 40, color: Colors.amber),
                    SizedBox(
                      height: 24,
                    ),
                    Text("Lista vazia ou ainda não existe",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: "GothamBook",
                            color: Theme.of(context).primaryColor)),
                  ],
                ),
              );
            } else
              return SafeArea(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return snapshot.data.docs[index]['is_seen'] == true
                            ? listaContainerProntos(context, snapshot, index)
                            : Container();
                      }));
          },
        ));
  }

  InkWell listaContainerProntos(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            SlideLeftRoute(
                page: TreinosProntos(
                    widget.level,
                    widget.idLevel,
                    snapshot.data.docs[index].id,
                    snapshot.data.docs[index]["title"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: index == 0 ? 20 : 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(12.0)),
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
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                snapshot.data.docs[index]["title"].toString().toUpperCase(),
                style: TextStyle(fontSize: 25, fontFamily: "GothamBold"),
                textAlign: TextAlign.center,
              ),
              Divider(),
              Text(
                snapshot.data.docs[index]["description"],
                style: TextStyle(fontSize: 22, fontFamily: "GothamBook"),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
