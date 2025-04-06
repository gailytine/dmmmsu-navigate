import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dmmmsu_navigate/utils/layers_utils.dart';
import 'package:dmmmsu_navigate/utils/marker_utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dmmmsu_navigate/global_variable.dart';

import '../../database/local_database/queries.dart';

import '../../config/change_notifier.dart';

import '../../utils/polygon_utils.dart';
import '../../utils/polygon_animation_utils.dart';
import '../../utils/getter_utils.dart';
import '../../utils/map_utils.dart';
import '../../utils/geojson_utils.dart';
import '../../utils/location_utils.dart';

Future<void> addBuildingPolygon(MapboxMap mapboxMap, int campusId) async {
  List<Map<String, dynamic>> polygons = await fetchBuildings(campusId);
  final geoJsonData = await createBuildingFeature(polygons);

  // print("ALL BUILDINGS: $geoJsonData");

  GeoJsonSource? source =
      await mapboxMap.style.getSource("building-source") as GeoJsonSource?;
  source?.updateGeoJSON(jsonEncode(geoJsonData));

  // printBuildingSourceData(mapboxMap);
}

Future<void> addVenuePolygon(MapboxMap mapboxMap, int campusId) async {
  List<Map<String, dynamic>> polygons = await fetchVenues(campusId);
  final geoJsonData = await createVenueFeature(polygons);

  print("ALL VENUES: $geoJsonData");

  GeoJsonSource? source =
      await mapboxMap.style.getSource("venue-source") as GeoJsonSource?;
  source?.updateGeoJSON(jsonEncode(geoJsonData));
}

Future<void> updateOverlayForBuilding(
    MapboxMap mapboxMap, List<List<List<double>>> buildingCoordinates) async {
  await mapboxMap.style.setStyleLayerProperty(
    "overlay-layer",
    "fill-opacity",
    0.7,
  );
  // Define a world-covering polygon (outer boundary)
  List<List<List<double>>> worldPolygon = [
    [
      [-180.0, -90.0],
      [180.0, -90.0],
      [180.0, 90.0],
      [-180.0, 90.0],
      [-180.0, -90.0]
    ]
  ];

  // Ensure the buildingCoordinates is correctly formatted
  if (buildingCoordinates.isEmpty || buildingCoordinates[0].isEmpty) {
    print("Invalid building coordinates!");
    return;
  }

  // Ensure the floorCoordinates is correctly formatted
  // if (floorCoordinates.isEmpty || floorCoordinates[0].isEmpty) {
  //   print("Invalid floor coordinates!");
  //   return;
  // }

  // Debugging output
  // print("Building Coordinates: $buildingCoordinates");
  // print("Floor Coordinates: $floorCoordinates");

  // Create a polygon with holes for the building and floors
  Map<String, dynamic> overlayGeoJson = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [
            worldPolygon[0], // Outer boundary (world polygon)
            buildingCoordinates[0], // Building as a hole in the world polygon
            // ...floorCoordinates, // Floors as holes within the building
          ]
        }
      }
    ]
  };

  // Debugging output
  print("Overlay GeoJSON: ${jsonEncode(overlayGeoJson)}");

  // Update the GeoJSON source with the new overlay
  await mapboxMap.style.setStyleSourceProperty(
    "overlay-source",
    "data",
    jsonEncode(overlayGeoJson), // Pass the GeoJSON as a JSON-encoded string
  );

  print("Overlay updated with building and floor holes.");
}

Future<void> showFloorPolygon(
    MapboxMap mapboxMap, Map<String, dynamic> geoJsonData) async {
  await mapboxMap.style.setStyleLayerProperty(
    "floor-layer",
    "fill-opacity",
    0.0,
  );

  await mapboxMap.style.setStyleSourceProperty(
    "floor-source",
    "data",
    jsonEncode(geoJsonData),
  );

  animateFloorFadeIn(mapboxMap);
}

Future<void> showOfficePolygons(
    MapboxMap mapboxMap, Map<String, dynamic> geoJsonData) async {
  await mapboxMap.style.setStyleLayerProperty(
    "office-layer",
    "fill-opacity",
    1.0,
  );

  // Update the existing office-source with new polygons
  await mapboxMap.style.setStyleSourceProperty(
    "office-source",
    "data",
    jsonEncode(geoJsonData),
  );
}

Future<void> showStairsPolygons(MapboxMap mapboxMap, int? floorId) async {
  List<Map<String, dynamic>> polygons = await getStairs(floorId);

  if (polygons.isNotEmpty) {
    Map<String, dynamic> geoJsonData = await createStairFeature(polygons);

    await mapboxMap.style.setStyleLayerProperty(
      "stair-layer",
      "fill-opacity",
      1.0,
    );

    await mapboxMap.style.setStyleSourceProperty(
      "stair-source",
      "data",
      jsonEncode(geoJsonData),
    );
  }
}

