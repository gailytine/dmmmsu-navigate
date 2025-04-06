import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter/services.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'campus_db.db');

  var exists = await databaseExists(path);

  if (!exists) {
    ByteData data = await rootBundle.load('assets/database/campus_db.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes, flush: true);
  }
  return openDatabase(path);
}

Future<List<Map<String, dynamic>>> fetchCampusEntrance(int campusId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT *
    FROM campus_entrance
    WHERE campus_id = ?
  ''', [campusId]);
}

Future<String?> fetchBuildingImgName(int buildingId) async {
  final Database db = await getDatabase();
  final result = await db.rawQuery('''
    SELECT img_name
    FROM buildings
    WHERE id = ?
  ''', [buildingId]);

  print("IMG FROM DB: $result"); 

  // Change 'image_name' to 'img_name' to match your database column
  return result.isNotEmpty ? result.first['img_name'] as String? : null;
}

Future<List<Map<String, dynamic>>> fetchBuildings(int campusId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT buildings.*, places.name, places.coordinates, places.centroid, places.icon_type
    FROM buildings
    JOIN places ON buildings.place_id = places.id
     WHERE places.campus_id = ?
  ''', [campusId]);
}

Future<int?> fetchBuildingIdByOffice(int officeId) async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT buildings.id AS building_id
    FROM offices
    JOIN floors ON offices.floor_id = floors.id
    JOIN buildings ON floors.building_id = buildings.id
    WHERE offices.id = ?
  ''', [officeId]);

  if (result.isNotEmpty) {
    return result.first['building_id'] as int;
  } else {
    return null; // No match found
  }
}

Future<int?> fetchFloorNumberByOffice(int officeId) async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT floors.floor_num
    FROM offices
    JOIN floors ON offices.floor_id = floors.id
    WHERE offices.id = ?
  ''', [officeId]);

  if (result.isNotEmpty) {
    return result.first['floor_num'] as int;
  } else {
    return null; // No match found
  }
}

Future<List<Map<String, dynamic>>> fetchBuildingEntrances(
    int buildingId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT * FROM building_entrance
     WHERE building_id = ?
  ''', [buildingId]);
}

Future<List<Map<String, dynamic>>> fetchOfficeEntrances(int floorId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT oe.* 
    FROM office_entrance oe
    JOIN offices o ON oe.office_id = o.id
    WHERE o.floor_id = ?
  ''', [floorId]);
}

Future<List<Map<String, dynamic>>> fetchVenues(int campusId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT venues.*, places.name, places.coordinates, places.centroid, places.icon_type
    FROM venues
    JOIN places ON venues.place_id = places.id
     WHERE places.campus_id = ?
  ''', [campusId]);
}

Future<List<Map<String, dynamic>>> fetchPlacesMarkers(int campusId) async {
  final Database db = await getDatabase();
  return await db.rawQuery('''
    SELECT *
    FROM places
    WHERE campus_id = ?
  ''', [campusId]);
}

Future<String?> fetchBuildingName(int? buildingId) async {
  if (buildingId == null) return null;

  final Database db = await getDatabase();
  List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT places.name
    FROM buildings
    JOIN places ON buildings.place_id = places.id
    WHERE buildings.id = ?
    LIMIT 1
  ''', [buildingId]);

  if (result.isNotEmpty) {
    return result.first['name'] as String?;
  }
  return null;
}

Future<List<Map<String, dynamic>>> fetchBuildingAllFloor(int buildingId) async {
  final Database db = await getDatabase();
  List<Map<String, dynamic>> result = await db.query(
    'floors',
    where: 'id = ?',
    whereArgs: [buildingId],
  );
  return result;
}

Future<List<Map<String, dynamic>>> fetchAllBuildingFloors(
    int buildingId) async {
  final Database db = await getDatabase();
  return await db.query(
    'floors',
    where: 'building_id = ?',
    whereArgs: [buildingId],
  );
}

Future<List<Map<String, dynamic>>> fetchAllFloorsOffices(int floorId) async {
  final Database db = await getDatabase();
  return await db.query(
    'offices',
    where: 'floor_id = ?',
    whereArgs: [floorId],
  );
}

Future<int> countBuildingFloors(int buildingId) async {
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> result = await db.rawQuery(
    'SELECT COUNT(*) as floorCount FROM floors WHERE building_id = ?',
    [buildingId],
  );

  return Sqflite.firstIntValue(result) ?? 0;
}

Future<List<Map<String, dynamic>>> fetchFloors(
    int buildingId, int floorNum) async {
  final Database db = await getDatabase();
  return await db.query(
    'floors',
    where: 'building_id = ? AND floor_num = ?',
    whereArgs: [buildingId, floorNum],
  );
}

