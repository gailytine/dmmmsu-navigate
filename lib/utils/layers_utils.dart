import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'color_utils.dart';
import 'marker_utils.dart';

Future<void> initializeLayers(MapboxMap mapboxMap) async {
  // Initialize the layers in the correct order (from bottom to top)
  try {
    await _ensureStyleLoaded(mapboxMap);

    await Future.wait([
      initializeVenueLayer(mapboxMap),
      initializeBuildingLayer(mapboxMap),
      initializeFloorLayer(mapboxMap),
      initializeOfficeLayer(mapboxMap),
      initializeOfficeOutlineLayer(mapboxMap),
      initializeStairLayer(mapboxMap),
      initializeOutdoorMarkerLayer(mapboxMap),
      initializeIndoorMarkerLayer(mapboxMap),
      initializeRouteLayer(mapboxMap),
      initializePathLayer(mapboxMap),
      initializeWhiteOverlayLayer(mapboxMap),
      initializeMapOverlayLayer(mapboxMap),
    ]);

    print("All layers initialized successfully");
  } catch (e, stack) {
    print("Error during layer initialization: $e");
    print(stack);
    rethrow;
  }

  await mapboxMap.style.moveStyleLayer(
    "building-layer",
    LayerPosition(above: "venue-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "building-border-layer",
    LayerPosition(above: "building-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "floor-layer",
    LayerPosition(above: "building-border-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "office-layer",
    LayerPosition(above: "floor-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "stair-layer",
    LayerPosition(above: "office-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "office-outline-layer",
    LayerPosition(above: "office-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "outdoor-marker-layer",
    LayerPosition(above: "venue-outline-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "indoor-marker-layer",
    LayerPosition(above: "stair-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "route-layer",
    LayerPosition(above: "building-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "shortest-path-layer",
    LayerPosition(above: "route-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "overlay-layer",
    LayerPosition(below: "floor-layer"),
  );

  await mapboxMap.style.moveStyleLayer(
    "map-overlay-layer",
    LayerPosition(below: "floor-layer"),
  );

  // await mapboxMap.style.moveStyleLayer(
  //   "route-points-label-layer",
  //   LayerPosition(above: "shortest-path-layer"),
  // );

  //   await mapboxMap.style.moveStyleLayer(
  //   "marker-layer",
  //   LayerPosition(above: "building-layer"),
  // );
}

Future<void> _ensureStyleLoaded(MapboxMap mapboxMap) async {
  while (!await mapboxMap.style.isStyleLoaded()) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> hideOverlay(MapboxMap mapboxMap) async {
  // Hide the overlay layer by setting its opacity to 0
  await mapboxMap.style.setStyleLayerProperty(
    "overlay-layer",
    "fill-opacity",
    0.0,
  );
}

Future<void> clearIndoorLayers(MapboxMap mapboxMap) async {
  await mapboxMap.style.setStyleSourceProperty(
    "floor-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );

  await mapboxMap.style.setStyleSourceProperty(
    "office-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );

  await mapboxMap.style.setStyleSourceProperty(
    "stair-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );

  await mapboxMap.style.setStyleSourceProperty(
    "indoor-marker-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );
}

Future<void> clearOutdoorLayers(MapboxMap mapboxMap) async {
  await mapboxMap.style.setStyleSourceProperty(
    "building-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );

  await mapboxMap.style.setStyleSourceProperty(
    "venue-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );

  await mapboxMap.style.setStyleSourceProperty(
    "outdoor-marker-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );
}

Future<void> clearPath(MapboxMap mapboxMap) async {
  await mapboxMap.style.setStyleSourceProperty(
    "shortest-path-source",
    "data",
    jsonEncode({"type": "FeatureCollection", "features": []}),
  );
}

Future<void> initializeWhiteOverlayLayer(MapboxMap mapboxMap) async {
  // Ensure the style is loaded
  await mapboxMap.style.isStyleLoaded();

  // Check if the overlay source already exists
  bool sourceExists = await mapboxMap.style.styleSourceExists("overlay-source");

  if (!sourceExists) {
    // Add the overlay source if it doesn't exist
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "overlay-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));

    print("Overlay source added.");
  }

  // Check if the overlay layer already exists
  bool fillLayerExists =
      await mapboxMap.style.styleLayerExists("overlay-layer");

  if (!fillLayerExists) {
    // Add the overlay layer if it doesn't exist
    await mapboxMap.style.addLayer(FillLayer(
      id: "overlay-layer",
      sourceId: "overlay-source",
      fillColor: hexToColor('#ffffff'), // Semi-transparent white
      fillOpacity: 0.7,
    ));

    print("Overlay layer added.");
  }
}

Future<void> initializeMapOverlayLayer(MapboxMap mapboxMap) async {
  // Ensure the style is loaded
  await mapboxMap.style.isStyleLoaded();

  // Check if the overlay source already exists
  bool sourceExists =
      await mapboxMap.style.styleSourceExists("map-overlay-source");

  if (!sourceExists) {
    // Add the overlay source if it doesn't exist
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "map-overlay-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));

    print("Map overlay source added.");
  }

  // Check if the overlay layer already exists
  bool fillLayerExists =
      await mapboxMap.style.styleLayerExists("map-overlay-layer");

  if (!fillLayerExists) {
    // Add the overlay layer if it doesn't exist
    await mapboxMap.style.addLayer(FillLayer(
      id: "map-overlay-layer",
      sourceId: "map-overlay-source",
      fillColor: hexToColor('#ffffff'), // White color (won't be visible)
      fillOpacity: 0, // Fully transparent
    ));

    print("Map overlay layer added.");
  }
}

// INITIALIZE LAYERS FOR THE BUILDINGS
Future<void> initializeBuildingLayer(MapboxMap mapboxMap) async {
  try {
    // Wait for the style to load
    await mapboxMap.style.isStyleLoaded();

    // Check if the source exists
    bool sourceExists =
        await mapboxMap.style.styleSourceExists("building-source");
    if (!sourceExists) {
      // Add the source with an empty FeatureCollection
      await mapboxMap.style.addSource(GeoJsonSource(
        id: "building-source",
        data: jsonEncode({"type": "FeatureCollection", "features": []}),
      ));
      print("✅ Added 'building-source' to the map style.");
    }

    bool lineLayerExists =
        await mapboxMap.style.styleLayerExists("building-border-layer");
    if (!lineLayerExists) {
      // Add the LineLayer
      await mapboxMap.style.addLayer(LineLayer(
        id: "building-border-layer",
        sourceId: "building-source",
        lineWidth: 2.5,
        // lineColor: hexToColor('#92bbff'),
        lineColorExpression: [
          "case",
          [
            "boolean",
            ["get", "hasFloors"],
            false
          ], // Explicitly check for boolean `true`
          '#92bbff', // Blue for buildings with floors
          '#c0c8d6' // Gray for buildings without floors
        ],
      ));

      print("✅ Added 'building-border-layer' to the map style.");
    }

    // Check if the FillExtrusionLayer exists
    bool layerExists = await mapboxMap.style.styleLayerExists("building-layer");
    if (!layerExists) {
      // Add the FillExtrusionLayer
      await mapboxMap.style.addLayer(FillExtrusionLayer(
        id: "building-layer",
        sourceId: "building-source",
        fillExtrusionColorExpression: [
          "case",
          [
            "boolean",
            ["get", "hasFloors"],
            false
          ], // If hasFloors is false, gray color
          '#b9d3ff', // Blue for buildings with floors
          '#e9eaef'
        ],
        fillExtrusionHeight: 20,
        fillExtrusionOpacity: 1,
        fillExtrusionFloodLightGroundRadius: 5.0,
        fillExtrusionEdgeRadius: 0.15,
        fillExtrusionAmbientOcclusionGroundAttenuation: 1.0,
        fillExtrusionAmbientOcclusionGroundRadius: 1.0,
        fillExtrusionAmbientOcclusionIntensity: 0.5,
        fillExtrusionAmbientOcclusionRadius: 20.0,
        fillExtrusionAmbientOcclusionWallRadius: 10.0,
        fillExtrusionVerticalGradient: true,
      ));
      print("✅ Added 'building-layer' to the map style.");
    }

    // Check if the LineLayer exists
  } catch (e) {
    print("⚠️ Error in initializeBuildingLayer: $e");
  }
}

// INITIALIZE LAYER FOR WHEN BUILDING IS TAPPED
Future<void> initializeFloorLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists = await mapboxMap.style.styleSourceExists("floor-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "floor-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool fillLayerExists = await mapboxMap.style.styleLayerExists("floor-layer");

  if (!fillLayerExists) {
    await mapboxMap.style.addLayer(FillLayer(
      id: "floor-layer",
      sourceId: "floor-source",
      fillColor: hexToColor("#4e5e82"),
      fillOpacity: 0,
      // fillOutlineColor: hexToColor("#d3dbeb"),
    ));
  }

//check later if linewidth works
  // bool lineLayerExists =
  //     await mapboxMap.style.styleLayerExists("highlight-outline-layer");

  // if (!lineLayerExists) {
  //   await mapboxMap.style.addLayer(LineLayer(
  //     id: "highlight-outline-layer",
  //     sourceId: "highlight-source",
  //     lineColor: hexToColor("#d3dbeb"),
  //     lineWidthExpression: [
  //       "interpolate",
  //       ["linear"],
  //       ["zoom"],
  //       10, 2.0, // At zoom level 10, line width is 2.0
  //       15, 4.0 // At zoom level 15, line width is 4.0
  //     ],
  //   ));
  // }
}

Future<void> initializeOfficeOutlineLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("office-outline-source");
  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "office-outline-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool outlineLayerExists =
      await mapboxMap.style.styleLayerExists("office-outline-layer");
  if (!outlineLayerExists) {
    await mapboxMap.style.addLayer(LineLayer(
      id: "office-outline-layer",
      sourceId: "office-outline-source",
      lineColor: hexToColor('#92bbff'),
      lineWidth: 10, // Adjust for visibility
    ));
    print("✅ Venue outline layer created!");
  }
}

//INITIALIZE OFFICE LAYER
Future<void> initializeOfficeLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists = await mapboxMap.style.styleSourceExists("office-source");
  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "office-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool layerExists = await mapboxMap.style.styleLayerExists("office-layer");
  if (!layerExists) {
    await mapboxMap.style.addLayer(FillLayer(
      id: "office-layer",
      sourceId: "office-source",
      fillColor: hexToColor("#b9d3ff"),
      fillOpacity: 1,
    ));
  }
}

Future<void> initializeStairLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists = await mapboxMap.style.styleSourceExists("stair-source");
  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "stair-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool layerExists = await mapboxMap.style.styleLayerExists("stair-layer");
  if (!layerExists) {
    await mapboxMap.style.addLayer(FillLayer(
      id: "stair-layer",
      sourceId: "stair-source",
      fillColor: hexToColor("#5b75af"),
      fillOpacity: 1,
    ));
  }
}

Future<void> initializeVenueLayer(MapboxMap mapboxMap) async {
  // Ensure the map style is fully loaded before proceeding
  while (!await mapboxMap.style.isStyleLoaded()) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  bool sourceExists = await mapboxMap.style.styleSourceExists("venue-source");
  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "venue-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool layerExists = await mapboxMap.style.styleLayerExists("venue-layer");
  if (!layerExists) {
    await mapboxMap.style.addLayer(FillLayer(
      id: "venue-layer",
      sourceId: "venue-source",
      fillColorExpression: [
        'match', ['get', 'venueType'],
        'water', "#a3dbf4", // Light blue for water
        'oval', "#b2f2d3", // Default blue for land
        'court', "#ffe9be", // Orange for courts
        'rice', "#fdc898",
        'field', "#afe88b", // Green for fields
        "#b2f2d3" // Default
      ],
      fillOpacity: 1, // Adjust for visibility
    ));
    print("✅ Venue layer created!");
  }

  // Add an outline layer for better distinction
  bool outlineLayerExists =
      await mapboxMap.style.styleLayerExists("venue-outline-layer");
  if (!outlineLayerExists) {
    await mapboxMap.style.addLayer(LineLayer(
      id: "venue-outline-layer",
      sourceId: "venue-source",
      lineColorExpression: [
        'match', ['get', 'venueType'],
        'water', "#71c7ec", // Darker blue for water outline
        'oval', "#5ec27a", // Green outline for land
        'court', "#fac93e", // Dark brown outline for courts
        'rice', "#fba252", // Dark green outline for fields
        'field', "#5abf5b",
        "#5ec27a" // Default dark gray outline
      ],
      lineWidth: 0.3, // Adjust for visibility
    ));
    print("✅ Venue outline layer created!");
  }
}

Future<void> initializeOutdoorMarkerLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("outdoor-marker-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "outdoor-marker-source",
      data: jsonEncode({
        "type": "FeatureCollection",
        "features": [],
      }),
    ));
  }

  // Call the function to add the marker image
  await insertOustideImages(mapboxMap);

  bool layerExists =
      await mapboxMap.style.styleLayerExists("outdoor-marker-layer");

  if (!layerExists) {
    await mapboxMap.style.addLayer(
      SymbolLayer(
        id: "outdoor-marker-layer",
        sourceId: "outdoor-marker-source",
        minZoom: 0,
        maxZoom: 22,

        iconAllowOverlap: true,
        iconImageExpression: [
          'match', ['get', 'icon_type'],
          'admin', 'marker-admin',
          'medical', 'marker-medical',
          'library', 'marker-library',
          're', 'marker-re',
          'canteen', 'marker-canteen',

          'ccs', 'marker-ccs',
          'ce', 'marker-ce',
          'cchams', 'marker-cchams',
          'cas', 'marker-cas',
          'com', 'marker-com',
          'cgs', 'marker-cgs',
          'cf', 'marker-cf',
          'ca', 'marker-ca',

          'oval', 'marker-oval',
          'pool', 'marker-pool',
          'bb', 'marker-bb',
          'vb', 'marker-vb',
          'tc', 'marker-tc',
          'sc', 'marker-sc',

          'water', 'marker-water',
          'field', 'marker-field',
          'stage', 'marker-stage',
          'entrance', 'marker-entrance',

          'marker-default' // Default icon
        ],
        iconSizeExpression: [
          'match', ['get', 'type'], // Get the "type" property
          'building', 0.1, // If type is "building", size is 1.5
          'venue', 0.08, // If type is "venue", size is 1.2
          0.08 // Default size (for other types)
        ],
        iconOffset: [0, -200], // Move 10 pixels up

        textFieldExpression: ["get", "name"],
        textSizeExpression: [
          'match', ['get', 'type'], // Get the "type" property
          'building', 12.0, // If type is "building", size is 1.5
          // 'venue', 10.0, // If type is "venue", size is 1.2
          10.0 // Default size (for other types)
        ],
        textOffset: [0, 1],
        textColor: hexToColor('#ffffff'), // White text
        textHaloColorExpression: [
          'match', ['get', 'icon_type'],

          'admin', '#ADAEC8',
          'medical', '#f85050',
          'library', '#FCC841',
          're', '#14C18B',
          'canteen', '#FCC841',

          'ccs', '#FF8BD4',
          'ce', '#6D81FF',
          'cchams', '#FCC841',
          'cas', '#14C18B',
          'com', '#FBA252',
          'cgs', '#FF6C63',
          'cf', '#32C6E8',
          'ca', '#93CD51',

          'oval', '#ef6d3d',
          'pool', '#ef6d3d',
          'bb', '#ef6d3d',
          'vb', '#ef6d3d',
          'tc', '#ef6d3d',
          'sc', '#ef6d3d',

          'water', '#32c6e8',
          'field', '#93cd51',
          'stage', '#FCC841',
          'entrance', '#ADAEC8',

          '#ADAEC8' // Default
        ],
        textHaloWidth: 2, // Border thickness
        textFont: ['Open Sans Bold'], // Bold text
      ),
    );
    print("✅ Marker layer created!");
  }
}

Future<void> initializeIndoorMarkerLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("indoor-marker-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "indoor-marker-source",
      data: jsonEncode({
        "type": "FeatureCollection",
        "features": [],
      }),
    ));
  }

  // Call the function to add the marker image
  await insertInsideImages(mapboxMap);

  // bool hasStairUpImage = await mapboxMap.style.hasStyleImage("marker-stair-up");
  // bool hasStairDownImage =
  //     await mapboxMap.style.hasStyleImage("marker-stair-down");

  // print("🔍 Stair Up Image Exists: $hasStairUpImage");
  // print("🔍 Stair Down Image Exists: $hasStairDownImage");

  bool layerExists =
      await mapboxMap.style.styleLayerExists("indoor-marker-layer");

  if (!layerExists) {
    await mapboxMap.style.addLayer(
      SymbolLayer(
        id: "indoor-marker-layer",
        sourceId: "indoor-marker-source",
        minZoom: 0,
        maxZoom: 22,

        iconAllowOverlap: true,
        iconImageExpression: [
          'match', ['get', 'icon_type'],
          'building-entrance', 'marker-building-entrance',
          'office-entrance', 'marker-office-entrance',
          'office', 'marker-office',
          'canteen', 'marker-canteen',
          'stair-up', 'marker-stair-up',
          'stair-down', 'marker-stair-down',

          'marker-default' // Default icon
        ],
        iconSize: 0.08,
        // iconOffset: [0, -200], // Move 10 pixels up

        textFieldExpression: ["get", "name"],
        textSizeExpression: [
          'match', ['get', 'type'],
          'room', 14.0,
          // 'venue', 0.05,
          12.0
        ],
        textOffset: [0, -2],
        textColor: hexToColor('#ffffff'), // White text
        textHaloColorExpression: [
          'match', ['get', 'icon_type'],

          'office', '#FCC841',
          'canteen', '#FCC841',
          'stair-up', '#ADAEC8',
          'stair-down', '#ADAEC8',

          '#ADAEC8' // Default
        ],
        textHaloWidth: 2, // Border thickness
        textFont: ['Open Sans Bold'], // Bold text
      ),
    );
    print("✅ Marker layer created!");
  }
}

Future<void> initializePathLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists = await mapboxMap.style.styleSourceExists("route-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "route-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool lineLayerExists = await mapboxMap.style.styleLayerExists("route-layer");

  if (!lineLayerExists) {
    await mapboxMap.style.addLayer(LineLayer(
      id: "route-layer",
      sourceId: "route-source",
      lineColor: hexToColor("#d9dce8"),
      lineWidth: 10,
      lineOpacity: 1,
      lineBorderColor: hexToColor("#a0a6c0"),
      lineBorderWidth: 1,
    ));
  }
}

Future<void> initializeRouteLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("shortest-path-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "shortest-path-source",
      data: jsonEncode({"type": "FeatureCollection", "features": []}),
    ));
  }

  bool lineLayerExists =
      await mapboxMap.style.styleLayerExists("shortest-path-layer");

  if (!lineLayerExists) {
    await mapboxMap.style.addLayer(LineLayer(
      id: "shortest-path-layer",
      sourceId: "shortest-path-source",
      lineColor: hexToColor("#0081E8"),
      lineWidth: 15,
      lineOpacity: 1,
      // lineBorderColor: hexToColor("#595959"),
      lineBorderWidth: 2,
    ));
  }
}

Future<void> initializeNavigationnMarkerLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  bool sourceExists =
      await mapboxMap.style.styleSourceExists("navigation-marker-source");

  if (!sourceExists) {
    await mapboxMap.style.addSource(GeoJsonSource(
      id: "navigation-marker-source",
      data: jsonEncode({
        "type": "FeatureCollection",
        "features": [],
      }),
    ));
  }

  // Call the function to add the marker image
  await insertNavigationImages(mapboxMap);

  bool layerExists =
      await mapboxMap.style.styleLayerExists("navigation-marker-layer");

  if (!layerExists) {
    await mapboxMap.style.addLayer(
      SymbolLayer(
        id: "navigation-marker-layer",
        sourceId: "navigation-marker-source",
        minZoom: 0,
        maxZoom: 22,

        iconAllowOverlap: true,
        iconImageExpression: [
          'match', ['get', 'icon_type'],
          'building-entrance', 'marker-building-entrance',
          'office-entrance', 'marker-office-entrance',

          'marker-default' // Default icon
        ],
        iconSize: 0.08,
        // iconOffset: [0, -200], // Move 10 pixels up
      ),
    );
    print("✅ Marker layer created!");
  }
}

Future<void> initializePointLabelLayer(MapboxMap mapboxMap) async {
  await mapboxMap.style.isStyleLoaded();

  const pointsSourceId = "route-points-source";
  const labelLayerId = "route-points-label-layer";

  // Ensure the symbol layer exists for displaying labels
  bool labelLayerExists = await mapboxMap.style.styleLayerExists(labelLayerId);
  if (!labelLayerExists) {
    await mapboxMap.style.addLayer(SymbolLayer(
      id: labelLayerId,
      sourceId: pointsSourceId,
      textFieldExpression: [
        "get",
        "title"
      ], // Make sure "title" exists in GeoJSON properties
      textSize: 14,
      textColor: hexToColor("#000000"),
      textHaloColor: hexToColor("#FFFFFF"),
      textHaloWidth: 2,
      textAnchor: TextAnchor.TOP,
      textOffset: [0, 1.5], // Adjust label position above the point
    ));
  }
}
