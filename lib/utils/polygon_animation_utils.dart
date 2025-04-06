import 'dart:async';
import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'polygon_utils.dart';
import 'color_utils.dart'; 

Future<void> fadeOutSymbols(MapboxMap mapboxMap, String layerId) async {
  for (double opacity = 1.0; opacity >= 0.0; opacity -= 0.1) {
    await mapboxMap.style.setStyleLayerProperty(
      layerId,
      'icon-opacity',
      opacity,
    );
    await mapboxMap.style.setStyleLayerProperty(
      layerId,
      'text-opacity',
      opacity,
    );
    await Future.delayed(Duration(milliseconds: 100)); // Smooth transition
  }

  // Finally, set visibility to 'none' when fully faded
  await mapboxMap.style.setStyleLayerProperty(layerId, 'visibility', 'none');
}

Future<void> fadeInSymbols(MapboxMap mapboxMap, String layerId) async {
  await mapboxMap.style.setStyleLayerProperty(layerId, 'visibility', 'visible');

  for (double opacity = 0.0; opacity <= 1.0; opacity += 0.1) {
    await mapboxMap.style
        .setStyleLayerProperty(layerId, 'icon-opacity', opacity);
    await mapboxMap.style
        .setStyleLayerProperty(layerId, 'text-opacity', opacity);
    await Future.delayed(Duration(milliseconds: 100));
  }
}

void animateFloorFadeIn(MapboxMap mapboxMap) {
  double opacity = 0.0;
  const double targetOpacity = 1.0;
  const int duration = 500;
  const int steps = 10;
  int stepTime = duration ~/ steps;

  Timer.periodic(Duration(milliseconds: stepTime), (timer) async {
    if (opacity >= targetOpacity) {
      timer.cancel();
    } else {
      opacity += 1.0 / steps;
      await mapboxMap.style.setStyleLayerProperty(
        "floor-layer",
        "fill-opacity",
        opacity,
      );
    }
  });
}

void animateOverlayFadeIn(MapboxMap mapboxMap) {
  double opacity = 0.0;
  const double targetOpacity = 0.7;
  const int duration = 500;
  const int steps = 10;
  int stepTime = duration ~/ steps;

  Timer.periodic(Duration(milliseconds: stepTime), (timer) async {
    if (opacity >= targetOpacity) {
      timer.cancel();
    } else {
      opacity += targetOpacity / steps;
      await mapboxMap.style.setStyleLayerProperty(
        "screen-overlay-layer",
        "fill-opacity",
        opacity,
      );
    }
  });
}

void animateOverlayFadeOut(MapboxMap mapboxMap) {
  double opacity = 1; // Start from fully visible overlay
  const double targetOpacity = 0.0; // Fade out to 0
  const int duration = 500;
  const int steps = 10;
  int stepTime = duration ~/ steps;

  Timer.periodic(Duration(milliseconds: stepTime), (timer) async {
    if (opacity <= targetOpacity) {
      timer.cancel();
      await mapboxMap.style.setStyleLayerProperty(
        "screen-overlay-layer",
        "visibility",
        "none", // ✅ Hide the layer completely when fade-out is done
      );
    } else {
      opacity -= 1 / steps;
      await mapboxMap.style.setStyleLayerProperty(
        "screen-overlay-layer",
        "fill-opacity",
        opacity,
      );
    }
  });
}



// Future<bool> animateBorderExpansion(
//     MapboxMap mapboxMap, String featureId, String buildingId) async {
//   GeoJsonSource? source =
//       await mapboxMap.style.getSource("border-building-source") as GeoJsonSource?;

//   if (source == null) {
//     print("❌ Border source not found!");
//     return false;
//   }

//   // Get current GeoJSON data
//   var geoJsonData = await source.data;
//   if (geoJsonData is! Map<String, dynamic>) {
//     print("❌ GeoJSON data is not in expected format!");
//     return false;
//   }