Future<Map<String, dynamic>?> onBuildingTap(
  MapContentGestureContext context,
  MapboxMap mapboxMap,
  CameraOptions camera,
  int campusId,
  AppStateNotifier loadingState,
) async {
  Map<String, dynamic>? building = await getTappedBuilding(context, mapboxMap);
  int floorNum = 1;

  print("Building Tapped data: $building");

  if (building == null) {
    // No building selected, hide the overlay
    await hideOverlay(mapboxMap);
    return null;
  }

  var buildingName = building['properties']['name'];
  var buildingRawId = building['id'];
  var buildingGeometry = Map<String, dynamic>.from(building['geometry']);

  // Fix: Ensure buildingCentroid is a List<dynamic>
  var buildingCentroid = building['properties']['centroid'];
  if (buildingCentroid is String) {
    buildingCentroid = jsonDecode(buildingCentroid);
  }
  buildingCentroid = buildingCentroid as List<dynamic>;

  // Fix: Ensure buildingEntrances is a List<dynamic>
  // Replace the current entrance parsing with:
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

  if (buildingName == null) return null;

  // Step 1: Bound the camera to the building
  await boundBuildingCamera(
      mapboxMap, camera, buildingGeometry, buildingCentroid, loadingState);

  // Step 2: Set isLoading to true after bounding the box
  loadingState.setLoading(true);

  // Step 3: Fetch additional data (e.g., floors, offices, etc.)
  bool buildingHasFloors = building['properties']['hasFloors'];
  int buildingId = extractID(buildingRawId, 'building-');
  String? buildingImgName = await fetchBuildingImgName(buildingId); 


  int totalFloors = await countBuildingFloors(buildingId);
  List<Map<String, dynamic>> allBuildingFloors =
      await fetchAllBuildingFloors(buildingId);

  List<Map<String, dynamic>> allOffices =
      await fetchAllOfficesForBuilding(buildingId);

  Map<String, dynamic>? floorInfo = await handleBuildingIndoor(
      mapboxMap, buildingId, floorNum, buildingHasFloors);

  List<List<List<double>>> buildingCoordinates;
  try {
    buildingCoordinates = parseCoordinates(buildingGeometry['coordinates']);
  } catch (e) {
    print("Failed to parse building coordinates: $e");
    return null;
  }

  print("IMAGE NAME: $buildingImgName, IMG ID: $buildingId"); 

  await updateOverlayForBuilding(mapboxMap, buildingCoordinates);

  print("PARSED ENTRANCES: $entranceCoordinates");

  return {
    "id": buildingId,
    "imgName" : buildingImgName, 
    "name": buildingName,
    "entrances": entranceCoordinates,
    "centroid": buildingCentroid, // Useful for UI updates
    "floorId": floorInfo?['floorId'] ?? null,
    "allFloors": allBuildingFloors,
    "hasFloors": buildingHasFloors,
    "totalFloorNum": totalFloors,
    "officesInfo": allOffices, // Use the fetched offices here
  };
}

Future<Map<String, dynamic>?> getTappedBuilding(
    MapContentGestureContext context, MapboxMap mapboxMap) async {
  List<QueriedRenderedFeature> features =
      (await mapboxMap.queryRenderedFeatures(
    RenderedQueryGeometry.fromScreenCoordinate(
      ScreenCoordinate(x: context.touchPosition.x, y: context.touchPosition.y),
    ),
    RenderedQueryOptions(layerIds: ["building-layer"]),
  ))
          .whereType<QueriedRenderedFeature>()
          .toList();

  if (features.isEmpty) return null;

  // Extract feature properties as a standard Map<String, dynamic>
  final feature = features.first.queriedFeature.feature;
  // print("Tapped FEATURE: $feature");

  return feature.map((key, value) => MapEntry(key.toString(), value));
}

Future<void> checkTapBlockedByOverlay(
    MapContentGestureContext context, MapboxMap mapboxMap) async {
  ScreenCoordinate point = ScreenCoordinate(
    x: context.touchPosition.x,
    y: context.touchPosition.y,
  );

  List<QueriedRenderedFeature> overlayFeatures =
      (await mapboxMap.queryRenderedFeatures(
    RenderedQueryGeometry.fromScreenCoordinate(point),
    RenderedQueryOptions(
        layerIds: ["map-overlay-layer"]), // Checking overlay layer
  ))
          .whereType<QueriedRenderedFeature>()
          .toList();

  if (overlayFeatures.isNotEmpty) {
    print("Tap is blocked by the overlay.");
  } else {
    print("Tap is NOT blocked by the overlay.");
  }
}

