import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:parcours_test/screens/Delivery/location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'order_traking_page.dart';

String apiKey = 'AIzaSyAmvTfGjEbkHZvla_wJmkeVm63T8m_0guo';
const List<Widget> numberDeliveries = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
];

class InputDelivery extends StatefulWidget {
  const InputDelivery({super.key});

  @override
  State<InputDelivery> createState() => _InputDeliveryState();
}

final googleMapsPlaces = GoogleMapsPlaces(apiKey: apiKey);

class _InputDeliveryState extends State<InputDelivery> {
  final List<bool> _selectedNumberDeliveries = <bool>[true, false, false];
  bool vertical = false;
  int _selectedDeliveries = 1;

  Completer<GoogleMapController> _controller = Completer();

  TextEditingController deliveryOneController = TextEditingController();
  TextEditingController deliveryTwoController = TextEditingController();
  TextEditingController deliveryThreeController = TextEditingController();

  final TextEditingController sourceAddressController = TextEditingController();
  final TextEditingController destinationAddressController =
      TextEditingController();

  late GoogleMapController mapController;
  MapType _currentMapType = MapType.normal;
  LatLng _center = LatLng(47.22001245928995, -1.5626921574356325);

  // Stocker les coordonnées
  Map<String, LatLng> deliveryCoordinates = {};
  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLng = <LatLng>[];
  double _calculatedDistance = 0;
  int _scooterTravelTime = 0;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  // Trouver la position adresse de livraison
  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
              northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
          25),
    );
    print('ddddddddddddddddddddddddddddddddddddddddddddddd');
    print(LatLng(lat, lng));
    print('ddddddddddddddddddddddddddddddddddddddddddddddd');
    _setMarker(LatLng(lat, lng));
  }

  Future<void> _addDeliveryMarker(String address) async {
    // 2. Appeler le service pour récupérer les détails du lieu
    var place = await LocationService().getPlace(address);

    // 3. Récupérer la latitude et longitude
    var lat = place['geometry']['location']['lat'];
    var lng = place['geometry']['location']['lng'];

    // 4. Créer le marqueur
    var marker =
        Marker(markerId: MarkerId('delivery'), position: LatLng(lat, lng));

    // 5. Ajouter au set de marqueurs
    setState(() {
      _markers.add(marker);

      // Enregistrer les coordonnées
      deliveryCoordinates[address] = LatLng(lat, lng);
    });
  }

/*
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
*/
  @override
  void initState() {
    super.initState();

    _setMarker(LatLng(47.22007288680556, -1.5627102019549326));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('marker'),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)),
      );
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLng,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouvelle livraison"),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 900),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Nombre de livraisons à effectuer"),
                    ToggleButtons(
                      direction: vertical ? Axis.vertical : Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          _selectedDeliveries = index + 1;
                          for (int i = 0;
                              i < _selectedNumberDeliveries.length;
                              i++) {
                            _selectedNumberDeliveries[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.red[700],
                      selectedColor: Colors.white,
                      fillColor: Colors.red[200],
                      color: Colors.red[400],
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 80.0,
                      ),
                      isSelected: _selectedNumberDeliveries,
                      children: numberDeliveries,
                    ),
                  ],
                ),
                TextField(
                  controller: sourceAddressController,
                  enabled: false, // Désactive la modification
                  decoration: InputDecoration(
                      hintText: "Lieu de départ",
                      suffixIcon: Icon(Icons.location_on),
                      labelText: '31 Pl. Viarme, 44000 Nantes'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AutocompleteAddress(
                        controller: deliveryOneController,
                        hintText: "Adresse de livraison 1",
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: _selectedDeliveries >= 2,
                  child: Column(
                    children: [
                      AutocompleteAddress(
                        controller: deliveryTwoController,
                        hintText: "Adresse de livraison 2",
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _selectedDeliveries >= 3,
                  child: AutocompleteAddress(
                    controller: deliveryThreeController,
                    hintText: "Adresse de livraison 3",
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      sourceAddressController.text =
                          '31 Pl. Viarme, 44000 Nantes';
                      var directions = await LocationService().getDirections(
                          sourceAddressController.text,
                          deliveryOneController.text);
                      _goToPlace(
                          directions['start_location']['lat'],
                          directions['start_location']['lng'],
                          directions['bounds_ne'],
                          directions['bounds_sw']);
                      await _addDeliveryMarker(deliveryOneController.text);
                      _setPolyline(directions['polyline_decoded']);

                      // Calculer la distance et la durée en scooter
                      final result =
                          await LocationService().calculateDistanceAndDuration(
                        sourceAddressController.text,
                        deliveryOneController.text,
                      );

                      // Mettre à jour la distance calculée et la durée en scooter
                      setState(() {
                        _calculatedDistance = result['distance'];
                        _scooterTravelTime = result['duration'];
                      });
                    },
                    child: Text('Recherche')),
                Text(
                  _calculatedDistance > 0
                      ? 'Distance calculée : ${_calculatedDistance.toStringAsFixed(2)} km'
                      : '',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _scooterTravelTime > 0
                      ? 'Temps de parcours en scooter : ${(_scooterTravelTime / 60).toStringAsFixed(0)} minutes'
                      : '',
                  style: TextStyle(fontSize: 16),
                ),
                Flexible(
                  child: Card(
                    child: Expanded(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        //polylines: {_kPolyline},
                        mapType: _currentMapType,
                        initialCameraPosition:
                            CameraPosition(target: _center, zoom: 15.0),
                        markers: _markers,
                        polygons: _polygons,
                        polylines: _polylines,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text("Valider"),
                  onPressed: () async {
                    sourceAddressController.text =
                        '31 Pl. Viarme, 44000 Nantes';
                    var directions = await LocationService().getDirections(
                        sourceAddressController.text,
                        deliveryOneController.text);

                    Map<String, LatLng> coordinates = {
                      'start': LatLng(directions['start_location']['lat'],
                          directions['start_location']['lng']),
                      'delivery1':
                          deliveryCoordinates[deliveryOneController.text]!,
                      // Ajoutez les coordonnées des autres adresses de livraison si nécessaires
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingPage(
                          coordinates:
                              coordinates, // Passez les coordonnées à la nouvelle page
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutocompleteAddress extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const AutocompleteAddress({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 3) {
          return const Iterable<String>.empty();
        }

        final response =
            await googleMapsPlaces.autocomplete(textEditingValue.text);
        final suggestions = response.predictions
            .map((prediction) => prediction.description ?? '')
            .toList();

        return suggestions;
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldController,
          textCapitalization: TextCapitalization.words,
          focusNode: fieldFocusNode,
          onChanged: (value) {
            // Vous pouvez éventuellement appeler le onFieldSubmitted ici
            // si vous voulez déclencher la recherche après chaque changement de texte
          },
          decoration: InputDecoration(
            hintText: hintText,
          ),
          onSubmitted: (value) {
            // Appeler la méthode de recherche ici si nécessaire
          },
        );
      },
    );
  }
}
