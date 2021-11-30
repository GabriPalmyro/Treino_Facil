import 'package:flutter/material.dart';

class VisualizarExercicio extends StatefulWidget {
  final String video;
  VisualizarExercicio(this.video);

  @override
  _VisualizarExercicioState createState() => _VisualizarExercicioState();
}

class _VisualizarExercicioState extends State<VisualizarExercicio> {
  String _calculateProgress(ImageChunkEvent loadingProgress) {
    return ((loadingProgress.cumulativeBytesLoaded * 100) /
            loadingProgress.expectedTotalBytes)
        .toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.grey[900],
      height: height * 0.8,
      child: Column(
        children: [
          SizedBox(
            height: 18,
          ),
          Container(
            width: width * 0.7,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: AspectRatio(
              aspectRatio: 0.8,
              child: Image.network(widget.video, loadingBuilder:
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
        ],
      ),
    );
  }
}
