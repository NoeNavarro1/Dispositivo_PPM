import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'history.dart';
import 'homeui.dart';


class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  // ignore: library_private_types_in_public_api
  _SensorPageState createState() {
    return _SensorPageState();
  }
}

class _SensorPageState extends State<SensorPage> {
  // ignore: non_constant_identifier_names
  String service_uuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  // ignore: non_constant_identifier_names
  String characteristic_uuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  late bool isReady;
  late Stream<List<int>> stream;
  // ignore: non_constant_identifier_names
  late List _Pulsos;
  late double _bpm = 0.0;
  late double _avg = 0.0;
  bool pulseDetected = false;

  @override
  void initState() {
    super.initState();
    isReady = false;
    _bpm = 0.0; // inicializar con 0
    _avg = 0.0; // inicializar con 0
    connectToDevice();
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  connectToDevice() async {
    // ignore: unnecessary_null_comparison
    if (widget.device == null) {
      _pop();
      return;
    }

    Timer(const Duration(seconds: 20), () {
      if (!isReady) {
        disconnectFromDevice();
        _pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    // ignore: unnecessary_null_comparison
    if (widget.device == null) {
      _pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    // ignore: unnecessary_null_comparison
    if (widget.device == null) {
      _pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    // ignore: avoid_function_literals_in_foreach_calls
    services.forEach((service) {
      if (service.uuid.toString() == service_uuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristic_uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            if (mounted) {
              setState(() {
                isReady = true;
              });
            }
          }
        }
      }
    });

    if (!isReady) {
      _pop();
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('¿Estas seguro?'),
        content: const Text('¿Quiere desconectar el dispositivo y volver?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () {
                disconnectFromDevice();
                Navigator.of(context).pop(true);
              },
              child: const Text('Si')),
        ],
      ),
    ) as bool;
  }

  _pop() {
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(135, 37, 42, 34),
        appBar: AppBar(
          title: const Text('Pulsos'),
          leading: const Icon(Icons.monitor_heart_outlined),
          backgroundColor: const Color.fromARGB(135, 37, 42, 34),
        ),
        body: Container(
            child: !isReady
                ? const Center(
                    child: Text(
                      "Espere...",
                      style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  )
                : StreamBuilder<List<int>>(
                    stream: stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<int>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      //aqui esta el error trakechath
                      if (snapshot.connectionState == ConnectionState.active) {
                        // geting data from bluetooth
                        var currentValue = _dataParser(snapshot.requireData);
                        _Pulsos = currentValue.split(",");
                        try {
                          if (_Pulsos[0] != "nan") {
                            _bpm = double.parse('${_Pulsos[0]}');
                          }
                          if (_Pulsos[1] != "nan") {
                            _avg = double.parse('${_Pulsos[1]}');
                          }
                          if (_bpm == 0.0) {
                            throw const FormatException(
                            "Por favor pon el dedo en el sensor");
                          }
                        } catch (e) {
                          // en caso de excepción, establecer los valores en cero y mostrar el mensaje
                          _bpm = 0.0;
                          _avg = 0.0;
                        }
                        guardarHistorial(_bpm, _avg);

                        return HomeUI(
                          bpm: _bpm,
                          avg: _avg,
                        );
                      } else {
                        return const Text('Check the stream');
                      }
                    },
                  )),
      ),
    );
  }
}
