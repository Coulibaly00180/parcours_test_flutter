import 'package:flutter/material.dart';
import 'inputDelivery.dart';
import 'package:parcours_test/main.dart';

class DeliveryConfirmationPage extends StatelessWidget {
  final String message;
  final String timeElapsed;
  final String distanceCovered;

  const DeliveryConfirmationPage({
    Key? key,
    required this.message,
    required this.timeElapsed,
    required this.distanceCovered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmation de la livraison"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text("Temps écoulé: $timeElapsed"),
            Text("Distance parcourue: $distanceCovered"),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Naviguer vers la page d'accueil
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ),
                    );
                  },
                  child: Text("Accueil"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Naviguer vers une nouvelle livraison (ou une autre page)
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => InputDelivery(),
                    ));
                  },
                  child: Text("Nouvelle livraison"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
