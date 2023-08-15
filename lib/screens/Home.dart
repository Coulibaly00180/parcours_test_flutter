import 'package:flutter/material.dart';
import 'package:parcours_test/widgets/screens/card.dart';
import 'Delivery/inputDelivery.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Card 1
            Expanded(
              child: MyCard(title: 'Nombre de livraison', value: '100'),
            ),

            // Card 2
            Expanded(
              child: MyCard(title: 'Temps parcours moyen', value: '14'),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Card 3
            Expanded(
              child: MyCard(title: 'Distance parcouru ce mois', value: '100'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InputDelivery(),
                ),
              );
            },
            child: Text("Nouvelle livraison"),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
