List<double> getPolygonCentroid(List<dynamic> coordinates) {
  double sumLon = 0, sumLat = 0;
  for (var coord in coordinates) {
    sumLon += coord[0];
    sumLat += coord[1];
  }
  return [sumLon / coordinates.length, sumLat / coordinates.length];
}

List<dynamic> expandPolygon(List<dynamic> originalCoordinates, double factor) {
  List<double> centroid = getPolygonCentroid(originalCoordinates);
  List<dynamic> expandedCoordinates = [];

  for (var coord in originalCoordinates) {
    double lon = coord[0];
    double lat = coord[1];

    double newLon = centroid[0] + (lon - centroid[0]) * factor;
    double newLat = centroid[1] + (lat - centroid[1]) * factor;

    expandedCoordinates.add([newLon, newLat]);
  }

  return expandedCoordinates;
}

List<List<double>> extractMultiPolygonCoordinates(
    List<dynamic> rawCoordinates) {
  List<List<double>> extractedCoordinates = [];

  void extractFromList(List<dynamic> points) {
    for (var point in points) {
      if (point is List && point.isNotEmpty) {
        // Handle [ [ [lng, lat] ] ] or [ [lng, lat] ]
        if (point.length >= 2 && point[0] is num && point[1] is num) {
          // Extract only lng, lat
          double lng = (point[0] as num).toDouble();
          double lat = (point[1] as num).toDouble();
          extractedCoordinates.add([lng, lat]);
        } else {
          // Recursively handle nested lists
          extractFromList(point);
        }
      }
    }
  }

  // Normalize nesting: unwrap if deeply nested but empty
  List<dynamic> normalizedCoordinates = rawCoordinates;
  while (normalizedCoordinates.isNotEmpty &&
      normalizedCoordinates.first is List &&
      normalizedCoordinates.first.length == 1 &&
      normalizedCoordinates.first.first is List) {
    normalizedCoordinates = normalizedCoordinates.first;
  }

  extractFromList(normalizedCoordinates);

  if (extractedCoordinates.isEmpty) {
    print("⚠️ Warning: No valid coordinates found.");
  } else {
    print("✅ Extracted Coordinates: $extractedCoordinates");
  }

  return extractedCoordinates;
}
