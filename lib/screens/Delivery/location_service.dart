import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class LocationService {
  final String key = 'AIzaSyAmvTfGjEbkHZvla_wJmkeVm63T8m_0guo';

  Future<String> getPlaceId(String input) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);
    
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
        .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    return results;
  }

  
  Future<int> getScooterTravelTime(String origin, String destination) async {

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json' +
      '?origin=$origin' +
      '&destination=$destination' +
      '&mode=scooter' +
      '&key=$key'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final durationInSeconds = data['routes'][0]['legs'][0]['duration']['value'];
      return durationInSeconds;
    } else {
      throw Exception('Failed to fetch travel time');
    }
  }

  Future<Map<String, dynamic>> calculateDistanceAndDuration(String origin, String destination) async {
    
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json' +
      '?origins=$origin' +
      '&destinations=$destination' +
      '&mode=scooter' +
      '&key=$key'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final elements = data['rows'][0]['elements'][0];

      final distance = elements['distance']['value'] / 1000;  // En kilomètres
      final duration = elements['duration']['value'];  // En secondes

      return {'distance': distance, 'duration': duration};
    } else {
      throw Exception('Failed to fetch distance and duration');
    }
  }
}