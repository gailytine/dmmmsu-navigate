import '../database/local_database/queries.dart';

import 'package:dmmmsu_navigate/global_variable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

//WHEN USER TAP BUILDING, THESE ARE THE GETTERS
Future<Map<String, dynamic>> getFloors(int buildingId, int floorNum) async {
  List<Map<String, dynamic>> polygons = await fetchFloors(buildingId, floorNum);

  print("FLOOR POLYGONS: $polygons FLOOR num: $floorNum");

  // print("FLOOR UNDER BUILDING $buildingId  ${polygons.length}");
  return polygons.first;
}

Future<List<Map<String, dynamic>>> getOffices(int floorId) async {
  // if (floorId == null) return [];
  List<Map<String, dynamic>> polygons = await fetchOffices(floorId);
  print("OFFICE POLYGONS: $polygons");
  return polygons;
}

Future<List<Map<String, dynamic>>> getStairs(int? floorId) async {
  if (floorId == null) return [];
  List<Map<String, dynamic>> polygons = await fetchStairs(floorId);
  return polygons;
}

Future<List<Map<String, dynamic>>> getMarkerPoints(int campusId) async {
  List<Map<String, dynamic>> markers =
      await fetchPlacesMarkers(campusId);

  print("ALL MARKERS $markers");

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    print("BUILDING TYPE:  ${marker['icon_type']}");

    return {
      'id': marker['id'],
      'name': marker['name'],
      'centroid': marker['centroid'], // Parse centroid
      'icon_type': marker['icon_type'].toLowerCase(),
      'type': marker['type'],
    };
  }).toList();

  // print("MARKERS: $markerPoints");

  return markerPoints;
}

Future<List<Map<String, dynamic>>> getEntrancePoints(int campusId) async {
  List<Map<String, dynamic>> markers =
      await fetchCampusEntrance(campusId);

  print("ALL MARKERS $markers");

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    return {
      'id': marker['id'],
      'name': marker['name'],
      'centroid': marker['coordinates'], // Parse centroid
      'icon_type': 'entrance',
    };
  }).toList();

  // print("MARKERS: $markerPoints");

  return markerPoints;
}

Future<List<Map<String, dynamic>>> getBuildingEntrancePoints(
    int buildingId) async {
  List<Map<String, dynamic>> markers = await fetchBuildingEntrances(buildingId);

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    return {
      'id': marker['id'],
      'name': marker['name'],
      'centroid': marker['coordinates'], // Parse centroid
      'icon_type': 'building-entrance',
    };
  }).toList();

  // print("MARKERS: $markerPoints");

  return markerPoints;
}

Future<List<Map<String, dynamic>>> getOfficesEntrancePoints(int floorId) async {
  List<Map<String, dynamic>> markers = await fetchOfficeEntrances(floorId);

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    return {
      'id': marker['id'],
      'centroid': marker['coordinates'], // Parse centroid
      'icon_type': 'office-entrance',
    };
  }).toList();

  print("MARKERS: $markers");

  return markerPoints;
}

Future<List<Map<String, dynamic>>> getOfficesMarkers(int floorId) async {
  List<Map<String, dynamic>> markers = await fetchOffices(floorId);

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    return {
      'id': marker['id'],
      'name': marker['name'],
      'centroid': marker['centroid'], // Parse centroid
      'icon_type': 'office',
    };
  }).toList();

  // print("MARKERS: $markerPoints");

  return markerPoints;
}

Future<List<Map<String, dynamic>>> getStairsMarkers(int floorId) async {
  List<Map<String, dynamic>> markers = await fetchStairs(floorId);

  // Extract centroid for each building
  List<Map<String, dynamic>> markerPoints = markers.map((marker) {
    return {
      'id': marker['id'],
      'name': 'F${marker['start']}',
      'centroid': marker['centroid'], // Parse centroid
      'icon_type':
          (marker['start'] < marker['end']) ? 'stair-up' : 'stair-down',
    };
  }).toList();

  print("MARKERS: $markerPoints");

  return markerPoints;
}

Future<List<List<Position>>> getGroupedRoutePoints(int campusId) async {
  final List<Map<String, dynamic>> routeLines = await fetchAllRouteLines(campusId);
  if (routeLines.isEmpty) return [];

  List<List<Position>> groupedPoints = [];

  for (var line in routeLines) {
    // print("ROUTE LINES: $line");

    String pointIdsString = line['point_ids'] as String;
    List<int> pointIds = pointIdsString.split(',').map(int.parse).toList();

    if (pointIds.isNotEmpty) {
      List<Map<String, dynamic>> pointsData = await fetchRoutePoints(pointIds);
      List<Position> positions = pointsData.map((point) {
        return Position(
          point['longitude'] as double,
          point['latitude'] as double,
        );
      }).toList();

      groupedPoints.add(positions); // Store each route as a separate list

      print("GROUPED ROUTE: $pointsData");
    }
  }

  return groupedPoints;
}
