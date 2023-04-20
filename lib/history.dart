import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Historial {
  final double bpm;
  final double avg;
  Timestamp timestamp;

  Historial({required this.bpm, required this.avg, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'bpm': bpm,
      'avg': avg,
      'fecha': timestamp,
    };
  }
}

Future<void>guardarHistorial(double bpm, double avg) async {
  Historial historial = Historial(
    bpm: bpm,
    avg: avg,
    timestamp: Timestamp.now(),
  );

  // Creamos una nueva colección con el ID del documento como marca de tiempo
  CollectionReference historialRef = FirebaseFirestore.instance.collection('historial');
  DocumentReference historialDocRef = historialRef.doc(Timestamp.now().toDate().toString());

  // Agregamos un nuevo documento a la nueva colección con los datos del historial
  await historialDocRef.set(historial.toMap());
}

class HistorialPage extends StatefulWidget {
  const HistorialPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late Stream<QuerySnapshot> _historialStream;

  //Getter para el Stream de historial
  Stream<QuerySnapshot> get historialStream => _historialStream;

  //Setter para el Stream de historial
  set historialStream(Stream<QuerySnapshot> value) {
    setState(() {
      _historialStream = value;
    });
  }

  @override
  void initState() {
    super.initState();
    historialStream =
        FirebaseFirestore.instance.collection('historial').orderBy('fecha', descending: true).snapshots();
  }

 void onNewPulseDetected(double bpm, double avg) {
  // Guarda los valores en una nueva colección con la marca de tiempo como ID del documento
  guardarHistorial(bpm, avg);

  // Actualiza el stream de datos para que se reflejen los cambios en el widget
  historialStream =
      FirebaseFirestore.instance.collection('historial').orderBy('fecha', descending: true).snapshots();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(135, 37, 42, 34),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(135, 37, 42, 34),
        title: const Text('Historial'),
        automaticallyImplyLeading: false,
      ),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: historialStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Cargando...');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              Timestamp timestamp = data['fecha'] as Timestamp;
              DateTime dateTime = timestamp.toDate();
              String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
              return ListTile(
                leading: const Icon(Icons.favorite,
                color: Colors.red,),
                title: Text('Fecha: $formattedDateTime',
                style: const TextStyle(color: Colors.white),),
                subtitle: Text('BPM: ${data['bpm']}, AVG: ${data['avg']}',
                style:  const TextStyle(color: Colors.white),),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
