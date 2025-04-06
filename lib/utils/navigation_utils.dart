import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:dmmmsu_navigate/global_variable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dmmmsu_navigate/models.dart';
import 'package:dmmmsu_navigate/utils/color_utils.dart';
// import 'package:flutter/material.dart';

import '../database/local_database/queries.dart';

double haversine(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Earth radius in meters

  // Convert degrees to radians
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in meters
}

double _toRadians(double degrees) {
  return degrees * (pi / 180);
}

List<double>? findNearestEntrance(
    List<List<double>>? entrances, Point userLocation) {
  List<double>? nearestEntrance;
  double minDistance = double.infinity;

  if (entrances != null) {
    for (var entrance in entrances) {
      print("ENTRANCE IN BUILDINGS: $entrance");

      double entranceLon = entrance[0]; // Longitude
      double entranceLat = entrance[1]; // Latitude

      // Calculate distance using Haversine formula
      double distance = haversine(
        userLocation.coordinates.lat.toDouble(),
        userLocation.coordinates.lng.toDouble(),
        entranceLat,
        entranceLon,
      );

      // Update nearest entrance if this one is closer
      if (distance < minDistance) {
        minDistance = distance;
        nearestEntrance = entrance; // ✅ Just store the coordinates directly
      }
    }

    if (nearestEntrance != null) {
      print("✅ Nearest Entrance: $nearestEntrance at $minDistance meters");
    } else {
      print("⚠️ No valid entrances found.");
    }
  } else {
    print("⚠️ No entrances available for the selected building.");
  }

  return nearestEntrance; // ✅ Now returns List<double> instead of Map!
}

List<double> findNearestPolygonPoint(
    List<List<double>> polygonPoints, List<double> entranceCoordinates) {
  print("POLYGON ROUTE POINTS: $polygonPoints");
  double minDistance = double.infinity;
  List<double> nearestPoint = [];

  for (var point in polygonPoints) {
    double distance = haversine(
      entranceCoordinates[1], // Entrance latitude
      entranceCoordinates[0], // Entrance longitude
      point[1], // Polygon point latitude
      point[0], // Polygon point longitude
    );

    if (distance < minDistance) {
      minDistance = distance;
      nearestPoint = point;
    }
  }

  return nearestPoint;
}

Future<int> findNearestNode(double lat, double lon, int campusId) async {
  // Fetch all route points from the database
  List<Map<String, dynamic>> points = await fetchAllRoutePoints(campusId);

  if (points.isEmpty) {
    throw Exception("No route points found.");
  }

  int nearestNode = points.first['id']; // Default to the first point
  double minDistance = double.infinity;

  // Round the input coordinates to match database precision
  double roundedLat =
      double.parse(lat.toStringAsFixed(13)); // Match latitude precision
  double roundedLon =
      double.parse(lon.toStringAsFixed(12)); // Match longitude precision

  print("USER LOCATION (Rounded): LAT = $roundedLat, LON = $roundedLon");

  // Tolerance for near-zero distances
  double tolerance = 1e-9;

  for (var point in points) {
    // Extract latitude and longitude from the database point
    double pointLat =
        double.parse((point['latitude'] as double).toStringAsFixed(13));
    double pointLon =
        double.parse((point['longitude'] as double).toStringAsFixed(12));

    // Calculate the distance using the Haversine formula
    double distance = haversine(roundedLat, roundedLon, pointLat, pointLon);

    // Treat very small distances as zero
    if (distance < tolerance) {
      distance = 0.0;
    }

    print(
        "Checking Point ID: ${point['id']} | LAT = $pointLat, LON = $pointLon | Distance = $distance");

    // Update the nearest node if a closer one is found
    if (distance < minDistance) {
      minDistance = distance;
      nearestNode = point['id'];

      print(
          "New Nearest Node Found: ID = $nearestNode | Distance = $minDistance");
    }
  }

  print("FINAL NEAREST NODE: $nearestNode");
  return nearestNode;
}

Future<void> highlightRoute(MapboxMap mapboxMap, List<Position> route) async {
  final sourceId = 'highlighted-route-source';

  // Create a GeoJSON feature for the highlighted route
  Map<String, dynamic> geoJsonData = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": route.map((point) => [point.lng, point.lat]).toList(),
        },
        "properties": {},
      },
    ],
  };

  // Update the source with the new route
  GeoJsonSource? source =
      await mapboxMap.style.getSource(sourceId) as GeoJsonSource?;
  if (source != null) {
    await source.updateGeoJSON(jsonEncode(geoJsonData));
  }
}

Future<Map<int, List<Edge>>> buildGraph(int campusId) async {
  try {
    // Fetch all route points and lines from the database
    List<Map<String, dynamic>> points = await fetchAllRoutePoints(campusId);
    List<Map<String, dynamic>> lines = await fetchAllRouteLines(campusId);

    if (points.isEmpty || lines.isEmpty) {
      throw Exception("No route points or lines found.");
    }

    // Map to store the graph (adjacency list)
    Map<int, List<Edge>> graph = {};

    // Step 1: Build initial graph with direct connections based on lines
    for (var line in lines) {
      int lineId = line['id']; // Get the line ID
      String pointIdsString = line['point_ids'] as String;
      List<int> pointIds = pointIdsString.split(',').map(int.parse).toList();

      // Connect points in the order defined by the line
      for (int i = 0; i < pointIds.length - 1; i++) {
        int nodeA = pointIds[i];
        int nodeB = pointIds[i + 1];

        // Calculate the distance between nodeA and nodeB
        double distance = calculateDistanceBetweenPoints(nodeA, nodeB, points);

        // Add edges to the graph (bidirectional) if they don't already exist
        if (!graph.containsKey(nodeA)) {
          graph[nodeA] = [];
        }
        if (!graph[nodeA]!.any((edge) => edge.targetNode == nodeB)) {
          graph[nodeA]!.add(Edge(nodeB, distance, lineId));
        }

        if (!graph.containsKey(nodeB)) {
          graph[nodeB] = [];
        }
        if (!graph[nodeB]!.any((edge) => edge.targetNode == nodeA)) {
          graph[nodeB]!.add(Edge(nodeA, distance, lineId));
        }
      }
    }

    print("GRAPH: $graph");
    logGraph(graph);
    return graph;
  } catch (e) {
    print("Error in buildGraph: $e");
    rethrow;
  }
}

