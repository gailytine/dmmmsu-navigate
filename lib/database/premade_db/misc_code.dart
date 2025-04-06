// ignore_for_file: unused_local_variable, body_might_complete_normally_nullable

import 'dart:io';
import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';
// import 'package:path/path.dart';

void setupDatabase(String dbPath) {
  final dbFile = File(dbPath);
  final db = sqlite3.open(dbPath);

  if (!dbFile.existsSync()) {
    createTables(db);
    db.dispose();
  } else {
    print("Database already exists.");
    // insertBuilding(db);
    insertFloors(db, 1);
    db.dispose();
  }
}

bool isTableExist(Database db) {
  final result =
      db.select("SELECT name FROM sqlite_master WHERE type='table';");
  bool isTableExist = false;

  if (result.isNotEmpty) {
    print("Tables found in database:");
    for (var table in result) {
      print("- ${table['name']}");
    }
    isTableExist = true;
  } else {
    print("No tables found in the database.");
  }

  return isTableExist;
}

void createTables(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS buildings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      coordinates TEXT NOT NULL
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS floors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      floor_num INTEGER NOT NULL,
      name TEXT NOT NULL, 
      coordinates TEXT NOT NULL,
      building_id INTEGER NOT NULL,
      FOREIGN KEY(building_id) REFERENCES buildings(id) ON DELETE CASCADE
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS offices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      coordinates TEXT NOT NULL,
      floor_id INTEGER NOT NULL,
      FOREIGN KEY(floor_id) REFERENCES floors(id) ON DELETE CASCADE
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS personnel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      office_id INTEGER NOT NULL,
      FOREIGN KEY(office_id) REFERENCES offices(id) ON DELETE CASCADE
    );
  ''');

  print("Tables created successfully.");
}

void insertBuilding(Database db) async {
  final geoJsonFilePath = 'assets/geojson/buildings.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? 'Unknown Building';
        List coordinates = feature['geometry']['coordinates'][0];
        String coordinatesJson = json.encode(coordinates);

        db.execute('''
          INSERT INTO buildings (name, coordinates) 
          VALUES (?, ?);
        ''', [name, coordinatesJson]);

        print("Inserted building with name: $name");
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

Map<int, List<List<double>>> getAllBuildingRawCoordinates(Database db) {
  final List<Map<String, dynamic>> maps =
      db.select('''SELECT id, coordinates FROM buildings''');
  Map<int, List<List<double>>>  buildingWhole = {}; 

  // print(maps);

  if(maps.isNotEmpty){
    for(var map in maps){
      // print(map); 
      int id = map['id'].toInt();
      String coordinatesJson = map['coordinates']; 

      List<dynamic> decodedCoordinates = json.decode(coordinatesJson);
      List<List<double>> extractedCoordinates = extractCoordinates(decodedCoordinates); 

      buildingWhole[id] = extractedCoordinates;

    }
    print(buildingWhole); 
  }

  // final geoJsonFilePath = 'assets/geojson/buildings.geojson';
  // final geoJsonFile = File(geoJsonFilePath);
  // List<List<dynamic>> allBuildingcoordinates = [];

  // try {
  //   String geoJsonContent = geoJsonFile.readAsStringSync();
  //   Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

  //   if (geoJsonData['features'] != null) {
  //     for (var feature in geoJsonData['features']) {
  //       List<dynamic> coordinates = feature['geometry']['coordinates'][0];

  //       allBuildingcoordinates.add(coordinates);
  //     }
  //     return allBuildingcoordinates;
  //   } else {
  //     print("GeoJSON file not found at $geoJsonFilePath");
  //   }
  // } catch (e) {
  //   print("Error reading GeoJSON: $e");
  // }
  return {};
}

// access geojsonfile,loop through each floors, pass coordinate list to getCoordinatesfromgeojson
void insertFloors(Database db, int floorNum) {
  final geoJsonFilePath = 'assets/geojson/first_floor.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  // print("ALL FOORS: $floorCoordinates");

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);
    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        //cuz will loop through floors
        String name = feature['properties']['name'] ?? 'Unknown Floor';
        List<dynamic> coordinates =
            feature['geometry']['coordinates'][0]; //pass this to be extracted
        List<List<double>> floorCoordinates = extractCoordinates(
            coordinates); // need extractedLng adn Lat to compare for building

        String? buildingId = computeClosestBuilding(db, floorCoordinates);

        // String coordinatesJson = json.encode(coordinates); //for inserting in the db

        // print("$name: $floorCoordinates");

        // print("$name: $coordinatesJson");
        // Map<String, String?> buildingId =
        // findBuildingId(db, floorCoordinates); //only singular

        // db.execute('''
        //   INSERT INTO floors (floor_num, name, coordinates, building_id)
        //   VALUES (?, ?, ?);
        // ''', [floor_num, name, coordinatesJson, buildingId]);

        // print("Inserted floor with name: $name");
      }
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

