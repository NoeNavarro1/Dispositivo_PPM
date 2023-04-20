import 'dart:async';

import 'package:bluetooh/sensor.dart';
import 'package:bluetooh/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: const Color.fromARGB(134, 7, 3, 63),
        home: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              if (snapshot.data == BluetoothState.on) {
                return const FindDevicesScreen();
              }
              return BluetoothOffScreen(
                snapshot.requireData,
                state: snapshot.requireData,
              );
            }));
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen(BluetoothState? data,
      {Key? key, required this.state})
      : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 5, 93),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(135, 37, 42, 34),
      appBar: AppBar(
        title: const Text('Dispositivos'),
        backgroundColor: const Color.fromARGB(135, 37, 42, 34),
        leading: const Icon(Icons.bluetooth),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(
                              d.name,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255), // Cambiar a tu color deseado
                              ),
                            ),
                            subtitle: Text(
                              d.id.toString(),
                              style: const TextStyle(
                                 color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              ),

                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {}
                                return Text(
                                  snapshot.data.toString(),
                                  style: const TextStyle(
                                     color: Color.fromARGB(255, 254, 0, 0),
                                  ),);
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return SensorPage(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.requireData) {
            return FloatingActionButton(
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: const Color.fromARGB(248, 188, 3, 3),
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 20, 72, 176),
                child: const Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: const Duration(seconds: 10)));
          }
        },
      ),
    );
  }
}
