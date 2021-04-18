import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabela_treino/ads/ads_model.dart';
import 'package:tabela_treino/screens/exerciseDetail_screen.dart';
import 'package:tabela_treino/widgets/custom_drawer.dart';
import 'package:firebase_admob/firebase_admob.dart';

import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

class MuscleListScreen extends StatefulWidget {
  final String authId;
  final String treinoId;
  final String title;
  final String exeId;
  final bool addMode;
  final int set;
  final int qntdExe;
  final double padding;
  MuscleListScreen(this.addMode, this.set, this.treinoId, this.exeId,
      this.qntdExe, this.authId, this.title, this.padding);
  @override
  _MuscleListScreenState createState() => _MuscleListScreenState(
      addMode, set, treinoId, exeId, qntdExe, authId, title, padding);
}

class _MuscleListScreenState extends State<MuscleListScreen> {
  final String authId;
  final bool addMode;
  final int set;
  final String treinoId;
  final String exeId;
  final int qntdExe;
  final String title;
  final double padding;
  _MuscleListScreenState(this.addMode, this.set, this.treinoId, this.exeId,
      this.qntdExe, this.authId, this.title, this.padding);

  //container animado controles
  double _containerHeight = 0;
  double _containerMargin = 0;

  // lists
  bool _isSearching = false;
  final _searchController = TextEditingController();

  Future resultsLoaded;
  List _muscleList = [];
  List _resultList = [];
  //List<String> _typeSearch = ["title", "muscleId", "home_exe"];
  String _selTypeSearch = "title";

  //ADSSSSSSSS
  final _controller = NativeAdmobController();
  InterstitialAd interstitialAdMuscle;
  bool _isInterstitialAdReady;
  int adClick = 0;

  void _loadInterstitialAd() {
    interstitialAdMuscle.load();
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        break;
      default:
      // do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _isInterstitialAdReady = false;
    interstitialAdMuscle = InterstitialAd(
      adUnitId: interstitialAdUnitId(),
      listener: _onInterstitialAdEvent,
    );
    _loadInterstitialAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getMuscleSnapshots();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResults = [];

    //se o controlador não estiver vazio
    if (_searchController.text != "") {
      // parametro de busca
      //analisar todos os arquivos do banco de dados
      for (var tripSnapshot in _muscleList) {
        var title = tripSnapshot["title"].toString().toUpperCase();
        var homeExe = tripSnapshot["home_exe"];
        var muscleId = tripSnapshot["muscleId"].toString().toUpperCase();
        //se o tipo for "home_exe"
        if (_selTypeSearch == "home_exe") {
          if (title.startsWith(_searchController.text.toUpperCase()) &&
              homeExe == true) {
            showResults.add(
                tripSnapshot); //adiciona apenas os procurados e home_exe na lista
          }
          //se o tipo for "muscleId"
        } else if (_selTypeSearch == "muscleId") {
          if (muscleId.startsWith(_searchController.text.toUpperCase())) {
            showResults.add(tripSnapshot);
          }
        } else if (_selTypeSearch == "title") {
          //se o tipo for title
          if (title.startsWith(_searchController.text.toUpperCase())) {
            showResults
                .add(tripSnapshot); //adiciona apenas os procurados na lista
          }
        } else {
          if (title.startsWith(_searchController.text.toUpperCase()) &&
              muscleId == _selTypeSearch.toUpperCase()) {
            showResults
                .add(tripSnapshot); //adiciona apenas os procurados na lista
          }
        }
      }
      //se o controlador estiver vazio de inicio e o tipo for "home_exe"
    } else if (_selTypeSearch == "home_exe") {
      //se o tipo for "home_exe"
      for (var tripSnapshot in _muscleList) {
        var homeExe = tripSnapshot["home_exe"];
        if (homeExe) {
          showResults.add(tripSnapshot);
        }
      }
    }
    //se for selecionado por titulo ou nome de agrupamentos
    else if (_selTypeSearch == "title" || _selTypeSearch == "muscleId") {
      showResults = List.from(_muscleList);
    } else {
      //se for selecionado por grupamento
      for (var tripSnapshot in _muscleList) {
        var muscle = tripSnapshot["muscleId"];
        if (muscle == _selTypeSearch) {
          showResults.add(tripSnapshot);
        }
      }
    }
    setState(() {
      _resultList = showResults;
    });
  }

  getMuscleSnapshots() async {
    QuerySnapshot data;
    //if (_selTypeSearch == "title") {
    data = await FirebaseFirestore.instance
        .collection("musculos2")
        .orderBy("title")
        .get();

    setState(() {
      _muscleList = data.docs;
    });

    searchResultList();
    return data.docs;
  }

