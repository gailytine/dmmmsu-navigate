import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxConfig {
  static String get accessToken {
    return "pk.eyJ1IjoibWVvd21lb3dtZW93bWVvd3ciLCJhIjoiY20zM3NxaWtxMWdyZTJscTNmeHU3YmF6ZSJ9.-ciQQTfeIWhN5J5_WdosXg"; 
  }

  static void setAccessToken() {
    MapboxOptions.setAccessToken(accessToken);
  }
}
