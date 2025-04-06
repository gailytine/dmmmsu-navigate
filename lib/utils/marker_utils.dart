import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:dmmmsu_navigate/utils/geojson_utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'getter_utils.dart';

Future<List<Map<String, dynamic>>> getOutdoorAllPoints(int campusId) async {
  // Execute both functions concurrently
  final results = await Future.wait([
    getEntrancePoints(campusId),
    getMarkerPoints(campusId),
  ]);

  // print("ENTRANCES: ${getEntrancePoints(campusId)}");

  // Combine the lists
  List<Map<String, dynamic>> combinedList = [...results[0], ...results[1]];

  return combinedList;
}

Future<List<Map<String, dynamic>>> getAllIndoorPoints(
    int buildingId, int floorId) async {
  // Execute both functions concurrently
  final results = await Future.wait([
    getStairsMarkers(floorId),
    getOfficesMarkers(floorId),
    getOfficesEntrancePoints(floorId),
    getBuildingEntrancePoints(buildingId),
    // getMarkerPoints(),
  ]);

  // var entrances = getOfficesEntrancePoints(floorId);

  // print("ENTRANCES: ${entrances[0]}");

  // Combine the lists
  List<Map<String, dynamic>> combinedList = [
    ...results[0],
    ...results[1],
    ...results[2],
    ...results[3]
  ];

  print("STAIR CENTROID: ${results[0]}");

  return combinedList;
}

Future<void> updateOutdoorMarkerLayer(MapboxMap mapboxMap, int campusId) async {
  await mapboxMap.style.isStyleLoaded();

  List<Map<String, dynamic>> markerPoints = await getOutdoorAllPoints(campusId);
  Map<String, dynamic> markerFeatures = await createMarkerFeature(markerPoints);

  // print("Features: $markerFeatures");

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("outdoor-marker-source");
  print("🔍 Marker Source Exists: $sourceExists");

  if (sourceExists) {
    GeoJsonSource? source = await mapboxMap.style
        .getSource("outdoor-marker-source") as GeoJsonSource?;
    source?.updateGeoJSON(jsonEncode(markerFeatures));
    print("✅ Features updated");
  } else {
    print(
        "⚠️ Marker source does not exist! Make sure to initialize the layer first.");
  }
}

Future<void> updateIndoorMarkerLayer(
    MapboxMap mapboxMap, int buildingId, int? floorId) async {
  await mapboxMap.style.isStyleLoaded();

  List<Map<String, dynamic>> markerPoints =
      await getBuildingEntrancePoints(buildingId);

  if (floorId != null) {
    markerPoints = await getAllIndoorPoints(buildingId, floorId);
  } else {
    markerPoints = await getBuildingEntrancePoints(buildingId);
  }

  Map<String, dynamic> markerFeatures = await createMarkerFeature(markerPoints);

  print("MEOW: $markerFeatures");

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("indoor-marker-source");
  // print("🔍 Marker Source Exists: $sourceExists");

  if (sourceExists) {
    GeoJsonSource? source = await mapboxMap.style
        .getSource("indoor-marker-source") as GeoJsonSource?;
    source?.updateGeoJSON(jsonEncode(markerFeatures));
    print("✅ Features updated");
  } else {
    print(
        "⚠️ Marker source does not exist! Make sure to initialize the layer first.");
  }
}

Future<void> insertOustideImages(MapboxMap mapboxMap) async {
  await addMarkerImage(
      mapboxMap, "admin", "assets/images/markers/building.png");
  await addMarkerImage(
      mapboxMap, "library", "assets/images/markers/library.png");
  await addMarkerImage(
      mapboxMap, "medical", "assets/images/markers/medical.png");
  await addMarkerImage(mapboxMap, "re", "assets/images/markers/re.png");
  await addMarkerImage(
      mapboxMap, "canteen", "assets/images/markers/canteen.png");

  await addMarkerImage(mapboxMap, "ccs", "assets/images/markers/ccs.png");
  await addMarkerImage(mapboxMap, "ce", "assets/images/markers/ce.png");
  await addMarkerImage(mapboxMap, "cchams", "assets/images/markers/cchams.png");
  await addMarkerImage(mapboxMap, "cas", "assets/images/markers/cas.png");
  await addMarkerImage(mapboxMap, "com", "assets/images/markers/com.png");
  await addMarkerImage(mapboxMap, "cgs", "assets/images/markers/cgs.png");
  await addMarkerImage(mapboxMap, "cf", "assets/images/markers/cf.png");
  await addMarkerImage(mapboxMap, "ca", "assets/images/markers/ca.png");

  await addMarkerImage(mapboxMap, "bb", "assets/images/markers/basketball.png");
  await addMarkerImage(mapboxMap, "vb", "assets/images/markers/volleyball.png");
  await addMarkerImage(mapboxMap, "tc", "assets/images/markers/tennis.png");
  await addMarkerImage(mapboxMap, "sc", "assets/images/markers/sepak.png");
  await addMarkerImage(mapboxMap, "oval", "assets/images/markers/oval.png");
  await addMarkerImage(mapboxMap, "pool", "assets/images/markers/pool.png");

  await addMarkerImage(mapboxMap, "water", "assets/images/markers/water.png");
  await addMarkerImage(mapboxMap, "field", "assets/images/markers/field.png");
  await addMarkerImage(mapboxMap, "stage", "assets/images/markers/stage.png");
  await addMarkerImage(mapboxMap, "entrance", "assets/images/markers/gate.png");
}

Future<void> insertInsideImages(MapboxMap mapboxMap) async {
  await addMarkerImage(
      mapboxMap, "building-entrance", "assets/images/markers/entrance.png");
  await addMarkerImage(
      mapboxMap, "office-entrance", "assets/images/markers/door.png");
  await addMarkerImage(
      mapboxMap, "stair-up", "assets/images/markers/stairs_up.png");
  await addMarkerImage(
      mapboxMap, "stair-down", "assets/images/markers/stairs_down.png");
  await addMarkerImage(mapboxMap, "office", "assets/images/markers/office.png");
  await addMarkerImage(
      mapboxMap, "canteen", "assets/images/markers/canteen.png");
}

Future<void> insertNavigationImages(MapboxMap mapboxMap) async {
  await addMarkerImage(
      mapboxMap, "destination", "assets/images/markers/entrance.png");
  await addMarkerImage(mapboxMap, "user", "assets/images/markers/door.png");
}

Future<void> addMarkerImage(
    MapboxMap mapboxMap, String type, String assetPath) async {
  bool hasImage = await mapboxMap.style.hasStyleImage("marker-$type");

  if (!hasImage) {
    try {
      // Load the custom marker image
      final ByteData imageData = await rootBundle.load(assetPath);
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      // Decode the image to get its dimensions
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final width = image.width;
      final height = image.height;

      final MbxImage markerImage = MbxImage(
        width: width,
        height: height,
        data: imageBytes,
      );

      // Add the image to the Mapbox style
      await mapboxMap.style.addStyleImage(
        "marker-$type",
        1.0, // Scale factor
        markerImage,
        false, // Not an SDF
        [],
        [],
        null,
      );

      print("✅ Marker image marker-$type added successfully!");
    } catch (e) {
      print("❌ Failed to load marker image: $e");
    }
  }
}
