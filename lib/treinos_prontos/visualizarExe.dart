import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class VisualizarExeP extends StatefulWidget {
  final String video;
  final String series;
  final String reps;
  VisualizarExeP(this.video, this.series, this.reps);

  @override
  _VisualizarExePState createState() => _VisualizarExePState();
}

class _VisualizarExePState extends State<VisualizarExeP> {
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
            width: width * 0.6,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: AspectRatio(
              aspectRatio: 1,
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
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Séries',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'GothamBold',
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  AutoSizeText(
                    widget.series.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'GothamBook',
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Repetições',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'GothamBold',
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  AutoSizeText(
                    widget.reps.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'GothamBook',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
