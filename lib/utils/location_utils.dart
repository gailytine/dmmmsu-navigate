import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:turf/turf.dart' as turfLib;

// import 'map_utils.dart';

Future<LocationData?> getUserLocation(Location locationService) async {
  try {
    LocationData locationData = await locationService.getLocation();
    print(
        'User Location: Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
    return locationData;
  } catch (e) {
    print('Error retrieving location: $e');
    return null;
  }
}

Stream<Point?> startLocationUpdates(Location locationService) async* {
  await for (LocationData locationData in locationService.onLocationChanged) {
    if (locationData.latitude != null && locationData.longitude != null) {
      print(
          'Updated Location: Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
      Point newPosition = Point(
        coordinates: Position(locationData.longitude!, locationData.latitude!),
      );

      yield newPosition;
    }
  }
}

void stopLocationTracking(Location locationService) {
  locationService.changeSettings(
    accuracy: LocationAccuracy.low, // Lower accuracy to save power
    distanceFilter: 1000, // Large threshold to prevent frequent updates
    interval: 60000, // Check every 1 minute (in case user enters the area)
  );
}

//if user is detected in the bounds (campuses), return true in initialization
// Stream<bool?> isUserInBound(
//     Location locationService, Point? southwest, Point? northeast) async* {
//   await for (Point? newPosition in startLocationUpdates(locationService)) {
//     if (newPosition != null) {
//       double swLat = southwest!.coordinates.lat.toDouble();
//       double swLng = southwest.coordinates.lng.toDouble();
//       double neLat = northeast!.coordinates.lat.toDouble();
//       double neLng = northeast.coordinates.lng.toDouble();

//       double userLat = newPosition.coordinates.lat.toDouble();
//       double userLng = newPosition.coordinates.lng.toDouble();

//       if (userLat >= swLat &&
//           userLng >= swLng &&
//           userLat <= neLat &&
//           userLng <= neLng) {
//         yield true;
//       } else {
//         yield false;
//       }
//       // if(newPosition)
//       // updateCameraPosition(newPosition, mapboxMap, camera);
//     }
//   }
// }

Future<bool?> isUserInBoundInit(
    Location locationService, Point? southwest, Point? northeast) async {
  LocationData? userLocation = await getUserLocation(locationService);

  if (userLocation != null) {
    double swLat = southwest!.coordinates.lat.toDouble();
    double swLng = southwest.coordinates.lng.toDouble();
    double neLat = northeast!.coordinates.lat.toDouble();
    double neLng = northeast.coordinates.lng.toDouble();

    double userLat = userLocation.latitude!;
    double userLng = userLocation.longitude!;

    if (userLat >= swLat &&
        userLng >= swLng &&
        userLat <= neLat &&
        userLng <= neLng) {
      return true;
    }
  }
  return false;
}

Point computeCenterBound(Point southwest, Point northeast) {
  double centerLatitude =
      ((southwest.coordinates.lat + southwest.coordinates.lng) / 2).toDouble();
  double centerLongitude =
      ((northeast.coordinates.lat + northeast.coordinates.lng) / 2).toDouble();

  Point centerPosition =
      Point(coordinates: Position(centerLongitude, centerLatitude));

  return centerPosition;
}

Point fromListToPoint(List<dynamic> coordinateList) {
  Point coordinatePoints =
      Point(coordinates: Position(coordinateList[0], coordinateList[1]));
  return coordinatePoints;
}

Point locationToPoint(LocationData location) {
  return Point(coordinates: Position(location.longitude!, location.latitude!));
}

List<List<double>> roundPolygonPoints(List<List<double>> polygonPoints,
    {int precision = 12}) {
  return polygonPoints.map((point) {
    return [
      double.parse(point[0].toStringAsFixed(precision)),
      double.parse(point[1].toStringAsFixed(precision)),
    ];
  }).toList();
}

List<List<List<double>>> parseCoordinates(dynamic coordinates) {
  if (coordinates is List) {
    return coordinates.map((outer) {
      if (outer is List) {
        return outer.map((inner) {
          if (inner is List) {
            return inner.map((value) {
              if (value is double) {
                return value;
              } else if (value is int) {
                return value.toDouble();
              } else {
                throw FormatException("Invalid coordinate value: $value");
              }
            }).toList();
          } else {
            throw FormatException("Invalid inner coordinate list: $inner");
          }
        }).toList();
      } else {
        throw FormatException("Invalid outer coordinate list: $outer");
      }
    }).toList();
  } else {
    throw FormatException("Invalid coordinates format: $coordinates");
  }
}

// Map<String, double> parseCentroid(String centroid) {
//   List<String> parts = centroid.split(',');
//   return {
//     'lat': double.parse(parts[0]),
//     'lng': double.parse(parts[1]),
//   };
// }