Future<void> boundBuildingCamera(
    MapboxMap mapboxMap,
    CameraOptions camera,
    Map buildingGeometry,
    List<dynamic> buildingCentroid,
    AppStateNotifier loadingState) async {
  // Calculate the bounding box and new camera position
  var boundingBox =
      getBoundingBox(List.from(buildingGeometry['coordinates'][0]));
  var (expandedSW, expandedNE) = expandBoundingBox(
    boundingBox['sw']!,
    boundingBox['ne']!,
    200,
    19,
    1080,
    1920,
  );

  // List<dynamic> polygonCentroid = getPolygonCentroid(List.from(buildingGeometry['coordinates'][0]));
  Point newPosition = fromListToPoint(buildingCentroid);

  // Step 1: Smoothly zoom into the building
  await updateCameraPosition(newPosition, mapboxMap, camera, 20);

  loadingState.setAnimation(true);

  await Future.delayed(Duration(milliseconds: 2000));

  await boundMap(mapboxMap, expandedSW, expandedNE, 21, 20);
  loadingState.setAnimation(false);
}

Future<List<Map<String, dynamic>>> fetchAllOfficesForBuilding(
    int buildingId) async {
  // Fetch all floors for the building
  List<Map<String, dynamic>> allBuildingFloors =
      await fetchAllBuildingFloors(buildingId);

  // List to store all offices
  List<Map<String, dynamic>> allOffices = [];

  // Loop through each floor
  for (var floor in allBuildingFloors) {
    final floorId = floor['id'] as int; // Assuming each floor has an 'id' field
    final floorNum = floor['floor_num']
        as int; // Assuming each floor has a 'floor_num' field

    // Fetch offices for the current floor
    List<Map<String, dynamic>> officesForFloor =
        await fetchAllFloorsOffices(floorId);

    // Add floorId and floorNum to each office and add to the allOffices list
    for (var office in officesForFloor) {
      List<Map<String, dynamic>> personnel = await fetchPersonnel(office['id']);

      allOffices.add({
        'id': office['id'],
        'name': office['name'],
        'floorId': floorId,
        'floorNum': floorNum, // Add floor_num to the office data
        'personnel': personnel,
      });
    }
  }

  return allOffices;
}

Future<Map<String, dynamic>?> handleBuildingIndoor(MapboxMap mapboxMap,
    int buildingId, int floorNum, bool buildingHasFloors) async {
  // Map<String, dynamic>? selectedBuildingFloor =
  //     await getFloors(buildingId, floorNum);

  // print("SELECTED BUILDING FLOOR: $selectedBuildingFloor");
  // print("BUILDING ID: $buildingId");

  if (buildingHasFloors) {
    Map<String, dynamic> selectedBuildingFloor =
        await getFloors(buildingId, floorNum);
    Map<String, dynamic> floorFeature =
        createFloorFeature(selectedBuildingFloor);
    int floorId = extractID(floorFeature['id'], 'floor-');

    print("FLOOR FEATURE: $floorId");
    Map<String, dynamic> selectedFloor = {
      'id': floorId,
      'floorNum': floorNum,
    };

    List<Map<String, dynamic>> selectedFloorOffices = await getOffices(floorId);
    Map<String, dynamic> officesFeature =
        await createOfficeFeature(selectedFloorOffices);

    print("SELECTED FLOOR OFFICES: $selectedFloorOffices");
    List<Map<String, dynamic>> officeList = selectedFloorOffices.map((office) {
      return {
        'id': office['id'],
        'name': office['name'],
        'floorId': floorId,
      };
    }).toList();

    await updateIndoorMarkerLayer(mapboxMap, buildingId, floorId);
    await showOfficePolygons(mapboxMap, officesFeature);
    await showStairsPolygons(mapboxMap, floorId);
    await showFloorPolygon(mapboxMap, floorFeature);

    return {'floorId': floorId, 'officesInfo': officeList};
  } else {
    // totalFloors = await countBuildingFloors(buildingId);
    // selectedBuildingHasFloors = false;
    updateIndoorMarkerLayer(mapboxMap, buildingId, null);
    return null;
  }
}

Future<void> onFloorSwitch(MapboxMap mapboxMap, int buildingId,
    int selectedFloor, bool buildingHasFloors) async {
  clearIndoorLayers(mapboxMap);
  // print("SELECTED FLOOR: $selectedFloor");
  await handleBuildingIndoor(
      mapboxMap, buildingId, selectedFloor, buildingHasFloors);
}

// Add to your utils/map_utils.dart
