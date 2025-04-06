import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dmmmsu_navigate/utils/layers_utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../database/local_database/queries.dart';

import '../../config/change_notifier.dart';

import '../../utils/map_utils.dart';
import '../../utils/location_utils.dart';
import '../screens/map/polygon_screen.dart';

Future<Map<String, dynamic>?> findBuildingById(
  int buildingId,
  MapboxMap mapboxMap,
  CameraOptions camera,
  int campusId,
  AppStateNotifier loadingState,
) async {
  try {
    // Step 1: Fetch initial data and zoom into the building
    final initialData =
        await fetchBuildingAndZoom(buildingId, mapboxMap, camera, loadingState);

    if (initialData == null) {
      return null;
    }

    // Step 2: Process the rendered feature for bounding, overlaying, etc.
    final buildingData =
        await processRenderedBuilding(mapboxMap, initialData, loadingState);

    return buildingData;
  } catch (e) {
    debugPrint("Error in findBuildingById: $e");
    return null;
  }
}

Future<Map<String, dynamic>?> findFeatureInSource(
  MapboxMap mapboxMap,
  String sourceId,
  int featureId,
) async {
  // Define a filter to find the feature by its ID
  final String filter = jsonEncode([
    "==",
    ["get", "id"], // Assuming "id" is the property for the feature ID
    featureId,
  ]);

  // Query the source features
  final List<QueriedSourceFeature?> features =
      await mapboxMap.querySourceFeatures(
    sourceId,
    SourceQueryOptions(filter: filter),
  );

  // Filter out null values
  final List<QueriedSourceFeature> nonNullFeatures =
      features.whereType<QueriedSourceFeature>().toList();

  if (nonNullFeatures.isEmpty) return null;

  // Extract the first matching feature
  final feature = nonNullFeatures.first.queriedFeature.feature;

  return feature.map((key, value) => MapEntry(key.toString(), value));
}

Future<Map<String, dynamic>?> findFeatureInRendered(
  MapboxMap mapboxMap,
  String layerId,
  String featureId, // Change to String
) async {
  try {
    // Get the current camera state
    final cameraState = await mapboxMap.getCameraState();

    // Get the current camera center (as a Point)
    final cameraCenter = cameraState.center;

    // Convert the geographic coordinates (Point) to screen coordinates (ScreenCoordinate)
    final screenCoordinate = await mapboxMap.pixelForCoordinate(
      Point(
        coordinates: Position(
          cameraCenter.coordinates.lng,
          cameraCenter.coordinates.lat,
        ),
      ),
    );

    // Query the rendered features at the current camera center
    final List<QueriedRenderedFeature?> features =
        await mapboxMap.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
      RenderedQueryOptions(layerIds: [layerId]),
    );

    // Filter out null values and cast to non-nullable list
    final List<QueriedRenderedFeature> nonNullFeatures =
        features.whereType<QueriedRenderedFeature>().toList();

    // Find the feature by its ID
    for (var feature in nonNullFeatures) {
      final queriedFeature = feature.queriedFeature.feature;
      if (queriedFeature['id'] == featureId) {
        // Compare with the full ID
        return queriedFeature
            .map((key, value) => MapEntry(key.toString(), value));
      }
    }

    // If no feature is found, return null
    debugPrint("Feature with ID $featureId not found.");
    return null;
  } catch (e) {
    debugPrint("Error querying rendered features: $e");
    return null;
  }
}

