import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// bool selectedBuildingHasFloors = false;
// int totalFloors = 0;

Map<String, Map<String, Point>> locationPoints = {
  'SLUC Agoo': {
    'southwest':
        Point(coordinates: Position(120.36984891062082, 16.32367306097113)),
    'northeast':
        Point(coordinates: Position(120.37547715472397, 16.32771718864815)),
  },
  'SLUC Santo Tomas': {
    'southwest':
        Point(coordinates: Position(120.38139703005294, 16.262708545033533)),
    'northeast':
        Point(coordinates: Position(120.39157934128343, 16.27484692732604)),
  },
  'SLUC Rosario': {
    'southwest':
        Point(coordinates: Position(120.412931879481, 16.23678237519667)),
    'northeast':
        Point(coordinates: Position(120.41721916058566, 16.240239307459674)),
  },
  // 'BAHAY KO': {
  //   'southwest':
  //       Point(coordinates: Position(120.37107626510306, 16.311798650285454)),
  //   'northeast':
  //       Point(coordinates: Position(120.37286497510786, 16.313212026652337)),
  // },
};

Map<String, int> campusIds = {
  'SLUC Agoo': 1,
  'SLUC Santo Tomas': 2,
  'SLUC Rosario': 3,
};

int? getCampusId(String campusName) {
  return campusIds[campusName]; // Returns ID or null if not found
}

// bool isLoading = true;
