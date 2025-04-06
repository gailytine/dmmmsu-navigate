import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dmmmsu_navigate/global_variable.dart';

import '../database/local_database/queries.dart';
import '../../utils/polygon_utils.dart';
// import '../../utils/getter_utils.dart';

List<double> stringToDoubleList(String data) {
  try {
    // Parse the string into a List<dynamic>
    List<dynamic> dynamicList = jsonDecode(data);

    // Convert List<dynamic> to List<double>
    return dynamicList.map((e) => (e as num).toDouble()).toList();
  } catch (e) {
    print("Error parsing string to List<double>: $e");
    return [];
  }
}

List<List<List<double>>> parseCoordinatesFromString(String coordinates) {
  // Decode the JSON string into a List<dynamic>
  List<dynamic> decoded = jsonDecode(coordinates);

  // Explicitly cast each level of the nested list
  return decoded.map<List<List<double>>>((outerList) {
    return (outerList as List<dynamic>).map<List<double>>((innerList) {
      return (innerList as List<dynamic>)
          .map<double>((value) => value.toDouble())
          .toList();
    }).toList();
  }).toList();
}

int extractID(Object geoJsonId, String typeId) {
  // if(geoJsonId == null) return null;

  String convertedString = geoJsonId.toString();
  if (!convertedString.startsWith(typeId)) {
    throw Exception("Invalid featureId format: $geoJsonId");
  }
  return int.parse(convertedString.replaceFirst(typeId, ''));
}

Future<Map<String, dynamic>?> fetchBuildingGeoJsonData(
    MapboxMap mapboxMap, String sourceId, Object featureId, int campusId) async {
  var geoJsonSource =
      await mapboxMap.style.getSource(sourceId) as GeoJsonSource?;

  if (geoJsonSource != null) {
    List<Map<String, dynamic>> polygons =
        await fetchBuildings(campusId);
    Map<String, dynamic> geoJsonData = await createBuildingFeature(polygons);

    geoJsonData["features"] = geoJsonData["features"].map((f) {
      return f;
    }).toList();

    return geoJsonData;
  } else {
    print("⚠️ Error: GeoJSON source not found.");
    return null;
  }
}

// Future<Map<String, dynamic>?> fetchBuildingGeoJsonData(
//   MapboxMap mapboxMap,
//   String sourceId,
//   String featureId,
// ) async {
//   var style = mapboxMap.style;

//   // Fetch the current GeoJSON data from the source
//   var geoJsonData = await style.getStyleSourceProperty(sourceId, "data");
//   if (geoJsonData == null || geoJsonData.value == null) {
//     print("⚠️ Error: GeoJSON data not found or is null.");
//     return null;
//   }

//   // Extract the value from StylePropertyValue
//   if (geoJsonData.value is String) {
//     String geoJsonString = geoJsonData.value as String;

//     // Parse the GeoJSON data
//     var geoJson = jsonDecode(geoJsonString);

//     // Find the feature to update
//     var featureToUpdate = geoJson["features"].firstWhere(
//       (f) => f["id"] == featureId,
//       orElse: () => null,
//     );

//     if (featureToUpdate == null) {
//       print("⚠️ Error: Feature with ID $featureId not found.");
//       return null;
//     }

//     return geoJson;
//   } else {
//     print("⚠️ Error: GeoJSON data is not a String.");
//     return null;
//   }
// }

Future<Map<String, dynamic>> createOfficeFeature(
    List<Map<String, dynamic>> polygons) async {
  List<Map<String, dynamic>> features = polygons.map((polygon) {
    List<dynamic> rawCoordinates = jsonDecode(polygon['coordinates']);
    List<List<double>> filteredCoordinates =
        extractMultiPolygonCoordinates(rawCoordinates);

    return {
      "type": "Feature",
      "id": "office-${polygon['id']}",
      "geometry": {
        "type": "Polygon",
        "coordinates": [filteredCoordinates],
      },
      "properties": {
        "id": polygon['id'],
        "name": polygon['name'] ?? '',
      }
    };
  }).toList();

  return {
    "type": "FeatureCollection",
    "features": features,
  };
}

Future<Map<String, dynamic>> createStairFeature(
    List<Map<String, dynamic>> polygons) async {
  List<Map<String, dynamic>> features = polygons.map((polygon) {
    List<dynamic> rawCoordinates = jsonDecode(polygon['coordinates']);
    List<List<double>> filteredCoordinates =
        extractMultiPolygonCoordinates(rawCoordinates);

    return {
      "type": "Feature",
      "id": "stair-${polygon['id']}",
      "geometry": {
        "type": "Polygon",
        "coordinates": [filteredCoordinates],
      },
      "properties": {
        "id": polygon['id'],
        "name": polygon['name'] ?? '',
      }
    };
  }).toList();

  return {
    "type": "FeatureCollection",
    "features": features,
  };
}

Map<String, dynamic> createFloorFeature(Map<String, dynamic> polygon) {
  // Decode coordinates from string to List
  List<dynamic> rawCoordinates = jsonDecode(polygon['coordinates']);
  List<List<double>> filteredCoordinates =
      extractMultiPolygonCoordinates(rawCoordinates);

  return {
    "type": "Feature",
    "id": "floor-${polygon['id']}",
    "geometry": {
      "type": "Polygon",
      "coordinates": [filteredCoordinates], // Ensure correct nesting
    },
    "properties": {
      "id": polygon['id'],
      "name": polygon['name'] ?? '',
    }
  };
}

