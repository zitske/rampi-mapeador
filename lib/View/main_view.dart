import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rampi_mapeador/Model/add_rampa.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/View/widgets/card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('rampas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasData) {
                  return Center(
                    child: Text('Nenhuma rampa cadastrada.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        print(snapshot.data?.docs[index].data());
                        return WhiteCard(
                          Rampa(
                            coordenadas: snapshot.data?.docs[index]
                                ['coordenadas'],
                            dataAdicionado: snapshot.data?.docs[index]
                                ['data_adicionado'],
                            inclinacao: snapshot.data?.docs[index]
                                ['inclinacao'],
                            condicao: snapshot.data?.docs[index]['condicao'],
                            foto: snapshot.data?.docs[index]['foto'],
                            id: snapshot.data!.docs[index].id,
                          ),
                        );
                      }),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          adicionar();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
