import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/View/widgets/toggle.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class WhiteCard extends StatelessWidget {
  WhiteCard(this.rampa, this.blocked);

  final Rampa rampa;
  final bool blocked;
  @override
  Widget build(BuildContext context) {
    var date = DateTime.fromMillisecondsSinceEpoch(rampa.dataAdicionado);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return Dismissible(
      direction: blocked ? DismissDirection.none : DismissDirection.horizontal,
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          print('start to end');
          try {
            await FirebaseFirestore.instance
                .collection('rampas')
                .doc(rampa.id)
                .set({
              'review': true,
              'approved': false,
              'assessment': false,
            }, SetOptions(merge: true));
            print('Rampa added to Firebase');
          } catch (e) {
            print('Error adding rampa to Firebase: $e');
          }
        } else {
          try {
            // Replace 'rampaId' with the actual ID of the rampa you want to delete
            await firebase_storage.FirebaseStorage.instance
                .refFromURL(rampa.foto)
                .delete();

            await FirebaseFirestore.instance
                .collection('rampas')
                .doc(rampa.id)
                .delete();
            print('Rampa deleted from Firebase');
          } catch (e) {
            print('Error deleting rampa from Firebase: $e');
          }
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.0),
        margin: EdgeInsets.symmetric(vertical: 10.0),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.symmetric(vertical: 10.0),
      ),
      child: Card(
        elevation: 4, // Adjust the elevation for the drop shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15), // Adjust the border radius for rounded corners
        ),
        color: Colors.white,
        child: Container(
          //width: 200, // Adjust the width of the card as needed
          height: 130, // Adjust the height of the card as needed
          // Add your content here
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(rampa.foto,
                                height: 80.0, width: 80.0, fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              rampa.coordenadas[0].toString(),
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Logitude',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              rampa.coordenadas[1].toString(),
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text("Adicionado em ${formattedDate}")
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Inclinação',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ToggleSwitch(
                    index: rampa.inclinacao,
                    selector: true,
                    id: rampa.id,
                    blocked: blocked,
                  ),
                  Spacer(),
                  Text(
                    'Condição',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ToggleSwitch(
                      index: rampa.condicao,
                      selector: false,
                      id: rampa.id,
                      blocked: blocked),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