// Map<String, String?> findBuildingId(
//     Database db, List<List<double>> floorCoordinates) {
//   Map<String, String?> floorBuildingMapping = {};

//   for (var floorPoint in floorCoordinates) {
//     String? closestBuildingId = computeClosestBuilding(db, floorPoint);
//     print("Floor point $floorPoint belongs to building ID: $closestBuildingId");
//     if (closestBuildingId != null) {
//       floorBuildingMapping[floorPoint.toString()] = closestBuildingId;
//     }
//   }

//   return floorBuildingMapping;
// }

// List<Map<String, dynamic>> getCoordinatesFromDB(Database db) {
//   final List<Map<String, dynamic>> maps =
//       db.select('''SELECT id, coordinates FROM buildings''');
//   List<Map<String, dynamic>> allCoordinates = [];

//   if (maps.isNotEmpty) {
//     for (var map in maps) {
//       String id = map['id'].toString();
//       String coordinatesJson = map['coordinates'];

//       List<dynamic> decoded = json.decode(coordinatesJson);
//       List<List<double>> extractedPoints =
//           decoded.map<List<double>>((point) => [point[0], point[1]]).toList();

//       List<List<double>> buildingCoords = extractedPoints
//           .map<List<double>>((point) => List<double>.from(point))
//           .toList();

//       allCoordinates.add({'id': id, 'coords': buildingCoords});
//     }
//     // print(allCoordinates);

//     return allCoordinates;
//   }
//   return [];
// }

// for offices and floors // pass coordinate list
List<List<double>> extractCoordinates(List<dynamic> rawCoordinates) {
  List<List<double>> extractedCoordinates = [];

  for (var point in rawCoordinates) {
    if (point.length >= 2) {
      try {
        double lng = (point[0] as num).toDouble();
        double lat = (point[1] as num).toDouble();

        extractedCoordinates.add([lng, lat]);
      } catch (e) {
        print("Error processing point: $point - $e");
      }
    } else {
      print("Invalid coordinate format: $point");
    }
  }

  // print("point: $extractedCoordinates");
  return extractedCoordinates;
}

//pass the floorcoordinate and return its building id
String? computeClosestBuilding(Database db, List<List<double>> floorCoords) {
  Map<int, List<List<dynamic>>> allBuildingCoords = getAllBuildingRawCoordinates(db);

  // print(allBuildingCoords); 

  // for (var rawCoords in rawBuildingCoords) {
  //   List<List<double>> buildingCoords = extractCoordinates(rawCoords);
  //   // print("Building: $buildingCoords");
  // }

  // String? closestBuildingId;
  // double minDistance = double.infinity;


// -----
  // for (var building in buildingCoords) {
  //   String buildingId = building['id'];
  //   List<List<double>> buildingPolygon =
  //       List<List<double>>.from(building['coords']);

  //   for (var buildingPoint in buildingPolygon) {
  //     double distance = sqrt(pow(floorCoords[0] - buildingPoint[0], 2) +
  //         pow(floorCoords[1] - buildingPoint[1], 2));

  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       closestBuildingId = buildingId;
  //     }
  //   }
  // }

  // return closestBuildingId;
}
