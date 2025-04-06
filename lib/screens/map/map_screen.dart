import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';


// IN CHARGE OF SHOWING THE MAP AND ITS INTERACTIONS 

class MapView extends StatelessWidget {
  final CameraOptions cameraOptions;
  final Function(MapboxMap) onMapCreated;
  final OnMapTapListener? onTapListener;
  final OnStyleDataLoadedListener? onStyleLoadedListener;

  const MapView({
    required this.cameraOptions,
    required this.onMapCreated,
    this.onTapListener,
    this.onStyleLoadedListener,
  });

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: cameraOptions,
      styleUri: 'mapbox://styles/meowmeowmeowmeoww/cm6npvb7c00sx01s21jx21x6r',
      onMapCreated: onMapCreated,
      onTapListener: onTapListener,
      onStyleDataLoadedListener: onStyleLoadedListener,
    );
  }
}