  Widget _buildSearchField() {
    return TextField(
      keyboardType: TextInputType.text,
      controller: _searchController,
      style: TextStyle(
        color: Colors.grey[900],
        fontSize: 20,
        height: 1.3,
        fontFamily: "GothamBook",
      ),
      enableInteractiveSelection: true,
      decoration: InputDecoration(
          hintText: _selTypeSearch == "title"
              ? "Procure um exercício"
              : _selTypeSearch == "home_exe"
                  ? "Fazer em casa"
                  : _selTypeSearch == "muscleId"
                      ? "Procure um músculo"
                      : "Procure em $_selTypeSearch",
          border: InputBorder.none,
          hintStyle: TextStyle(
              fontSize: 18, color: Colors.grey[900].withOpacity(0.9))),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchController == null || _searchController.text.isEmpty) {
              setState(() {
                _isSearching = false;
                _containerHeight = 0;
                _containerMargin = 0;
              });
              return;
            }
            setState(() {
              _searchController.clear();
            });
          },
        ),
        IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: () {
              setState(() {
                if (_containerHeight == 0) {
                  _containerHeight = 120;
                  _containerMargin = 20;
                } else {
                  _containerHeight = 0;
                  _containerMargin = 0;
                }
              });
            })
      ];
    }
    return <Widget>[
      IconButton(
        padding: EdgeInsets.only(right: 30),
        icon: const Icon(
          Icons.search,
          size: 30,
        ),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
    ];
  }

  Widget _filterButtons(String title, String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selTypeSearch = "$filter";
          _onSearchChanged();
        });
      },
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _selTypeSearch == filter
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.6),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          "$title",
          style: TextStyle(fontFamily: "GothamBook", fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
            loadingProgress.expectedTotalBytes)
        .toStringAsFixed(2);
  }

  Future<void> _displayExerciseModalBottom(
      BuildContext context, DocumentSnapshot exercise) async {
    return showModalBottomSheet(
        backgroundColor: Colors.grey[850],
        context: context,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            height: 500,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: AspectRatio(
                aspectRatio: 0.5,
                child: Image.network(exercise["video"], loadingBuilder:
                    (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Carregando exercício: ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Gotham"),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "${_calculateProgress(loadingProgress)}%",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 30,
                              fontFamily: "GothamBold"),
                        ),
                      ),
                    ],
                  ));
                }, fit: BoxFit.contain),
              ),
            ),
          );
        });
  }

  Future<void> _addRequest(BuildContext context) async {
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
              'Para continuar vendo exercícios um anúncio aparecerá',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "GothamBook",
                  fontSize: 20,
                  height: 1.1),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    interstitialAdMuscle.show();
                    Navigator.pop(context);
                  },
                  child: Text("Ok",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Gotham",
                        fontSize: 18,
                      )))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Scaffold(
          drawer: addMode ? null : CustomDrawer(2, padding),
          appBar: AppBar(
            title: _isSearching
                ? _buildSearchField()
                : Text(
                    "Exercícios",
                    style: TextStyle(fontFamily: "GothamBold", fontSize: 30),
                    maxLines: 2,
                  ),
            actions: _buildActions(),
            leading: (addMode && exeId != null) ? Container() : null,
            centerTitle: true,
          ),
          backgroundColor: Color(0xff313131),
          body: Column(
            children: [
              AnimatedContainer(
                margin: EdgeInsets.only(top: _containerMargin),
                width: MediaQuery.of(context).size.width * 0.8,
                height: _containerHeight,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: GridView(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 0.5,
                      childAspectRatio: 0.4),
                  children: [
                    _filterButtons("Título", "title"),
                    _filterButtons("Bíceps", "biceps"),
                    _filterButtons("Peitoral", "peitoral"),
                    _filterButtons("Fazer em casa", "home_exe"),
                    _filterButtons("Costas", "costas"),
                    _filterButtons("Tríceps", "triceps"),
                    _filterButtons("Abdomen", "abdomen"),
                    _filterButtons("Pernas", "pernas"),
                    _filterButtons("Ombros", "ombros"),
                  ],
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(7),
                      itemCount: _resultList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            (index % 6 == 0 && index != 0)
                                ? Container(
                                    height: 120,
                                    padding: EdgeInsets.all(10),
                                    child: NativeAdmob(
                                      adUnitID: nativeAdUnitId(),
                                      controller: _controller,
                                    ),
                                  )
                                : Container(),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _isSearching = false;
                                  _containerHeight = 0;
                                  _containerMargin = 0;
                                });
                                if (addMode) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      settings:
                                          RouteSettings(name: "/adicionar"),
                                      builder: (context) => ExerciseDetail(
                                          _resultList[index],
                                          set,
                                          addMode,
                                          qntdExe,
                                          treinoId,
                                          exeId,
                                          authId,
                                          title,
                                          padding)));
                                } else {
                                  if (_isInterstitialAdReady && adClick >= 5) {
                                    await _addRequest(context);
                                    adClick = 0;

                                    _displayExerciseModalBottom(
                                        context, _resultList[index]);

                                    interstitialAdMuscle.load();
                                  } else {
                                    adClick++;
                                    _displayExerciseModalBottom(
                                        context, _resultList[index]);
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(10.0)),
                                  color: Theme.of(context).primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(
                                          2, 5), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: AutoSizeText(
                                        _resultList[index]["title"]
                                            .toString()
                                            .toUpperCase(),
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 25,
                                            height: 1.1,
                                            fontFamily: "Gotham"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    AutoSizeText(
                                      _resultList[index]["muscleId"]
                                          .toString()
                                          .toUpperCase(),
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.1,
                                          fontFamily: "GothamBook"),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            index + 1 == _resultList.length
                                ? SizedBox(
                                    height: 60,
                                  )
                                : SizedBox(
                                    height: 0,
                                  )
                          ],
                        );
                      })),
            ],
          )),
    );
  }
}
