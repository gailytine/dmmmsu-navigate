import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// import 'package:dmmmsu_navigate/global_variable.dart';

// FUNCTIONS THAT CAN BE USED FOR THE MAP

Future<Uint8List> loadPuckImage(String assetPath) async {
  try {
    final ByteData bytes = await rootBundle.load(assetPath);
    final imageBytes = bytes.buffer.asUint8List();
    return imageBytes;
  } catch (e) {
    return Uint8List.fromList([]);
  }
}

void logZoomLevel(MapboxMap? mapboxMap) async {
  if (mapboxMap != null) {
    try {
      CameraState cameraState = await mapboxMap.getCameraState();
      double zoomLevel = cameraState.zoom;
      print('Current Zoom Level: $zoomLevel');
    } catch (e) {
      print('Error retrieving zoom level: $e');
    }
  } else {
    print('Map is not initialized yet.');
  }
}

Future<void> boundMap(MapboxMap? mapboxMap, Point southwest, Point northeast,
    double maxZoom, double minZoom) async {
  final bounds = CoordinateBounds(
    southwest: southwest,
    northeast: northeast,
    infiniteBounds: false,
  );

  mapboxMap?.setBounds(CameraBoundsOptions(
    bounds: bounds,
    maxZoom: maxZoom,
    minZoom: minZoom,
  ));
}

Map<String, Point> getBoundingBox(List<dynamic> coordinates) {
  double minLat = double.infinity;
  double maxLat = -double.infinity;
  double minLng = double.infinity;
  double maxLng = -double.infinity;

  for (var coord in coordinates) {
    double lng = coord[0];
    double lat = coord[1];

    if (lat < minLat) minLat = lat;
    if (lat > maxLat) maxLat = lat;
    if (lng < minLng) minLng = lng;
    if (lng > maxLng) maxLng = lng;
  }

  // 🔹 Compute width & height of the box
  double latDiff = maxLat - minLat;
  double lngDiff = maxLng - minLng;

  // 🔹 Expand the bounding box (5% of width & height)
  double expandLat = latDiff * 0.05; // Expand height
  double expandLng = lngDiff * 0.05; // Expand width

  print("POSITIONS BBOX SE: ${(minLat - expandLat)}, ${minLng - expandLng}");
  print("POSITIONS BBOX NE: ${(maxLat - expandLat)}, ${maxLng - expandLng}");

  return {
    "sw":
        Point(coordinates: Position((minLat - expandLat), minLng - expandLng)),
    "ne": Point(coordinates: Position(maxLat + expandLat, maxLng + expandLng)),
  };
}

(Point, Point) expandBoundingBox(Point sw, Point ne, double expansionPixels,
    double zoom, double mapWidth, double mapHeight) {
  // Estimate degrees per pixel (varies by latitude & zoom)
  double latPerPixel = (ne.coordinates.lat - sw.coordinates.lat) / mapHeight;
  double lngPerPixel = (ne.coordinates.lng - sw.coordinates.lng) / mapWidth;

  // Expand the bounding box by `expansionPixels`
  double latExpansion = latPerPixel * expansionPixels;
  double lngExpansion = lngPerPixel * expansionPixels;

  return (
    Point(
        coordinates: Position(sw.coordinates.lat - latExpansion,
            sw.coordinates.lng - lngExpansion)), // Expanded SW
    Point(
        coordinates: Position(ne.coordinates.lat + latExpansion,
            ne.coordinates.lng + lngExpansion)) // Expanded NE
  );
}


Future<void> updateCameraPosition(
  Point newPosition, 
  MapboxMap? mapboxMap, 
  CameraOptions camera, 
  double? zoom,
) async {
  if (mapboxMap == null) return;

  // Update the camera options
  camera.center = newPosition;
  camera.zoom = zoom;
  camera.bearing = 0; // Optional: Reset bearing to north
  camera.pitch = 0;   // Optional: Reset pitch to flat

  // Use `flyTo` for a smooth camera transition
  await mapboxMap.flyTo(
    camera,
    MapAnimationOptions(
      duration: 2000, // Duration of the animation in milliseconds
      startDelay: 0,   // Optional delay before the animation starts
    ),
  );
}