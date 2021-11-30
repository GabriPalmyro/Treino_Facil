import 'package:flutter/material.dart';

class ChangeLevelAlert extends StatefulWidget {
  const ChangeLevelAlert({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChangeLevelAlertState();
}

class ChangeLevelAlertState extends State<ChangeLevelAlert>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.ease);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  String selectedLevel;
  String selectedId;

  List<String> levels = <String>['Iniciante', 'Avançado'];
  List<String> levelId = <String>[
    "owNiAMA7DN9trhiK3nDp",
    "RGwqW8GwUoNwnCem1KAH"
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            height: height * 0.4,
            width: width * 0.8,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Atualização realizada!\nTalvez seja necessário reiniciar para atualizar.',
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: width < 990 ? width * 0.8 : 700,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        return levelId[0];
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0XFFeb2020)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Ok',
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