Future<bool> fetchFloorByBuilding(int buildingId) async {
  final Database db = await getDatabase();
  List<Map<String, dynamic>> result = await db.query(
    'floors',
    where: 'building_id = ?',
    whereArgs: [buildingId],
  );
  print("RESULT $buildingId has floors $result");
  return result.isNotEmpty; // Returns true if at least one floor exists
}

Future<List<Map<String, dynamic>>> fetchOffices(int floorId) async {
  final Database db = await getDatabase();
  return await db.query(
    'offices',
    where: 'floor_id = ?',
    whereArgs: [floorId],
  );
}

Future<List<Map<String, dynamic>>> fetchStairs(int floorId) async {
  print("FLOOR ID FOR STAIRS: $floorId");
  final Database db = await getDatabase();
  return await db.query(
    'stairs',
    where: 'floor_id = ?',
    whereArgs: [floorId],
  );
}

Future<String?> fetchOfficeName(int? officeId) async {
  final Database db = await getDatabase();

  if (officeId == null) return null;
  List<Map<String, dynamic>> result = await db.query(
    'offices',
    columns: ['name'],
    where: 'id = ?',
    whereArgs: [officeId],
    limit: 1,
  );

  return result.isNotEmpty ? result.first['name'] as String : null;
}

Future<List<Map<String, dynamic>>> fetchPersonnel(int? officeId) async {
  final Database db = await getDatabase();
  if (officeId == null) return [];

  return await db.query(
    'personnel',
    where: 'office_id = ?',
    whereArgs: [officeId],
  );
}

Future<int?> fetchOfficeIdByPersonnel(int personnelId) async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT office_id 
    FROM personnel
    WHERE id = ?
  ''', [personnelId]);

  if (result.isNotEmpty) {
    return result.first['office_id'] as int;
  } else {
    return null; // No match found
  }
}

Future<List<Map<String, dynamic>>> fetchAllRouteLines(int campusId) async {
  final Database db = await getDatabase();

  final pointsResult = await db.query(
    'route_lines',
    where: 'campus_id = ?',
    whereArgs: [campusId],
    orderBy: 'id', // Ensure the points are ordered properly
  );

  return pointsResult;
}

Future<List<Map<String, dynamic>>> fetchAllRoutePoints(int campusId) async {
  final Database db = await getDatabase();

  final pointsResult = await db.query(
    'route_points',
    where: 'campus_id = ?',
    whereArgs: [campusId],
  );

  return pointsResult;
}

Future<List<Map<String, dynamic>>> fetchRoutePoints(List<int> pointIds) async {
  final Database db = await getDatabase();

  // Ensure the list is not empty
  if (pointIds.isEmpty) {
    return [];
  }

  // Fetch points from the route_points table
  final List<Map<String, dynamic>> points = await db.query(
    'route_points',
    where: 'id IN (${pointIds.map((_) => '?').join(',')})',
    whereArgs: pointIds.toSet().toList(), // Remove duplicates for the query
  );

  // Create a map of points for quick lookup
  final Map<int, Map<String, dynamic>> pointMap = {
    for (var point in points) point['id'] as int: point
  };

  // Reconstruct the list of points in the order of pointIds, including duplicates
  final List<Map<String, dynamic>> orderedPoints = [];
  for (var id in pointIds) {
    if (pointMap.containsKey(id)) {
      orderedPoints.add(pointMap[id]!);
    } else {
      print("Point with id $id not found in the database.");
    }
  }

  print("POINTS IN ROUTE: $orderedPoints");
  return orderedPoints;
}

// Future<List<Map<String, dynamic>>> fetchRoutePoints(List<int> pointIds) async {
//   final Database db = await getDatabase();

//   if (pointIds.isEmpty) {
//     return [];
//   }

//   return await db.rawQuery(
//     'SELECT id, latitude, longitude FROM route_points WHERE id IN (${List.filled(pointIds.length, '?').join(',')}) ORDER BY id',
//     pointIds.map((id) => id.toString()).toList(),
//   );
// }

// Future<Map<String, dynamic>> convertDBtoJSON(
//     List<Map<String, dynamic>> polygons,
//     String idString) async {
//   List<Map<String, dynamic>> features = polygons.map((polygon) {
//     List<dynamic> coordinates = jsonDecode(polygon['coordinates']);
//     int id = polygon['id'];

//     return {
//       "type": "Feature",
//       "id": "$idString-$id",
//       "geometry": {
//         "type": "Polygon",
//         "coordinates": [coordinates]
//       },
//     };
//   }).toList();

//   return {
//     "type": "FeatureCollection",
//     "features": features,
//   };
// }
