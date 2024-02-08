import 'package:flutter/material.dart';
import 'package:rampi_mapeador/View/widgets/toggle.dart';

class WhiteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png',
                          height: 70.0,
                          width: 70.0,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '-29.6918198',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'Logitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '-53.8022449',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      )
                    ],
                  ),
                  Text("Adicionado em 22/22/2222")
                ],
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Inclinação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ToggleSwitch(),
                Text(
                  'Condição',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ToggleSwitch(),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