void logGraph(Map<int, List<Edge>> graph) {
  print("GRAPH STRUCTURE:");
  graph.forEach((node, edges) {
    String connections = edges
        .map((edge) =>
            "${edge.targetNode} (distance: ${edge.distance}, lineId: ${edge.lineId})")
        .join(", ");
    print("Node $node -> $connections");
  });

  // Log specific node (e.g., node 130)
  if (graph.containsKey(130)) {
    print("Detailed Connections for Node 130:");
    for (var edge in graph[130]!) {
      print(
          "  -> ${edge.targetNode} (distance: ${edge.distance}, lineId: ${edge.lineId})");
    }
  }
}

// void exportGraphToDot(Map<int, List<Edge>> graph, String filePath) {
//   final file = File(filePath);
//   final sink = file.openWrite();

//   sink.writeln("graph G {");
//   graph.forEach((node, edges) {
//     for (var edge in edges) {
//       sink.writeln("  $node -- ${edge.node} [label=\"${edge.distance}\"];");
//     }
//   });
//   sink.writeln("}");
//   sink.close();
// }

double calculateDistanceBetweenPoints(
    int nodeA, int nodeB, List<Map<String, dynamic>> points) {
  // Find the coordinates of nodeA and nodeB
  Map<String, dynamic>? pointA =
      points.firstWhere((point) => point['id'] == nodeA, orElse: () => {});
  Map<String, dynamic>? pointB =
      points.firstWhere((point) => point['id'] == nodeB, orElse: () => {});

  if (pointA.isEmpty || pointB.isEmpty) {
    throw Exception("Points not found for nodes $nodeA and $nodeB");
  }

  double latA = pointA['latitude'];
  double lonA = pointA['longitude'];
  double latB = pointB['latitude'];
  double lonB = pointB['longitude'];

  // Use Haversine formula to calculate distance
  double distance = haversine(latA, lonA, latB, lonB);

  print("Distance between Node $nodeA and Node $nodeB: $distance meters");

  return distance;
}

Future<double> findAndDrawRoute(MapboxMap? mapboxMap, double userLat,
    double userLon, double destLat, double destLon, int campusId) async {
  try {
    // Build the graph for navigation
    Map<int, List<Edge>> graph = await buildGraph(campusId);
    logGraph(graph);

    Graph navigationGraph = Graph(graph);

    // Find the nearest nodes
    int? userNode = await findNearestNode(userLat, userLon, campusId);
    int? destNode = await findNearestNode(destLat, destLon, campusId);

    if (userNode == null || destNode == null) {
      print("No valid nodes found for user or destination.");
      return 0.0;
    }

    // Find the shortest path
    List<int> shortestPath = navigationGraph.dijkstra(userNode, destNode);
    print("Shortest Path: $shortestPath");

    // Calculate total distance
    double totalDistance = 0.0;
    List<Position> pathCoordinates = [];
    final db = await getDatabase();

    // Get all points at once for efficiency
    final allPoints = await db.query('route_points');

    for (var i = 0; i < shortestPath.length - 1; i++) {
      final nodeId = shortestPath[i];
      final nextNodeId = shortestPath[i + 1];

      // Find current and next point
      final point = allPoints.firstWhere((p) => p['id'] == nodeId);
      final nextPoint = allPoints.firstWhere((p) => p['id'] == nextNodeId);

      // Calculate segment distance
      double lat1 = (point['latitude'] as num).toDouble();
      double lon1 = (point['longitude'] as num).toDouble();
      double lat2 = (nextPoint['latitude'] as num).toDouble();
      double lon2 = (nextPoint['longitude'] as num).toDouble();

      totalDistance += haversine(lat1, lon1, lat2, lon2);

      // Add to path coordinates
      pathCoordinates.add(Position(lon1, lat1));
      if (i == shortestPath.length - 2) {
        pathCoordinates.add(Position(lon2, lat2));
      }
    }

    print("Total Route Distance: ${totalDistance.toStringAsFixed(2)} meters");

    // Draw the route (your existing code)
    Map<String, dynamic> geoJsonData = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates":
                pathCoordinates.map((point) => [point.lng, point.lat]).toList(),
          },
          "properties": {},
        },
      ],
    };

    final sourceId = 'shortest-path-source';
    bool sourceExists = await mapboxMap!.style.styleSourceExists(sourceId);

    if (sourceExists) {
      GeoJsonSource? source =
          await mapboxMap.style.getSource(sourceId) as GeoJsonSource?;
      if (source != null) {
        await source.updateGeoJSON(jsonEncode(geoJsonData));
      }
    }

    return totalDistance;
  } catch (e) {
    print("Error in findAndDrawRoute: $e");
    return 0.0;
  }
}
