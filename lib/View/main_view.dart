import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rampi_mapeador/Controller/navigation.dart';
import 'package:rampi_mapeador/Model/add_rampa.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/View/login_view.dart';
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
    List<Widget> status = [
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rampas')
                  .where("assessment", isEqualTo: true)
                  .where('creatorId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
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
                  onRefresh: () async {},
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
                            false);
                      }),
                );
              })),
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rampas')
                  .where("review", isEqualTo: true)
                  .where('creatorId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
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
                  onRefresh: () async {},
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
                            true);
                      }),
                );
              })),
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rampas')
                  .where("approved", isEqualTo: true)
                  .where('creatorId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
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
                    //setState(() {});
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
                            true);
                      }),
                );
              })),
    ];
    final Controller c = Get.find();
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF0191E2),
            title: Text(widget.title),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá,',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          c.userName.value + ' ' + c.userLastName.value,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        Text(
                          '${c.userPoints} pontos',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              color: Colors.white),
                        )
                      ]),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ListTile(
                  title: Text('Rampas'),
                  leading: Icon(Icons.wheelchair_pickup),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Sair', style: TextStyle(color: Colors.red)),
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    c.isLogged.value = false;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
          ),
          body: status[c.index_tab.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: c.index_tab.value,
            onTap: (index) {
              c.index_tab.value = index;
              c.update();
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.reviews_outlined),
                label: 'Avaliação',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Aprovação',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Aprovadas',
              ),
            ],
            selectedItemColor: Theme.of(context).colorScheme.primary,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              adicionar();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ));
  }
}
