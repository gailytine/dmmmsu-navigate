import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';

import 'getter_utils.dart';
import 'geojson_utils.dart';
import '../database/local_database/queries.dart'; 

Future<void> updateRouteLayer(MapboxMap mapboxMap, int campusId) async {
  await mapboxMap.style.isStyleLoaded();

  final sourceId = 'route-source';

  // Fetch grouped route points
  List<List<Position>> groupedRoutes = await getGroupedRoutePoints(campusId);
  if (groupedRoutes.isEmpty) return;

  // Create MultiLineString GeoJSON
  Map<String, dynamic> geoJsonData =
      await createMultiRouteFeature(groupedRoutes);

  print("ROUTE FEATURE: $geoJsonData");
  bool sourceExists = await mapboxMap.style.styleSourceExists(sourceId);
  if (sourceExists) {
    GeoJsonSource? source =
        await mapboxMap.style.getSource(sourceId) as GeoJsonSource?;
    if (source != null) {
      print(
          "📡 Source before update: ${await mapboxMap.style.getStyleSourceProperties(sourceId)}"); // Debug
      await source.updateGeoJSON(jsonEncode(geoJsonData));
      print("✅ Route updated!");
      print(
          "📡 Source after update: ${await mapboxMap.style.getStyleSourceProperties(sourceId)}"); // Debug
    } else {
      print("🚨 Failed to retrieve source!");
    }
  } else {
    print("⚠️ Route source does not exist! Make sure to initialize it.");
  }
}

Future<void> debugRouteSource(MapboxMap mapboxMap) async {
  final sourceId = 'route-source';

  bool sourceExists = await mapboxMap.style.styleSourceExists(sourceId);
  print("🔍 Route Source Exists: $sourceExists");

  if (sourceExists) {
    String sourceProps =
        await mapboxMap.style.getStyleSourceProperties(sourceId);
    print("📡 Route Source Properties: $sourceProps");
  } else {
    print("🚨 Route Source is missing!");
  }
}

Future<void> debugRouteLayer(MapboxMap mapboxMap) async {
  final layerId = 'route-layer';

  bool layerExists = await mapboxMap.style.styleLayerExists(layerId);
  print("🔍 Route Layer Exists: $layerExists");

  if (layerExists) {
    String layerProps = await mapboxMap.style.getStyleLayerProperties(layerId);
    print("🛠 Route Layer Properties: $layerProps");
  } else {
    print("🚨 Route Layer is missing!");
  }
}

List<List<double>> convertToPolygonPoints(List<Map<String, dynamic>> points) {
  return points.map((point) {
    return [point['longitude'] as double, point['latitude'] as double];
  }).toList();
}

Future<void> updatePointLayer(MapboxMap mapboxMap, int campusId) async {
  await mapboxMap.style.isStyleLoaded();

  const sourceId = "route-points-source";

  // Fetch points from the database
  List<Map<String, dynamic>> points = await fetchAllRoutePoints(campusId);

  // Convert to GeoJSON format
  Map<String, dynamic> geoJsonData = {
    "type": "FeatureCollection",
    "features": points.map((point) {
      return {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [point["longitude"], point["latitude"]],
        },
        "properties": {
          "title": point["id"].toString(), // Ensure ID is a string
        },
      };
    }).toList(),
  };

  print("📌 POINTS W LABEL: $geoJsonData"); // Debugging output

  bool sourceExists = await mapboxMap.style.styleSourceExists(sourceId);
  if (sourceExists) {
    GeoJsonSource? source = await mapboxMap.style.getSource(sourceId) as GeoJsonSource?;
    if (source != null) {
      await source.updateGeoJSON(jsonEncode(geoJsonData));
      print("✅ Route Points Updated!");
    }
  } else {
    print("⚠️ Route Points Source Not Found! Creating new source...");
    await mapboxMap.style.addSource(GeoJsonSource(
      id: sourceId,
      data: jsonEncode(geoJsonData),
    ));
  }
}
