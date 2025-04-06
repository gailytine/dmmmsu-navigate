import 'dart:convert';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../database/local_database/queries.dart';

import '../../utils/geojson_utils.dart';
import '../../utils/location_utils.dart';
import '../../utils/map_utils.dart';

import '../config/change_notifier.dart';

Future<void> highlightOffice(
    MapboxMap mapboxMap, List<List<List<double>>> officeCoordinates) async {
  try {
    // 1. Create proper GeoJSON feature
    final highlightFeature = {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": officeCoordinates
      },
      "properties": {}
    };

    // 2. Convert to JSON string
    final geoJsonString = jsonEncode({
      "type": "FeatureCollection",
      "features": [highlightFeature]
    });

    // 3. Update existing source data
    await mapboxMap.style.setStyleSourceProperty(
      "office-outline-source", // Use your existing source ID
      "data",
      geoJsonString,
    );

  } catch (e) {
    rethrow;
  }
}

Future<int?> onOfficeTap(
  MapContentGestureContext context,
  MapboxMap mapboxMap,
  CameraOptions camera,
  AppStateNotifier appState,
) async {
  appState.setLoading(true);
  try {
    // 1. Get tapped office
    final office = await getTappedOffice(context, mapboxMap);

    print("OFFICE FEATURE: $office");
    if (office == null) return null;

    // 2. Extract and return just the ID
    final officeId = extractID(office['id'], 'office-');
    if (officeId == null) return null;

    // 3. Zoom to office
    await zoomToOffice(mapboxMap, office, camera);

    // 4. Highlight office
    final coordinates = (office['geometry']['coordinates'] as List)
        .cast<List<dynamic>>()
        .map((ring) => ring
            .cast<dynamic>()
            .map((point) => (point as List).cast<double>())
            .toList())
        .toList();
        
    await highlightOffice(mapboxMap, coordinates);

    return officeId; // Just return the integer ID
  } finally {
    appState.setLoading(false);
  }
}

Future<Map<String, dynamic>?> getTappedOffice(
    MapContentGestureContext context, MapboxMap mapboxMap) async {
  final features = (await mapboxMap.queryRenderedFeatures(
    RenderedQueryGeometry.fromScreenCoordinate(
      ScreenCoordinate(
        x: context.touchPosition.x,
        y: context.touchPosition.y,
      ),
    ),
    RenderedQueryOptions(layerIds: ["office-layer"]),
  ))
      .whereType<QueriedRenderedFeature>()
      .toList();

  if (features.isEmpty) return null;

  final feature = features.first.queriedFeature.feature;
  return feature.map((key, value) => MapEntry(key.toString(), value));
}

Future<void> zoomToOffice(MapboxMap mapboxMap, Map<String, dynamic> office,
    CameraOptions camera) async {
  final coordinates = office['geometry']['coordinates'][0][0]; // First point
  final center = Point(coordinates: Position(coordinates[0], coordinates[1]));
  await updateCameraPosition(
      center, mapboxMap, camera, 22); // Custom zoom level
}


Future<void> clearOfficeHighlight(MapboxMap mapboxMap) async {
  try {
    // Clear the highlight data
    await mapboxMap.style.setStyleSourceProperty(
      "office-outline-source",
      "data",
      jsonEncode({"type": "FeatureCollection", "features": []}),
    );

    // Optional: Hide the highlight layer
    await mapboxMap.style.setStyleLayerProperty(
      "office-outline-layer",
      "visibility",
      "none",
    );
  } catch (e) {
    // debugPrint("Error clearing office highlight: $e");
  }
}
