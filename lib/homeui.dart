import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'history.dart';

class HomeUI extends StatefulWidget {
  final double bpm;
  final double avg;
  const HomeUI({
    Key? key,
    required this.bpm,
    required this.avg,
  }) : super(key: key);
  @override

  // ignore: library_private_types_in_public_api
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(135, 37, 42, 34),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.help,
                    size: 30,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor:
                           const Color.fromARGB(255, 255, 255, 255),
                        title: const Text('Consejo'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: const <Widget>[
                              Text('Las pulsaciones normales en reposo pueden variar de persona a persona, pero en general, las siguientes son las pulsaciones por minuto (ppm) consideradas normales por edad:'),
                              Text(''),
                              Text('Niños de 3 a 4 años: 80-120 ppm.'),
                              Text(''),
                              Text('Niños de 5 a 6 años: 75-115 ppm.'),
                              Text(''),
                              Text('Niños de 7 a 9 años: 70-110 ppm.'),
                              Text(''),
                              Text('Más de 10 años: 60-100 ppm.'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history_outlined,
                    size: 30,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistorialPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: SvgPicture.asset(
                "assets/roof.svg",
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  // left: 5,
                  // right: 5,
                  ),
              // child: Container(
              //   decoration: BoxDecoration(
              //       color: const Color.fromARGB(135, 37, 42, 34),
              //       border: Border.all(color: Colors.black)),
              // width: double.infinity,
              child: Column(
                children: [
                  SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                              trackWidth: 4,
                              progressBarWidth: 20,
                              shadowWidth: 40),
                          customColors: CustomSliderColors(
                              trackColor: HexColor('#F93B3B'),
                              progressBarColor: HexColor('#E71919'),
                              shadowColor: HexColor('#E71919'),
                              shadowMaxOpacity: 0.5, //);
                              shadowStep: 20),
                          infoProperties: InfoProperties(
                              bottomLabelStyle: TextStyle(
                                  color: HexColor('#F6E7E7'),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                              bottomLabelText: 'ppm',
                              mainLabelStyle: TextStyle(
                                  color: HexColor('#F6E7E7'),
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w600),
                              modifier: (double value) {
                                return '${widget.bpm}';
                              }),
                          startAngle: 90,
                          angleRange: 360,
                          size: 200.0,
                          animationEnabled: true),
                      min: 0.0,
                      max: 200.0,
                      initialValue: widget
                          .bpm //esto hace que se produzca la animacion del widget
                      ),
                  const SizedBox(
                    height: 30,
                  ),
                  SleekCircularSlider(
                    appearance: CircularSliderAppearance(
                        customWidths: CustomSliderWidths(
                            trackWidth: 4,
                            progressBarWidth: 20,
                            shadowWidth: 40),
                        customColors: CustomSliderColors(
                            trackColor: HexColor('#03A5C5'),
                            progressBarColor: HexColor('#41B3CA'),
                            shadowColor: HexColor('#41B3CA'),
                            shadowMaxOpacity: 0.5, //);
                            shadowStep: 20),
                        infoProperties: InfoProperties(
                            bottomLabelStyle: TextStyle(
                                color: HexColor('#F6E7E7'),
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                            bottomLabelText: 'Promedio',
                            mainLabelStyle: TextStyle(
                                color: HexColor('#F6E7E7'),
                                fontSize: 30.0,
                                fontWeight: FontWeight.w600),
                            modifier: (double value) {
                              return '${widget.avg}';
                            }),
                        startAngle: 90,
                        angleRange: 360,
                        size: 200.0,
                        animationEnabled: true),
                    min: 0.0,
                    max: 200.0,
                    initialValue: widget.avg,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    icon: const Icon(
                      Icons.info,
                      size: 30,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      title: const Text('Nota sobre mediciones'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: const <Widget>[
            Text('1)El rango de medicion de este dispositivo es del 20 a 200 latidos por minuto (PPM).'),
            Text(''),
            Text('2)Algunos factores externos pueden afectar la precisión, como la circulación sanguínea, la posición del sensor en el dedo, temperatura , luz ambiental y la interferencia electromagnetica.' ),
            Text(''),
            Text('3)Los resultados de la medición son solo para referencia y no intentan ser fundamento para un diagnóstico médico.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
},

                    
                  ),
                ],
              ),
            ),
            //),
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
