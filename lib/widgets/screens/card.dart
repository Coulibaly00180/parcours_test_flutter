import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.title, required this.value});

  // Paramètres : titre, valeur
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title), // Utiliser le paramètre
            SizedBox(height: 8),
            Text(value), // Utiliser le paramètre
          ],
        ),
      ),
    );
  }
}
// L'utiliser :
/*
Expanded(
  child: MyCard(
    title: "Nombre de livraisons", 
    value: "125"
  ), 
),
*/