Future<Map<String, dynamic>?> fetchBuildingAndZoom(
  int buildingId,
  MapboxMap mapboxMap,
  CameraOptions camera,
  AppStateNotifier loadingState,
) async {
  try {
    // Step 1: Fetch building details by ID from the source
    Map<String, dynamic>? building =
        await findFeatureInSource(mapboxMap, 'building-source', buildingId);

    print("Building Data from Source: $building");

    if (building == null) {
      // No building found, hide the overlay
      await hideOverlay(mapboxMap);
      return null;
    }

    var buildingName = building['properties']['name'];
    var buildingCentroid = jsonDecode(building['properties']['centroid']);
    List<dynamic> buildingEntrances = building['properties']['entrances'];

    if (buildingName == null) return null;

    // Step 2: Smoothly zoom into the building
    Point newPosition = fromListToPoint(buildingCentroid);
    await updateCameraPosition(newPosition, mapboxMap, camera, 20);

    loadingState.setAnimation(true);

    // Wait for the camera animation to complete
    await Future.delayed(Duration(milliseconds: 2000));

    List<List<double>> entranceCoordinates = [];
    try {
      final rawEntrances = building['properties']['entrances'] ?? [];
      if (rawEntrances is List<List<double>>) {
        // Old format
        entranceCoordinates = rawEntrances;
      } else if (rawEntrances is List) {
        // New format or mixed format
        entranceCoordinates = rawEntrances
            .map((e) {
              if (e is List) return e.cast<double>();
              if (e is Map) return (e['coordinates'] as List).cast<double>();
              return <double>[];
            })
            .where((e) => e.length == 2)
            .toList();
      }
    } catch (e) {
      print("Error parsing entrances: $e");
    }

    // Return the initial data for further processing
    return {
      "id": buildingId,
      "name": buildingName,
      "centroid": buildingCentroid,
      "entrances": entranceCoordinates,
    };
  } catch (e) {
    debugPrint("Error in fetchBuildingAndZoom: $e");
    return null;
  }
}

Future<Map<String, dynamic>?> processRenderedBuilding(
  MapboxMap mapboxMap,
  Map<String, dynamic> initialData,
  AppStateNotifier loadingState,
) async {
  try {
    final buildingId = initialData['id'];

    // Step 1: Query the rendered features after zooming
    final renderedFeature = await findFeatureInRendered(
        mapboxMap, 'building-layer', 'building-$buildingId');

    if (renderedFeature == null) {
      debugPrint("Feature not found in rendered features.");
      return null;
    }

    // Step 2: Use the rendered feature's geometry and properties
    var renderedGeometry = renderedFeature['geometry'];
    var renderedProperties = renderedFeature['properties'];

    // Step 3: Bound the map to the building
    var boundingBox =
        getBoundingBox(List.from(renderedGeometry['coordinates'][0]));
    var (expandedSW, expandedNE) = expandBoundingBox(
      boundingBox['sw']!,
      boundingBox['ne']!,
      200,
      19,
      1080,
      1920,
    );

    await boundMap(mapboxMap, expandedSW, expandedNE, 22, 20);
    loadingState.setAnimation(false);

    // Add a delay to ensure the map has fully rendered the feature
    await Future.delayed(
        Duration(milliseconds: 500)); // Adjust the delay as needed

    // Step 4: Set isLoading to true after bounding the box
    loadingState.setLoading(true);

    // Step 5: Fetch additional data (e.g., floors, offices, etc.)
    bool buildingHasFloors = renderedProperties['hasFloors'];
    int totalFloors = await countBuildingFloors(buildingId);
    List<Map<String, dynamic>> allBuildingFloors =
        await fetchAllBuildingFloors(buildingId);
    List<Map<String, dynamic>> allOffices =
        await fetchAllOfficesForBuilding(buildingId);

    int floorNum = 1; // Default to the first floor
    Map<String, dynamic>? floorInfo = await handleBuildingIndoor(
        mapboxMap, buildingId, floorNum, buildingHasFloors);

    List<List<List<double>>> buildingCoordinates;
    try {
      buildingCoordinates = parseCoordinates(renderedGeometry['coordinates']);
    } catch (e) {
      print("Failed to parse building coordinates: $e");
      return null;
    }

    // Step 6: Update the map overlay for the building
    await updateOverlayForBuilding(mapboxMap, buildingCoordinates);

    // Combine initial data with additional data
    return {
      ...initialData,
      "floorId": floorInfo?['floorId'] ?? null,
      "allFloors": allBuildingFloors,
      "hasFloors": buildingHasFloors,
      "totalFloorNum": totalFloors,
      "officesInfo": allOffices, // Use the fetched offices here
    };
  } catch (e) {
    debugPrint("Error in processRenderedBuilding: $e");
    return null;
  }
}
