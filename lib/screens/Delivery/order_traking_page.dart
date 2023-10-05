import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'delivery_confirmation.dart';

class OrderTrackingPage extends StatefulWidget {
  final Map<String, LatLng> coordinates;
  final double distance;
  final int tempsParcours;
  const OrderTrackingPage({
    Key? key,
    required this.coordinates,
    required this.distance,
    required this.tempsParcours,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List laps = [];

  // Fonction stop
  void stop() {
    timer!.cancel();
    setState(() {
      started = false;
    });
  }

  void addLaps() {
    String lap = "$digitHours:$digitMinutes:$digitSeconds";
    setState(() {
      laps.add(lap);
    });
  }

  // Fonction start
  void start() {
    started = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if (localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }
      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
      });
    });
  }

  late LatLng startLocation;
  late LatLng deliveryLocation;

  final String key = 'AIzaSyAmvTfGjEbkHZvla_wJmkeVm63T8m_0guo';
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  bool isLoading = true;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  BitmapDescriptor currentLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
        isLoading = false;
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );

        setState(() {});
      },
    );
  }

  void getPolyPoints(sourceLocation, destination) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  // Page Confirmation
  void navigateToConfirmationPage() {
    stop(); // Arrêter le chronomètre avant de naviguer
    String message = "Livraison bien effectuée!";
    String timeElapsed = "$digitHours:$digitMinutes:$digitSeconds";
    String distanceCovered =
        "X km"; // Remplacez X par la distance réelle parcourue
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => DeliveryConfirmationPage(
        message: message,
        timeElapsed: timeElapsed,
        distanceCovered: distanceCovered,
      ),
    ));
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_current.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
  }

  @override
  void initState() {
    startLocation = widget.coordinates['start']!;
    deliveryLocation = widget.coordinates['delivery1']!;
    getCurrentLocation();
    getPolyPoints(startLocation, deliveryLocation);
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: isLoading
          ? const Center(child: Text("Loading"))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          zoom: 14.5,
                        ),
                        polylines: {
                          Polyline(
                            polylineId: PolylineId("route"),
                            points: polylineCoordinates,
                            color: Colors.red,
                            width: 6,
                          ),
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId("currentLocation"),
                            position: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                            icon: currentLocationIcon,
                          ),
                          Marker(
                              markerId: MarkerId("source"),
                              position: startLocation,
                              icon: sourceIcon),
                          Marker(
                            markerId: MarkerId("destination"),
                            position: deliveryLocation,
                            icon: destinationIcon,
                          ),
                        },
                        onMapCreated: (mapController) {
                          _controller.complete(mapController);
                        },
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.1,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Distance restant à parcourir : km",
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Chrnomètre",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "$digitHours:$digitMinutes:$digitSeconds",
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToConfirmationPage,
        backgroundColor:
            Colors.blue.withOpacity(0.5), // Couleur bleue transparente
        icon: Icon(Icons.check), // Icône de vérification
        label: Text("Valider Arrivée"), // Texte du bouton
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
