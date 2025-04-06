// ignore_for_file: unused_local_variable

import 'dart:io';
import 'dart:convert';
import 'dart:math';

// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
import 'package:dmmmsu_navigate/database/premade_db/misc_code.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:csv/csv.dart';
// import 'package:path/path.dart';

final Map<String, Map<String, List<double>>> locationPoints = {
  'SLUC Agoo': {
    'southwest': [120.36839453354702, 16.323270221283323],
    'northeast': [120.37629909957991, 16.32782861442945],
  },
  'SLUC Santo Tomas': {
    'southwest': [120.38139703005294, 16.262708545033533],
    'northeast': [120.39157934128343, 16.27484692732604],
  },
  'SLUC Rosario': {
    'southwest': [120.412931879481, 16.23678237519667],
    'northeast': [120.41721916058566, 16.240239307459674],
  }
};

void setupDatabase(String dbPath) {
  final dbFile = File(dbPath);
  final db = sqlite3.open(dbPath);
  // final floor1 = 'assets/geojson/floors_F1.geojson';
  // final floor2 = 'assets/geojson/floors_F2.geojson';
  // final floor3 = 'assets/geojson/floors_F3.geojson';
  // final officesF1 = 'assets/geojson/offices_f1.geojson';
  // final officesF2 = 'assets/geojson/offices_f2.geojson';
  // final officesF3 = 'assets/geojson/offices_f3.geojson';
  // final csvPersonnel = 'assets/csv/csvtest.csv';
  // final stairsF1 = 'assets/geojson/stairs_F1.geojson';
  // final stairsF2 = 'assets/geojson/stairs_F2.geojson';
  // final stairsF3 = 'assets/geojson/stairs_F3.geojson';

  // final stairsCentroidF1 = 'assets/geojson/stairs_centroid_F1.geojson';
  // final stairsCentroidF2 = 'assets/geojson/stairs_centroid_F2.geojson';
  // final stairsCentroidF3 = 'assets/geojson/stairs_centroid_F3.geojson';

  // final officeEntranceF1 = 'assets/geojson/office_entrance_F1.geojson';
  // final officeEntranceF2 = 'assets/geojson/office_entrance_F2.geojson';
  // final officeEntranceF3 = 'assets/geojson/office_entrance_F3.geojson';

  if (!dbFile.existsSync()) {
    db.dispose();
    print("Database setup complete.");
  } else {
    // createTables(db);
    // insertAllCampuses(db);
    // insertBuildings(db);
    // insertEntrances(db);
    // insertFloors(db);
    // insertFloors(db, floor2);
    // insertFloors(db, floor3);
    // insertOffices(db, officesF1, 1);
    // insertOffices(db, officesF2, 2);
    // insertOffices(db, officesF3, 3);
    // insertStairs(db, stairsF1, 1);
    // insertStairs(db, stairsF2, 2);
    // insertStairs(db, stairsF3, 3);
    // cleanCoordinates(db, 'floors');
    // insertVenues(db);
    // insertOfficeCentroid(db);
    // insertVenueCentroid(db);
    // insertBuildingCentroid(db);
    // insertOfficeEntrance(db, officeEntranceF1);
    // insertOfficeEntrance(db, officeEntranceF3);
    // insertCentroidStairs(db, stairsCentroidF1);
    // insertCentroidStairs(db, stairsCentroidF3);
    // cleanAndUpdateCentroids(db);
    // flipAndUpdateCentroids(db);
    // insertRoutePoints(db);
    // insertRouteLines(db);
    // insertBuildingsDirect(db);
    // insertBuildingsCentroidDirect(db);
    // insertVenuesDirect(db);
    // insertVenuesCentroidDirect(db);
    // insertBuildingEntranceDirect(db);
    // insertFloorsDirect(db);
    // insertOfficeDirect(db);
    // insertOfficeEntranceDirect(db);
    // insertVenuesFishery(db); 

    db.dispose();

    print("Database already exists.");
  }

  // insertBuilding(db);
  // insertFloors(floor1, 1);
  // insertFloors(floor2, 2);
  // insertFloors(floor3, 3);
  // insertOffices(db, officesF2, 2);
  // insertPersonnel(db, csvPersonnel);
  // db.dispose();
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
    CREATE TABLE IF NOT EXISTS route_points (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      properties TEXT
    );
  ''');

  db.execute('''
    CREATE TABLE route_lines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT, -- Optional: Name of the route/line
      point_ids TEXT -- Stores a list of point IDs in order (e.g., "1,2,3,4")
    );
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS campus (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      southwest TEXT NOT NULL,
      northeast TEXT NOT NULL
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS places (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      coordinates TEXT NOT NULL,
      type TEXT NOT NULL,
      campus_id INTEGER NOT NULL,
      FOREIGN KEY(campus_id) REFERENCES campus(id) ON DELETE CASCADE 
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS venue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL, 
      place_id INTEGER NOT NULL,
      FOREIGN KEY(place_id) REFERENCES places(id) ON DELETE CASCADE 
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS buildings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      place_id INTEGER NOT NULL,
      FOREIGN KEY(place_id) REFERENCES places(id) ON DELETE CASCADE 
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS entrance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      coordinates TEXT NOT NULL,
      building_id INTEGER NOT NULL,
      FOREIGN KEY(building_id) REFERENCES buildings(id) ON DELETE CASCADE
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS floors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      floor_num INTEGER NOT NULL,
      coordinates TEXT NOT NULL,
      building_id INTEGER NOT NULL,
      FOREIGN KEY(building_id) REFERENCES buildings(id) ON DELETE CASCADE
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS stairs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      coordinates TEXT NOT NULL,
      floor_id INTEGER NOT NULL,
      FOREIGN KEY(floor_id) REFERENCES floors(id) ON DELETE CASCADE
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
    CREATE TABLE IF NOT EXISTS office_entrance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      coordinates TEXT NOT NULL,
      office_id INTEGER NOT NULL,
      FOREIGN KEY(office_id) REFERENCES offices(id) ON DELETE CASCADE
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

  db.execute('''
    CREATE TABLE IF NOT EXISTS campus_entrance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      coordinates TEXT NOT NULL,
      campus_id INTEGER NOT NULL,
      FOREIGN KEY(campus_id) REFERENCES campus(id) ON DELETE CASCADE
    );
  ''');

  print("Tables created successfully.");
}

double roundTo13Decimals(double value) {
  return double.parse(value.toStringAsFixed(13));
}

void insertAllCampuses(Database db) {
  locationPoints.forEach((name, coords) {
    String southwest = coords['southwest']!.toString();
    String northeast = coords['northeast']!.toString();
    insertCampus(db, name, southwest, northeast);
    print("Inserted campus: $name with SW: $southwest and NE: $northeast");
  });
}

void insertCampus(
    Database db, String name, String southwest, String northeast) {
  db.execute('''
    INSERT INTO campus (name, southwest, northeast) 
    VALUES (?, ?, ?);
  ''', [name, southwest, northeast]);
}

void insertBuildings(Database db) async {
  final geoJsonFilePath = 'assets/geojson/buildings.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? 'Unknown Building';
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> buildingCoordinates =
            extractCoordinates(coordinates);
        int? campusId = getCampusId(db, buildingCoordinates);

        print("IDS: $campusId");
        String coordinatesJson = json.encode(coordinates);

        db.execute('''
          INSERT INTO places (name, coordinates, type, campus_id)
          VALUES (?, ?, ?, ?);
        ''', [name, coordinatesJson, 'building', campusId]);

        int placeId = db.lastInsertRowId;

        db.execute('''
          INSERT INTO buildings (place_id)
          VALUES (?);
        ''', [placeId]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertVenues(Database db) async {
  final geoJsonFilePath = 'assets/geojson/venues.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String rawName = feature['properties']['name'] ?? 'Unknown Venues';

        // Extract type inside parentheses and convert to lowercase
        RegExp regex = RegExp(r'\((.*?)\)');
        String type =
            regex.firstMatch(rawName)?.group(1)?.toLowerCase() ?? 'unknown';

        // Remove parentheses and type from name
        String name = rawName.replaceAll(regex, '').trim();

        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> buildingCoordinates =
            extractCoordinates(coordinates);
        int? campusId = getCampusId(db, buildingCoordinates);

        print("IDS: $campusId");
        String coordinatesJson = json.encode(coordinates);

        db.execute('''
          INSERT INTO places (name, coordinates, type, campus_id)
          VALUES (?, ?, ?, ?);
        ''', [name, coordinatesJson, 'venue', campusId]);

        int placeId = db.lastInsertRowId;

        db.execute('''
          INSERT INTO venues (place_id, type)
          VALUES (?, ?);
        ''', [placeId, type]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertEntrances(Database db) {
  final geoJsonFilePath = 'assets/geojson/entrances.geojson';
  final geoJsonFile = File(geoJsonFilePath);
  String geoJsonContent = geoJsonFile.readAsStringSync();
  final geojson = jsonDecode(geoJsonContent);

  for (var feature in geojson['features']) {
    var properties = feature['properties'];
    var points = feature['geometry']['coordinates'];
    var pointName = properties['name']; // e.g., "20E-1"

    // Extract only numeric part from point name
    String numericId = RegExp(r'^\d+').stringMatch(pointName) ?? '0';
    int buildingId = int.parse(numericId);

    // print(buildingId);

    // Store only longitude and latitude
    double longitude = points[0];
    double latitude = points[1];
    List<double> coordinates = [longitude, latitude];
    String stringCoords = coordinates.toString();

    // print(coordinates);

    // Insert into database
    db.execute('''
      INSERT INTO entrance (building_id, coordinates) 
      VALUES (?, ?);
    ''', [numericId, stringCoords]);
  }
  print("Points inserted successfully.");
}

void insertFloors(Database db, String geoJsonFilePath) {
  // final geoJsonFilePath = 'assets/geojson/floors_F1.geojson';
  final geoJsonFile = File(geoJsonFilePath);
  String geoJsonContent = geoJsonFile.readAsStringSync();
  final geojson = jsonDecode(geoJsonContent);

  for (var feature in geojson['features']) {
    var properties = feature['properties'];
    var points = feature['geometry']['coordinates'];
    var pointName = properties['name']; // e.g., "20E-1"

    print(points);

    // Extract only numeric part from point name
    String numericId = RegExp(r'^\d+').stringMatch(pointName) ?? '0';
    int buildingId = int.parse(numericId);

    String stringCoords = points.toString();

    // print(coordinates);

    // Insert into database
    db.execute('''
      INSERT INTO floors (floor_num, building_id, coordinates) 
      VALUES (?, ?, ?);
    ''', [3, numericId, stringCoords]);
  }
  print("Polygons inserted successfully.");
}

// access geojsonfile,loop through each floors, pass coordinate list to getCoordinatesfromgeojson
// void insertFloors(Database db, int floorNum, String geoJsonFilePath) {
//   final geoJsonFile = File(geoJsonFilePath);

//   try {
//     String geoJsonContent = geoJsonFile.readAsStringSync();
//     Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);
//     if (geoJsonData['features'] != null) {
//       for (var feature in geoJsonData['features']) {
//         //cuz will loop through floors
//         String name = feature['properties']['name'] ?? 'Unknown Floor';
//         List<dynamic> coordinates =
//             feature['geometry']['coordinates'][0]; //pass this to be extracted
//         List<List<double>> floorCoordinates = extractCoordinates(
//             coordinates); // need extractedLng adn Lat to compare for building

//         int? buildingId = computeClosestBuilding(db, floorCoordinates);
//         String coordinatesJson =
//             json.encode(coordinates); //for inserting in the db

//         if (buildingId != null) {
//           db.execute('''
//           INSERT INTO floors (floor_num, name, coordinates, building_id)
//           VALUES (?, ?, ?, ?);
//         ''', [floorNum, name, coordinatesJson, buildingId]);

//           print("Inserted floor with name: $name");
//         }
//       }
//     }
//   } catch (e) {
//     print("Error reading GeoJSON: $e");
//   }
// }

// clean the points first before passing and include floor num
void insertOffices(Database db, String geoJsonFilePath, int floorNum) {
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? 'Unknown Office';
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];
        List<List<double>> officesCoordinates = extractCoordinates(coordinates);
        int? floorId = computeInboundOffices(db, officesCoordinates, floorNum);
        String coordinatesJson = json.encode(coordinates);

        // print(floorId);

        if (floorId != null) {
          db.execute('''
            INSERT INTO offices (name, coordinates, floor_id)
            VALUES (?, ?, ?);
          ''', [name, coordinatesJson, floorId]);

          print("Inserted building with name: $name");
        }
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertStairs(Database db, String geoJsonFilePath, int floorNum) {
  final geoJsonFile = File(geoJsonFilePath);
  String geoJsonContent = geoJsonFile.readAsStringSync();
  final geojson = jsonDecode(geoJsonContent);

  for (var feature in geojson['features']) {
    var properties = feature['properties'];
    var points = feature['geometry']['coordinates'];
    var pointName = properties['name']; // e.g., "13S-1_1-2"

    // Extract floor ID from the naming convention (e.g., '13' from '13S-1_1-2')
    String floorId = RegExp(r'^\d+').stringMatch(pointName) ?? '0';

    // Extract start and end floors from the convention (e.g., '1-2' from '13S-1_1-2')
    String? floors = RegExp(r'\d+-\d+').stringMatch(pointName);
    String startFloor = floors?.split('-')[0] ?? '0';
    String endFloor = floors?.split('-')[1] ?? '0';
    String coordinates = points.toString();

    print("$floorId has stairs that starts $startFloor and ends at $endFloor");

    // Store only floor_id, start, and end floors
    db.execute('''
      INSERT INTO stairs (coordinates, floor_id, start, end)
      VALUES (?, ?, ?, ?);
    ''', [coordinates, floorId, startFloor, endFloor]);
  }
  print("Stair connections inserted successfully.");
}

void insertCentroidStairs(Database db, String geoJsonFilePath) {
  final geoJsonFile = File(geoJsonFilePath);
  String geoJsonContent = geoJsonFile.readAsStringSync();
  final geojson = jsonDecode(geoJsonContent);

  for (var feature in geojson['features']) {
    var properties = feature['properties'];
    var points = feature['geometry']['coordinates'];
    var pointName = properties['name']; // e.g., "13S-1_1-2"

    print(pointName);

    // Extract floor ID from the naming convention (e.g., '13' from '13S-1_1-2')
    String? stairId =
        RegExp(r'([0-9]+)$').firstMatch(pointName)?.group(1) ?? '0';

    // Extract start and end floors from the convention (e.g., '1-2' from '13S-1_1-2')
    String coordinates = points.toString();

    print("STAIR ID: $stairId COORDINATES: $coordinates");

    // Store only floor_id, start, and end floors
    db.execute('''
      UPDATE stairs 
      SET centroid = ? 
      WHERE id = ?;
    ''', [coordinates, stairId]);
  }
  // print("Stair connections inserted successfully.");
}

// for offices and floors // pass coordinate list
List<List<double>> extractCoordinates(List<dynamic> rawCoordinates) {
  List<List<double>> extractedCoordinates = [];

  for (var point in rawCoordinates) {
    // print("POINT: $point");

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

  return extractedCoordinates;
}

List<List<double>> extractMultiPolygonCoordinates(
    List<dynamic> rawCoordinates) {
  List<List<double>> extractedCoordinates = [];

  void extractFromList(List<dynamic> points) {
    for (var point in points) {
      if (point is List) {
        if (point.isNotEmpty && point[0] is List) {
          // Recursive call for nested lists
          extractFromList(point);
        } else if (point.length >= 2) {
          try {
            double lng = (point[0] as num).toDouble();
            double lat = (point[1] as num).toDouble();
            extractedCoordinates.add([lng, lat]);
          } catch (e) {
            print("Error processing point: $point - $e");
          }
        }
      }
    }
  }

  extractFromList(rawCoordinates);
  return extractedCoordinates;
}

Future<void> updateFloorCoordinates(Database db) async {
// Assuming you already have this function

  // Step 1: Fetch all floors with coordinates
  final ResultSet floors = db.select(
    'SELECT id, coordinates FROM floors',
  );

  for (final Row floor in floors) {
    try {
      final int floorId = floor['id'] as int;
      final String? coordJson = floor['coordinates'] as String?;

      if (coordJson == null) {
        print('Floor $floorId has no coordinates.');
        continue;
      }

      // Parse coordinates from JSON
      List<dynamic> rawCoordinates = jsonDecode(coordJson);

      // Step 2: Extract only [lng, lat]
      List<List<double>> cleanedCoordinates =
          extractMultiPolygonCoordinates(rawCoordinates);

      // Convert back to JSON
      String updatedCoordinates = jsonEncode([cleanedCoordinates]);

      // Step 3: Update the floor record
      db.execute(
        'UPDATE floors SET coordinates = ? WHERE id = ?',
        [updatedCoordinates, floorId],
      );

      print('Updated floor $floorId with cleaned coordinates');
    } catch (e) {
      print('Error processing floor ${floor['id']}: $e');
    }
  }

  print('Floor coordinates update completed.');
}

Map<int, List<List<double>>> getAllRawCoordinates(
    Database db, String attribute) {
  List<Map<String, dynamic>> maps =
      db.select('''SELECT id, coordinates FROM $attribute''');
  Map<int, List<List<double>>> buildingWhole = {};

  // print(maps);

  if (maps.isNotEmpty) {
    for (var map in maps) {
      // print(map);
      int id = map['id'].toInt();
      String coordinatesJson = map['coordinates'];

      List<dynamic> decodedCoordinates = json.decode(coordinatesJson);
      List<List<double>> extractedCoordinates =
          extractCoordinates(decodedCoordinates);

      buildingWhole[id] = extractedCoordinates;
    }
    // print(buildingWhole);
  }

  return buildingWhole;
}

Map<int, List<List<double>>> getSpecificFloor(Database db, int floorNum) {
  // Map<int, List<List<double>>> specifcFloors = getAllRawCoordinates(db, 'floors');
  List<Map<String, dynamic>> maps = db.select(
      '''SELECT id, coordinates FROM floors WHERE floor_num=$floorNum''');
  Map<int, List<List<double>>> extractedFloors = {};

  // print(maps);

  if (maps.isNotEmpty) {
    for (var map in maps) {
      // print(map);
      int id = map['id'].toInt();
      String coordinatesJson = map['coordinates'];

      List<dynamic> decodedCoordinates = json.decode(coordinatesJson);
      List<List<double>> extractedCoordinates =
          extractMultiPolygonCoordinates(decodedCoordinates);

      extractedFloors[id] = extractedCoordinates;
    }
    // print(buildingWhole);
  }

  return extractedFloors;
}

//pass the floorcoordinate and return its building id
int? computeClosestBuilding(Database db, List<List<double>> floorCoords) {
  Map<int, List<List<double>>> allBuildingCoords =
      getAllRawCoordinates(db, 'buildings');
  double minDistance = double.infinity;
  int? closestBuildingId;

  allBuildingCoords.forEach((buildingId, buildingCoords) {
    for (var buildingPoint in buildingCoords) {
      // print(buildingPoint[0]);
      double distance = sqrt(pow(floorCoords[0][0] - buildingPoint[0], 2) +
          pow(floorCoords[0][1] - buildingPoint[1], 2));

      if (distance < minDistance) {
        minDistance = distance;
        closestBuildingId = buildingId;
      }
    }
  });

  // print("$floorCoords is close to $closestBuildingId");
  return closestBuildingId;
}

List<double> computeCenterBound(List<List<double>> officesCoordinates) {
  double sumLat = 0.0; // To store the sum of latitudes
  double sumLng = 0.0; // To store the sum of longitudes
  int numPoints = officesCoordinates.length;

  // Sum up the latitudes and longitudes
  for (var coordinate in officesCoordinates) {
    sumLat += coordinate[1]; // Latitude is at index 1
    sumLng += coordinate[0]; // Longitude is at index 0
  }

  // Compute the average (centroid)
  double centroidLat = sumLat / numPoints;
  double centroidLng = sumLng / numPoints;

  return [
    centroidLng,
    centroidLat
  ]; // Return the centroid as [longitude, latitude]
}

//before inserting floor coordinates, it has to be a specific floor first
//to find if the polygon is inbound, i need the specific floor and the offices
// compare points of offices if in floor polygon
int? computeInboundOffices(
    Database db, List<List<double>> officesCoordinates, int floorNum) {
  List<double> officeCentroid = computeCenterBound(officesCoordinates);
  Map<int, List<List<double>>> allFloorsCoords = getSpecificFloor(db, floorNum);
  int? attachedFloor;

  allFloorsCoords.forEach((floorId, floorCoords) {
    bool isInPolygon = isPointInPolygon(officeCentroid, floorCoords);

    if (isInPolygon) {
      // print("true: $officesCoordinates is in floor $floorId");
      attachedFloor = floorId;
    }
  });

  return attachedFloor;
}

// Ray-casting algorithm for Point-in-Polygon test //the polygon is the floor
bool isPointInPolygon(List<double> point, List<List<double>> polygon) {
  int n = polygon.length;
  bool inside = false;

  // Iterate over each edge of the polygon
  for (int i = 0; i < n; i++) {
    List<double> p1 = polygon[i];
    List<double> p2 = polygon[(i + 1) % n]; // Next point (wrapping around)

    // Check if point is inside the polygon using ray-casting
    if (point[1] > p1[1] && point[1] <= p2[1] ||
        point[1] > p2[1] && point[1] <= p1[1]) {
      double xIntersection =
          (point[1] - p1[1]) * (p2[0] - p1[0]) / (p2[1] - p1[1]) + p1[0];
      if (point[0] < xIntersection) {
        inside = !inside;
      }
    }
  }

  return inside;
}

// Function to check if a point is inside a rectangular boundary defined by southwest and northeast points
bool isPointInBounds(
    List<double> point, List<double> southwest, List<double> northeast) {
  double swLat = southwest[0];
  double swLng = southwest[1];
  double neLat = northeast[0];
  double neLng = northeast[1];
  double userLat = point[0];
  double userLng = point[1];

  return (userLat >= swLat &&
      userLat <= neLat &&
      userLng >= swLng &&
      userLng <= neLng);
}

//loop through campuses and see what buildings are in
// Function to get campus ID based on building coordinates
int? getCampusId(Database db, List<List<double>> buildingCoordinates) {
  List<double> buildingCentroid = computeCenterBound(buildingCoordinates);
  Map<int, List<List<double>>> campusCoordinates = getCampusCoordinates(db);

  // print(buildingCentroid);

  for (var entry in campusCoordinates.entries) {
    int campusId = entry.key;
    List<double> southwest = campusCoordinates[campusId]![0];
    List<double> northeast = campusCoordinates[campusId]![1];

    if (isPointInBounds(buildingCentroid, southwest, northeast)) {
      // print('Building is inside campus ID: $campusId');
      return campusId;
    }
  }

  return null;
}

// Function to get southwest and northeast coordinates for each campus from the database
Map<int, List<List<double>>> getCampusCoordinates(Database db) {
  List<Map<String, dynamic>> maps =
      db.select('SELECT id, southwest, northeast FROM campus');
  Map<int, List<List<double>>> campusWhole = {};

  // print(maps);

  if (maps.isNotEmpty) {
    for (var map in maps) {
      int id = map['id'].toInt();

      List<double> southwest = decodePoints(map['southwest']);
      List<double> northeast = decodePoints(map['northeast']);

      // print(southwest);
      campusWhole[id] = [southwest, northeast];

      // print(campusWhole[id]);
    }
    // print(campusWhole);
  }

  return campusWhole;
}

List<double> decodePoints(String coords) {
  List<dynamic> decoded = json.decode(coords);
  List<double> coordinates = decoded.map((e) => (e as num).toDouble()).toList();

  return coordinates;
}

void insertPersonnel(Database db, String csvFilePath) async {
  final file = File(csvFilePath);
  String csvString = await file.readAsString();
  List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

  for (var i = 1; i < rows.length; i++) {
    int officeId = rows[i][0];
    String personnelName = rows[i][1];

    // print("$officeId: $personnelName");

    db.execute('''
      INSERT INTO personnel (name, office_id) 
      VALUES (?, ?);
    ''', [personnelName, officeId]);
  }

  print("CSV Data inserted successfully.");
}

void insertBuildingCentroid(Database db) {
  final geoJsonFilePath = 'assets/geojson/building_centroid.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String fullName = feature['properties']['name'];

        // Extract only numbers from the name (e.g., "1C" → "1")
        RegExp regex = RegExp(r'(\d+)');
        String? buildingId = regex.firstMatch(fullName)?.group(0);

        if (buildingId == null) {
          print("Skipping invalid building name: $fullName");
          continue;
        }

        // Extract only lat & lng (ignore height)
        List<dynamic> rawCoordinates = feature['geometry']['coordinates'];
        if (rawCoordinates.length < 2) continue; // Ensure valid coordinates

        double lng = rawCoordinates[0].toDouble();
        double lat = rawCoordinates[1].toDouble();
        String centroidJson = json.encode([lng, lat]);

        // Update the 'places' table where id matches (assuming id is numeric)
        db.execute('''
          UPDATE places 
          SET centroid = ? 
          WHERE id = ?;
        ''', [centroidJson, buildingId]);

        print("Updated centroid for building ID $buildingId: $centroidJson");
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertOfficeCentroid(Database db) {
  List<Map<String, dynamic>> rows =
      db.select('SELECT id, coordinates FROM offices');

  for (var row in rows) {
    String jsonString = row['coordinates'];
    int id = row['id'];

    try {
      var decoded = jsonDecode(jsonString);

      if (decoded is List && decoded.isNotEmpty) {
        List<List<double>> officesCoordinates = [];

        for (var coord in decoded) {
          if (coord is List && coord.length >= 2) {
            officesCoordinates.add([coord[0].toDouble(), coord[1].toDouble()]);
          }
        }

        if (officesCoordinates.isNotEmpty) {
          List<double> centroid = computeCenterBound(officesCoordinates);

          // Convert centroid to JSON format
          String centroidJson = jsonEncode(centroid);

          // Update the office table with the computed centroid
          db.execute(
            'UPDATE offices SET centroid = ? WHERE id = ?',
            [centroidJson, id],
          );

          print("Updated centroid for office ID $id: $centroid");
        }
      }
    } catch (e) {
      print("Error processing office ID $id: $e");
    }
  }
}

void insertVenueCentroid(Database db) {
  List<Map<String, dynamic>> rows =
      db.select('SELECT id, coordinates FROM places WHERE type = "venue"');
  print(rows);

  for (var row in rows) {
    String jsonString = row['coordinates'];
    int id = row['id'];

    try {
      var decoded = jsonDecode(jsonString);

      if (decoded is List && decoded.isNotEmpty) {
        List<List<double>> officesCoordinates = [];

        for (var coord in decoded) {
          if (coord is List && coord.length >= 2) {
            officesCoordinates.add([coord[0].toDouble(), coord[1].toDouble()]);
          }
        }

        if (officesCoordinates.isNotEmpty) {
          List<double> centroid = computeCenterBound(officesCoordinates);

          // Convert centroid to JSON format
          String centroidJson = jsonEncode(centroid);

          // Update the office table with the computed centroid
          db.execute(
            'UPDATE places SET centroid = ? WHERE id = ?',
            [centroidJson, id],
          );

          print("Updated centroid for venues ID $id: $centroid");
        }
      }
    } catch (e) {
      print("Error processing venues ID $id: $e");
    }
  }
}

void insertOfficeEntrance(Database db, String geoJsonFilePath) {
  final geoJsonFile = File(geoJsonFilePath);
  String geoJsonContent = geoJsonFile.readAsStringSync();
  final geojson = jsonDecode(geoJsonContent);

  for (var feature in geojson['features']) {
    var properties = feature['properties'];
    var points = feature['geometry']['coordinates'];
    var pointName = properties['name']; // e.g., "20E-1"

    // Extract only numeric part from point name
    String numericId = RegExp(r'^\d+').stringMatch(pointName) ?? '0';
    int buildingId = int.parse(numericId);

    // print(buildingId);

    // Store only longitude and latitude
    double longitude = points[0];
    double latitude = points[1];
    List<double> coordinates = [longitude, latitude];
    String stringCoords = coordinates.toString();

    // print(coordinates);

    // Insert into database
    db.execute('''
      INSERT INTO office_entrance (office_id, coordinates) 
      VALUES (?, ?);
    ''', [numericId, stringCoords]);
  }
  print("Points inserted successfully.");
}

void cleanCoordinates(Database db, String table) {
  List<Map<String, dynamic>> rows = db.select(
      'SELECT id, coordinates FROM $table'); // Fetching 'id' for updating

  for (var row in rows) {
    String jsonString = row['coordinates'];
    int id = row['id']; // Assuming there is a primary key 'id'

    var decoded = jsonDecode(jsonString);

    List<dynamic> cleanedCoordinates;

    if (decoded.isNotEmpty &&
        decoded.first is List &&
        decoded.first.first is List) {
      // Case: [[[]]] (Multi-polygon format)
      cleanedCoordinates = decoded
          .map((polygon) => (polygon as List)
              .map((e) => [e[0] as double, e[1] as double])
              .toList())
          .toList();
    } else {
      // Case: [[]] (Single polygon format)
      cleanedCoordinates =
          decoded.map((e) => [e[0] as double, e[1] as double]).toList();
    }

    // Convert cleaned coordinates back to JSON
    String cleanedJsonString = jsonEncode(cleanedCoordinates);

    // Print cleaned JSON (for debugging)
    print("Cleaned JSON for ID $id: $cleanedJsonString");

    // Update the database with the cleaned coordinates
    db.execute('UPDATE $table SET coordinates = ? WHERE id = ?',
        [cleanedJsonString, id]);
  }
}

void cleanAndUpdateCentroids(Database db) {
  // Fetch all centroids from the stairs table
  final ResultSet results = db.select('SELECT id, centroid FROM stairs');

  for (final Row row in results) {
    int stairId = row['id'] as int;
    String centroidRaw =
        row['centroid'] as String; // Stored as a JSON-like string

    try {
      // Convert the stored string to a list
      List<dynamic> parsedCentroid = jsonDecode(centroidRaw);

      if (parsedCentroid.length >= 2) {
        double lng = (parsedCentroid[0] as num).toDouble();
        double lat = (parsedCentroid[1] as num).toDouble();

        String cleanedCentroid = jsonEncode([lat, lng]); // Keep only [lat, lng]

        print("Updating STAIR ID: $stairId -> CENTROID: $cleanedCentroid");

        // Update the centroid column
        db.execute(
          'UPDATE stairs SET centroid = ? WHERE id = ?',
          [cleanedCentroid, stairId],
        );
      } else {
        print("Invalid centroid format for stair ID: $stairId");
      }
    } catch (e) {
      print("Error processing stair ID: $stairId - $e");
    }
  }

  print("Centroid cleaning and update complete.");
}

void flipAndUpdateCentroids(Database db) {
  // Fetch all centroids from the stairs table
  final ResultSet results = db.select('SELECT id, centroid FROM stairs');

  for (final Row row in results) {
    int stairId = row['id'] as int;
    String centroidRaw = row['centroid'] as String; // Stored as a JSON string

    try {
      // Convert the stored string to a list
      List<dynamic> parsedCentroid = jsonDecode(centroidRaw);

      if (parsedCentroid.length >= 2) {
        double lat = (parsedCentroid[0] as num).toDouble();
        double lng = (parsedCentroid[1] as num).toDouble();

        String flippedCentroid = jsonEncode([lng, lat]); // Swap to [lng, lat]

        print("Updating STAIR ID: $stairId -> CENTROID: $flippedCentroid");

        // Update the centroid column
        db.execute(
          'UPDATE stairs SET centroid = ? WHERE id = ?',
          [flippedCentroid, stairId],
        );
      } else {
        print("Invalid centroid format for stair ID: $stairId");
      }
    } catch (e) {
      print("Error processing stair ID: $stairId - $e");
    }
  }

  print("Centroid flipping and update complete.");
}

void insertRoutePoints(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/route.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    // Read the GeoJSON file synchronously
    String geoJsonContent = geoJsonFile.readAsStringSync();

    // Decode the GeoJSON data
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    print(geoJsonData);

    // Check if features exist
    if (geoJsonData['features'] == null) {
      print("No features found in the GeoJSON file.");
      return;
    }

    db.execute("BEGIN TRANSACTION;"); // Start transaction

    for (var feature in geoJsonData['features']) {
      if (feature['geometry'] == null ||
          feature['geometry']['coordinates'] == null) {
        print("Skipping feature with missing geometry.");
        continue;
      }

      String geometryType = feature['geometry']['type'];

      List<dynamic> coordinatesList;
      if (geometryType == 'LineString') {
        coordinatesList = [feature['geometry']['coordinates']];
      } else if (geometryType == 'MultiLineString') {
        coordinatesList = feature['geometry']['coordinates'];
      } else {
        print("Skipping feature with unsupported geometry type: $geometryType");
        continue;
      }

      for (var coordinates in coordinatesList) {
        for (var coord in coordinates) {
          double longitude = coord[0]; // Longitude is the first element
          double latitude = coord[1]; // Latitude is the second element

          // Check if the point already exists
          var existingPoint = db.select(
            'SELECT id FROM route_points WHERE latitude = ? AND longitude = ?;',
            [latitude, longitude],
          );

          if (existingPoint.isEmpty) {
            // Insert the point if it doesn't exist
            db.execute(
              'INSERT INTO route_points (latitude, longitude, campus_id) VALUES (?, ?, ?);',
              [latitude, longitude, 2],
            );
            print("Inserted Route Point: ($latitude, $longitude)");
          } else {
            print("Skipping duplicate Route Point: ($latitude, $longitude)");
          }
        }
      }
    }

    db.execute("COMMIT;"); // Commit transaction
    print("All route points inserted successfully!");
  } on FileSystemException catch (e) {
    print("Error reading GeoJSON file: $e");
  } on FormatException catch (e) {
    print("Error parsing GeoJSON: $e");
  } catch (e) {
    db.execute("ROLLBACK;"); // Rollback on error
    print("Unexpected error: $e");
  }
}

void insertRouteLines(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/route.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    // Read the GeoJSON file synchronously
    String geoJsonContent = geoJsonFile.readAsStringSync();

    // Decode the GeoJSON data
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    // Check if features exist
    if (geoJsonData['features'] == null) {
      print("No features found in the GeoJSON file.");
      return;
    }

    db.execute("BEGIN TRANSACTION;"); // Start transaction

    for (var feature in geoJsonData['features']) {
      // Extract the id from properties
      dynamic id = feature['properties']?['id'];
      if (id == null) {
        print("Skipping feature with missing id.");
        continue;
      }

      // Get coordinates based on geometry type
      List<dynamic> coordinatesList = [];
      if (feature['geometry']['type'] == 'MultiLineString') {
        // Flatten MultiLineString coordinates into a single list
        coordinatesList = (feature['geometry']['coordinates'] as List)
            .expand((line) => line as List)
            .toList();
      } else {
        print("Skipping feature with unsupported geometry type.");
        continue;
      }

      // Skip if coordinates are empty
      if (coordinatesList.isEmpty) {
        print("Skipping feature with empty coordinates.");
        continue;
      }

      // Collect point IDs for this line
      List<String> pointIds = [];
      for (var coord in coordinatesList) {
        double longitude = coord[0];
        double latitude = coord[1];

        // Find the ID of the point
        var pointResult = db.select(
          'SELECT id FROM route_points WHERE latitude = ? AND longitude = ?;',
          [latitude, longitude],
        );

        if (pointResult.isNotEmpty) {
          int pointId = pointResult.first['id'] as int;
          pointIds.add(pointId.toString());
        } else {
          print("Point not found: ($latitude, $longitude)");
        }
      }

      // Check if a line with the same name already exists
      var existingLine = db.select(
        'SELECT id FROM route_lines WHERE name = ?;',
        [id.toString()],
      );

      if (existingLine.isEmpty) {
        // Save the line with the point IDs as a comma-separated string
        String pointsIdString = pointIds.join(',');
        db.execute(
          'INSERT INTO route_lines (name, point_ids, campus_id) VALUES (?, ?, ?);',
          [id.toString(), pointsIdString, 2],
        );
        print("Inserted Line ${id.toString()} with points: $pointsIdString");
      } else {
        print("Skipping duplicate Line with name: ${id.toString()}");
      }
    }

    db.execute("COMMIT;"); // Commit transaction
    print("All route lines and points inserted successfully!");
  } on FileSystemException catch (e) {
    print("Error reading GeoJSON file: $e");
  } on FormatException catch (e) {
    print("Error parsing GeoJSON: $e");
  } catch (e) {
    db.execute("ROLLBACK;"); // Rollback on error
    print("Unexpected error: $e");
  }
}

//// DIRECT INSERTION /////
///

List<List<double>> roundCoordinates(List<dynamic> coordinates) {
  return coordinates.map<List<double>>((coord) {
    double roundedLng = double.parse(coord[0].toStringAsFixed(13)); // Longitude
    double roundedLat = double.parse(coord[1].toStringAsFixed(13)); // Latitude
    return [roundedLng, roundedLat];
  }).toList();
}

List<List<double>> roundMult(List<dynamic> coordinates) {
  return coordinates.map<List<double>>((coord) {
    double lng = coord[0]; // Extract Longitude
    double lat = coord[1]; // Extract Latitude
    double roundedLng = double.parse(lng.toStringAsFixed(13));
    double roundedLat = double.parse(lat.toStringAsFixed(13));
    return [roundedLng, roundedLat];
  }).toList();
}

void insertBuildingsDirect(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/buildings.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? 'Unknown Building';
        // String icon = feature['properties']['icon'] ?? 'ADMIN';
        // int campusId = feature['properties']['campus_id'];
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> buildingCoordinates = roundCoordinates(coordinates);

        String coordinatesJson = json.encode(buildingCoordinates);

        print("COORDINATES : $coordinatesJson");

        db.execute('''
          INSERT INTO places (name, coordinates, type, icon_type, campus_id)
          VALUES (?, ?, ?, ?, ?);
        ''', [name, coordinatesJson, 'building', 'ADMIN', 2]);

        int placeId = db.lastInsertRowId;

        db.execute('''
          INSERT INTO buildings (place_id)
          VALUES (?);
        ''', [placeId]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertBuildingsCentroidDirect(Database db) {
  final geoJsonFilePath =
      'assets/geojson/agriculture/building_centroid.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        int id = feature['properties']['id'];
        var coordinates = feature['geometry']['coordinates'];

        // Ensure coordinates are valid
        if (coordinates is List && coordinates.length == 2) {
          double lon = roundToDecimal(coordinates[0], 13);
          double lat = roundToDecimal(coordinates[1], 13);

          String coordinatesJson = json.encode([lon, lat]);

          print("COORDINATES for ID $id: $coordinatesJson");

          // Update the centroid column with the rounded coordinates
          db.execute('''
            UPDATE places SET centroid = ? WHERE id = ?
          ''', [coordinatesJson, id]);
        }
      }
    } else {
      print("No 'features' found in GeoJSON.");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

// Function to round numbers to a specific decimal place
double roundToDecimal(double value, int places) {
  num mod = pow(10.0, places);
  return (value * mod).round() / mod;
}

void insertVenuesDirect(Database db) {
  final geoJsonFilePath = 'assets/geojson/agriculture/venues.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? '';
        // String icon = feature['properties']['icon'];
        String type = feature['properties']['type'];
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> venueCoordinates = roundCoordinates(coordinates);

        String coordinatesJson = json.encode(venueCoordinates);

        print("COORDINATES : $coordinatesJson");

        db.execute('''
          INSERT INTO places (name, coordinates, type, campus_id)
          VALUES (?, ?, ?, ?);
        ''', [name, coordinatesJson, 'venue', 3]);

        int placeId = db.lastInsertRowId;

        db.execute('''
          INSERT INTO venues (place_id, type)
          VALUES (?, ?);
        ''', [placeId, type]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertVenuesFishery(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/venues.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        String name = feature['properties']['name'] ?? '';
        // String type = feature['properties']['type'];
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> venueCoordinates = roundCoordinates(coordinates);
        String coordinatesJson = json.encode(venueCoordinates);

        // Determine venue type and icon_type
        String lowerName = name.toLowerCase();
        String venueType = 'water'; // Default
        String iconType = ''; // Empty by default

        if (RegExp(r'Water Area \d+', caseSensitive: false).hasMatch(name)) {
          venueType = 'water';
          iconType = 'WATER';
        } else if (RegExp(r'rice field \d+', caseSensitive: false).hasMatch(name)) {
          venueType = 'rice';
          iconType = 'RICE';
        }

        print("COORDINATES: $coordinatesJson");

        db.execute('''
          INSERT INTO places (name, coordinates, type, campus_id, icon_type)
          VALUES (?, ?, ?, ?, ?);
        ''', [name, coordinatesJson, 'venue', 2, iconType]);

        int placeId = db.lastInsertRowId;

        db.execute('''
          INSERT INTO venues (place_id, type)
          VALUES (?, ?);
        ''', [placeId, venueType]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertVenuesCentroidDirect(Database db) {
  final geoJsonFilePath = 'assets/geojson/agriculture/venues_centroid.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        int id = feature['properties']['id'];
        var iconType = feature['properties']['icon_type'];
        var coordinates = feature['geometry']['coordinates'];

        // Ensure coordinates are valid
        if (coordinates is List && coordinates.length == 2) {
          double lon = roundToDecimal(coordinates[0], 13);
          double lat = roundToDecimal(coordinates[1], 13);

          String coordinatesJson = json.encode([lon, lat]);

          print("COORDINATES for ID $id: $coordinatesJson");

          // Update the centroid column with the rounded coordinates
          db.execute('''
            UPDATE places 
            SET centroid = ?, icon_type = ? 
            WHERE id = ?
          ''', [coordinatesJson, iconType, id]);
        }
      }
    } else {
      print("No 'features' found in GeoJSON.");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertBuildingEntranceDirect(Database db) {
  final geoJsonFilePath =
      'assets/geojson/fisheries/building_entrance.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData.containsKey('features') &&
        geoJsonData['features'] is List) {
      for (var feature in geoJsonData['features']) {
        // Ensure 'id' is an integer
        dynamic idValue = feature['properties']['id'];
        int? id = (idValue is int) ? idValue : int.tryParse(idValue.toString());

        if (id == null) {
          print("Invalid ID for feature: $idValue");
          continue; // Skip this feature
        }

        List<dynamic> coordinates =
            feature['geometry']['coordinates']; // Use directly as [lon, lat]

        if (coordinates.length >= 2) {
          double lon = roundToDecimal(coordinates[0], 13);
          double lat = roundToDecimal(coordinates[1], 13);
          String coordinatesJson = json.encode([lon, lat]);

          print("COORDINATES for ID $id: $coordinatesJson");

          // Insert into the database
          db.execute('''
            INSERT INTO building_entrance (coordinates, building_id) 
            VALUES (?, ?)
          ''', [coordinatesJson, id]);
        } else {
          print("Invalid coordinates for ID $id: $coordinates");
        }
      }
    } else {
      print("No valid features found in GeoJSON file.");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertFloorsDirect(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/floor_F2.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        dynamic idValue = feature['properties']['id'];
        int? buildingId =
            (idValue is int) ? idValue : int.tryParse(idValue.toString());
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> floorCoordinates = roundCoordinates(coordinates);

        String coordinatesJson = json.encode(floorCoordinates);

        print("COORDINATES : $buildingId");

        db.execute('''
          INSERT INTO floors (floor_num, coordinates, building_id)
          VALUES (?, ?, ?);
        ''', [1, coordinatesJson, buildingId]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertOfficeDirect(Database db) {
  final geoJsonFilePath = 'assets/geojson/fisheries/office_F2.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData['features'] != null) {
      for (var feature in geoJsonData['features']) {
        dynamic idValue = feature['properties']['id'];
        String name = feature['properties']['name'];
        int? floorId =
            (idValue is int) ? idValue : int.tryParse(idValue.toString());
        List<dynamic> coordinates = feature['geometry']['coordinates'][0];

        List<List<double>> officeCoordinates = roundCoordinates(coordinates);

        String coordinatesJson = json.encode(officeCoordinates);

        print("COORDINATES : $floorId");

        db.execute('''
          INSERT INTO offices (name, coordinates, floor_id)
          VALUES (?, ?, ?);
        ''', [name, coordinatesJson, floorId]);
      }
    } else {
      print("GeoJSON file not found at $geoJsonFilePath");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}

void insertOfficeEntranceDirect(Database db) {
  final geoJsonFilePath =
      'assets/geojson/fisheries/office_entrance_F2.geojson';
  final geoJsonFile = File(geoJsonFilePath);

  try {
    String geoJsonContent = geoJsonFile.readAsStringSync();
    Map<String, dynamic> geoJsonData = json.decode(geoJsonContent);

    if (geoJsonData.containsKey('features') &&
        geoJsonData['features'] is List) {
      for (var feature in geoJsonData['features']) {
        // Ensure 'id' is an integer
        dynamic idValue = feature['properties']['id'];
        int? id = (idValue is int) ? idValue : int.tryParse(idValue.toString());

        if (id == null) {
          print("Invalid ID for feature: $idValue");
          continue; // Skip this feature
        }

        List<dynamic> coordinates =
            feature['geometry']['coordinates']; // Use directly as [lon, lat]

        if (coordinates.length >= 2) {
          double lon = roundToDecimal(coordinates[0], 13);
          double lat = roundToDecimal(coordinates[1], 13);
          String coordinatesJson = json.encode([lon, lat]);

          print("COORDINATES for ID $id: $coordinatesJson");

          // Insert into the database
          db.execute('''
            INSERT INTO office_entrance (coordinates, office_id) 
            VALUES (?, ?)
          ''', [coordinatesJson, id]);
        } else {
          print("Invalid coordinates for ID $id: $coordinates");
        }
      }
    } else {
      print("No valid features found in GeoJSON file.");
    }
  } catch (e) {
    print("Error reading GeoJSON: $e");
  }
}