Future<Map<String, dynamic>> createVenueFeature(
    List<Map<String, dynamic>> polygons) async {
  // Decode coordinates from string to List
  List<Map<String, dynamic>> features =
      await Future.wait(polygons.map((polygon) async {
    List<dynamic> rawCoordinates = jsonDecode(polygon['coordinates']);
    // List<List<double>> filteredCoordinates =
    //     extractMultiPolygonCoordinates(rawCoordinates);

    int venueId = polygon['id'];

    var feature = {
      "type": "Feature",
      "id": "building-$venueId",
      "geometry": {
        "type": "Polygon",
        "coordinates": [rawCoordinates],
      },
      "properties": {
        "id": venueId,
        "name": polygon['name'] ?? '',
        "venueType": polygon['type'] ?? '',
      }
    };

    print("DEBUG: Feature Created -> ${jsonEncode(feature)}");

    return feature;
  }).toList());

  var geoJSON = {
    "type": "FeatureCollection",
    "features": features,
  };

  // print("DEBUG: Final GeoJSON -> ${jsonEncode(geoJSON)}");

  return geoJSON;
}

Future<Map<String, dynamic>> createBuildingFeature(
    List<Map<String, dynamic>> polygons) async {
  List<Map<String, dynamic>> features =
      await Future.wait(polygons.map((polygon) async {
    List<dynamic> rawCoordinates = jsonDecode(polygon['coordinates']);
    // List<List<double>> filteredCoordinates =
    //     extractMultiPolygonCoordinates(rawCoordinates);

    int buildingId = polygon['id'];
    bool hasFloors = await fetchFloorByBuilding(buildingId);
    List<Map<String, dynamic>> entrances =
        await fetchBuildingEntrances(buildingId);

    List<Map<String, dynamic>> parsedEntrances = entrances.map((entrance) {
      // Parse the coordinates string into a List<double>
      List<double> coordinates =
          List<double>.from(jsonDecode(entrance['coordinates']));
      return {
        ...entrance, // Keep all other fields
        'coordinates': coordinates, // Replace with parsed coordinates
      };
    }).toList();

    // print("BUILDING ENTRANCES: ")

    var feature = {
      "type": "Feature",
      "id": "building-$buildingId",
      "geometry": {
        "type": "Polygon",
        "coordinates": [rawCoordinates],
      },
      "properties": {
        "id": buildingId,
        "name": polygon['name'] ?? '',
        "hasFloors": hasFloors,
        "centroid": polygon['centroid'],
        "entrances": parsedEntrances,
      }
    };

    print("DEBUG: Feature Created -> ${jsonEncode(feature)}");

    return feature;
  }).toList());

  var geoJSON = {
    "type": "FeatureCollection",
    "features": features,
  };

  // print("DEBUG: Final GeoJSON -> ${jsonEncode(geoJSON)}");

  return geoJSON;
}

Future<Map<String, dynamic>> createMarkerFeature(
    List<Map<String, dynamic>> markers) async {
  return {
    "type": "FeatureCollection",
    "features": markers.map((marker) {
      String cleanedCentroid = marker['centroid'].replaceAll(
          RegExp(r'[\[\]\(\)]'), ''); // Remove brackets and parentheses

      List<double> coordinates = cleanedCentroid
          .split(',')
          .map((coord) => double.parse(coord.trim())) // Convert to double
          .toList();

      return {
        "type": "Feature",
        "id": "marker-${marker['id']}",
        "geometry": {
          "type": "Point",
          "coordinates":
              coordinates // Ensure correct format: [longitude, latitude]
        },
        "properties": {
          "id": marker['id'],
          "name": marker['name'] ?? '',
          "icon_type": marker['icon_type'] ?? '',
          "type": marker['type'] ?? '',
        }
      };
    }).toList()
  };
}

// Map<String, dynamic> createFloorFeature(Map<String, dynamic> floorData) {
//   return {
//     "type": "Feature",
//     "id": "floor-${floorData["id"]}",
//     "geometry": {
//       "type": "Polygon",
//       "coordinates": parseCoordinates(floorData["coordinates"]),
//     },
//     "properties": {
//       "id": floorData["id"],
//       "floor_num": floorData["floor_num"],
//       "building_id": floorData["building_id"],
//     },
//   };
// }

Future<Map<String, dynamic>> createMultiRouteFeature(
    List<List<Position>> routes) async {
  if (routes.isEmpty) {
    return {
      "type": "FeatureCollection",
      "features": [],
    };
  }

  // Convert each route segment to [lng, lat] format
  List<List<List<double>>> multiRouteCoordinates = routes.map((route) {
    return route
        .map((pos) => [pos.lng.toDouble(), pos.lat.toDouble()])
        .toList();
  }).toList();

  return {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "id": "route-layer",
        "geometry": {
          "type": "MultiLineString",
          "coordinates": multiRouteCoordinates,
        },
        "properties": {},
      }
    ],
  };
}
