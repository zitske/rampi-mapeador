import 'package:flutter/material.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';

class ToggleSwitch extends StatefulWidget {
  ToggleSwitch(
      {super.key,
      required this.index,
      required this.id,
      required this.selector,
      required this.blocked});
  final int index;
  final dynamic id;
  final bool selector;
  final bool blocked;
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
            if (!widget.blocked) {
              setState(() {
                selectedIndex = 0;
                if (widget.selector) {
                  editarInclinacao(widget.id);
                } else {
                  editarCondicao(widget.id);
                }
              });
            }
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
            if (!widget.blocked) {
              setState(() {
                selectedIndex = 1;
                if (widget.selector) {
                  editarInclinacao(widget.id);
                } else {
                  editarCondicao(widget.id);
                }
              });
            }
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
            if (!widget.blocked) {
              setState(() {
                selectedIndex = 2;
                if (widget.selector) {
                  editarInclinacao(widget.id);
                } else {
                  editarCondicao(widget.id);
                }
              });
            }
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
      await SupabaseService.client
          .from('rampas')
          .update({'inclinacao': selectedIndex}).eq('id', widget.id);
      print('Rampa edited on Supabase');
    } catch (e) {
      print('Error editing rampa on Supabase: $e');
    }
  }

  Future<void> editarCondicao(dynamic id) async {
    try {
      await SupabaseService.client
          .from('rampas')
          .update({'condicao': selectedIndex}).eq('id', widget.id);
      print('Rampa edited on Supabase');
    } catch (e) {
      print('Error editing rampa on Supabase: $e');
    }
  }
}
