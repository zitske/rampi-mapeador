import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  ToggleSwitch(
      {super.key,
      required this.index,
      required this.id,
      required this.selector});
  final int index;
  final dynamic id;
  final bool selector;
  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 0;
              if (widget.selector) {
                editarInclinacao(widget.id);
              } else {
                editarCondicao(widget.id);
              }
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF0000),
              border: Border.all(
                color: selectedIndex == 0 ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 1;
              if (widget.selector) {
                editarInclinacao(widget.id);
              } else {
                editarCondicao(widget.id);
              }
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE500),
              border: Border.all(
                color: selectedIndex == 1 ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 2;
              if (widget.selector) {
                editarInclinacao(widget.id);
              } else {
                editarCondicao(widget.id);
              }
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF80FF00),
              border: Border.all(
                color: selectedIndex == 2 ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> editarInclinacao(dynamic id) async {
    try {
      // Replace 'rampaId' with the actual ID of the rampa you want to edit
      await FirebaseFirestore.instance
          .collection('rampas')
          .doc(widget.id)
          .update({'inclinacao': selectedIndex});
      print('Rampa edited on Firebase');
    } catch (e) {
      print('Error editing rampa on Firebase: $e');
    }
  }

  Future<void> editarCondicao(dynamic id) async {
    try {
      // Replace 'rampaId' with the actual ID of the rampa you want to edit
      await FirebaseFirestore.instance
          .collection('rampas')
          .doc(widget.id)
          .update({'condicao': selectedIndex});
      print('Rampa edited on Firebase');
    } catch (e) {
      print('Error editing rampa on Firebase: $e');
    }
  }
}