//   // Find the building feature in GeoJSON
//   List<dynamic> features = geoJsonData["features"];
//   var buildingFeature = features.firstWhere(
//       (feature) => feature["properties"]["id"] == buildingId,
//       orElse: () => null);

//   if (buildingFeature == null) {
//     print("❌ No matching building found for ID: $buildingId");
//     return false;
//   }

//   // Animate `line-width` smoothly
//   double currentLineWidth = buildingFeature["properties"]["line-width"] ?? 3.0;
//   double targetLineWidth = currentLineWidth == 3.0 ? 8.0 : 3.0;

//   // Define animation duration and steps
//   int animationDuration = 300; // in milliseconds
//   int steps = 10;
//   double stepSize = (targetLineWidth - currentLineWidth) / steps;

//   for (int i = 0; i < steps; i++) {
//     // Update the line-width gradually
//     buildingFeature["properties"]["line-width"] = currentLineWidth + (stepSize * i);

//     // Update the source with modified GeoJSON
//     await source.updateGeoJSON(geoJsonData);

//     // Wait for a short duration to create the animation effect
//     await Future.delayed(Duration(milliseconds: animationDuration ~/ steps));
//   }

//   // Ensure the final value is set
//   buildingFeature["properties"]["line-width"] = targetLineWidth;
//   await source.updateGeoJSON(geoJsonData);

//   print("✅ Border animation applied! New width: $targetLineWidth");
//   return true;
// }


// Future<void> animateBuildingExpansion(
//     MapboxMap mapboxMap, String sourceId, Object featureId, Map<String, dynamic> geoJsonData) async {
//   var style = mapboxMap.style;

//   var geoJsonSource = await style.getSource(sourceId) as GeoJsonSource?;

//   if (geoJsonSource != null) {
//     double expansionFactor = 1.05;
//     int steps = 3; // Fewer steps for quick response
//     int delayMs = 5; // Very short delay for fast effect

//     var featureToUpdate = geoJsonData["features"].firstWhere(
//       (f) => f["id"] == featureId,
//       orElse: () => null,
//     );

//     if (featureToUpdate != null) {
//       List<dynamic> originalCoordinates =
//           featureToUpdate["geometry"]["coordinates"][0];

//       // Expand once (no back-and-forth animation)
//       for (int i = 0; i <= steps; i++) {
//         double ratio = i / steps;
//         List<dynamic> animatedCoordinates =
//             expandPolygon(originalCoordinates, 1 + (expansionFactor - 1) * ratio);

//         featureToUpdate["geometry"]["coordinates"] = [animatedCoordinates];

//         await style.updateGeoJSONSourceFeatures(
//           sourceId,
//           featureId.toString(),
//           [Feature.fromJson(featureToUpdate)],
//         );

//         await Future.delayed(Duration(milliseconds: delayMs));
//       }

//       print("✅ Quick expansion completed!");
//     } else {
//       print("⚠️ Error: Feature with ID $featureId not found.");
//     }
//   } else {
//     print("⚠️ Error: GeoJSON source not found.");
//   }
// }



// Future<void> highlightSelectedBuilding(MapboxMap mapboxMap, String featureId) async {
//   var existingSource = await mapboxMap.style.getSource("building-source");

//   if (existingSource is GeoJsonSource) {
//     // Fetch current building data
//     List<Map<String, dynamic>> polygons = await fetchBuildings();
//     Map<String, dynamic> geoJsonData = await convertDBtoJSON(polygons, 'building');

//     // Modify the GeoJSON to highlight the selected building
//     for (var feature in geoJsonData['features']) {
//       if (feature['properties'] == null) {
//         feature['properties'] = {}; // Ensure properties is not null
//       }

//       if (feature['id'] == featureId) {
//         feature['properties']['isSelected'] = true;  // Set selected building
//       } else {
//         feature['properties']['isSelected'] = false; // Reset others
//       }
//     }

//     // Update the GeoJSON source with modified data
//     await existingSource.updateGeoJSON(jsonEncode(geoJsonData));
//   } else {
//     print("Building source not found or incorrect type.");
//   }
// }
