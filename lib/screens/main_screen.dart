import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Visibility;
import 'package:location/location.dart';
import 'package:dmmmsu_navigate/global_variable.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../config/change_notifier.dart';

import 'package:dmmmsu_navigate/screens/ui/search_bar.dart' as custom;

import '../database/local_database/queries.dart';

// import '../utils/permission_utils.dart';
import '../utils/map_utils.dart';
import '../utils/location_utils.dart';
import '../utils/layers_utils.dart';
import '../utils/geojson_utils.dart';
import '../utils/polygon_animation_utils.dart';
import '../utils/marker_utils.dart';
import '../utils/line_utils.dart';
import '../utils/search_utils.dart';
import '../utils/navigation_utils.dart';
import '../utils/office_utils.dart';

// import '../config/mapbox_config.dart';

import 'ui/dropdown_list.dart';
import 'ui/toast.dart';
import 'ui/dialog_boxes.dart';
import 'ui/map_buttons.dart';
import 'ui/bottom_bar.dart';
import 'ui/navigation_button.dart';
import 'ui/navigation_buttons.dart';
import 'ui/navigation_card.dart';
import 'ui/navigation_topbar.dart';
import 'ui/navigation_bottom_sheet.dart';
import 'ui/image_viewer.dart';
// import 'ui/toggle_switch.dart';
// import 'ui/search_bar.dart';
import 'ui/top_bar.dart';

import 'map/map_screen.dart';
import 'map/polygon_screen.dart';

// THIS SCREEN CALLS UPON ALL FUNCTIONS AND UIS, THIS IS WHERE EVERYTHING IS SEEN

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late CameraOptions camera;
  final Location locationService = Location();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final double arrivalRadius = 10.0;

  MapboxMap? mapboxMap;
  Point? campusCentroid;
  StreamSubscription<Point?>? _locationSubscription;
  StreamController<double> _distanceController =
      StreamController<double>.broadcast();
  Stream<double> get distanceStream => _distanceController.stream;

  Map<String, dynamic>? buildingInfo;
  List<List<double>>? buildingEntrances;
  List<List<double>>? routePoints;
  Point? selectedBuildingCentroid;
  int? selectedOfficeId;

  String selectedBuildingName = "";
  String dropdownValue = locationPoints.keys.first;
  String loadingText = "";
  String? buildingImgName;

  int selectedBuildingId = 0;
  int selectedFloorId = 0;
  int officeFloorNum = 0;
  // int campusId = 1;

  bool isUIVisible = false;
  bool isUserInBound = false;
  bool isInCampus = false;
  bool _showPersonnelList = false;
  // Add this to your _MainScreenState class
  bool _showImage = false;

  // bool selectedBuildingHasFloors = false;
  bool isBuildingSelected = false;
  bool buildingHasFloors = false;
  bool isRefreshPressed = false;
  bool isMapLoaded = false;
  bool pressedNavigation = false;
  bool isNavigating = false;
  bool _isNavigationSheetVisible = false;
  bool inCampus = false;

  double _distanceToBuilding = 0.0;

  Point? southwest;
  Point? northeast;

  @override
  void initState() {
    super.initState();

    loadingText = "Loading Map. Please wait a moment...";
    southwest = locationPoints[dropdownValue]?['southwest'];
    northeast = locationPoints[dropdownValue]?['northeast'];

    campusCentroid = computeCenterBound(southwest!, northeast!);

    Point center = computeCenterBound(southwest!, northeast!);
    camera = CameraOptions(
      center: center,
      zoom: 10,
    );
    _initializeMap();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectUserInBound(); // Ensures it runs after the first frame
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _distanceController.close();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update every 10 meters
      interval: 5000, // update every 5 seconds
    );
  }

  void _enableLocationTracking() async {
    final imageBytes = await loadPuckImage('assets/shapes/red_circle.png');

    mapboxMap?.location.updateSettings(LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
      locationPuck: LocationPuck(
        locationPuck2D: DefaultLocationPuck2D(
          topImage: imageBytes,
          shadowImage: Uint8List.fromList([]),
        ),
      ),
    ));
  }

  Future<bool> _isUserInSelectedCampus() async {
    LocationData? userLocation = await getUserLocation(locationService);
    if (userLocation == null) return false;

    Point userPoint = Point(
      coordinates: Position(
        userLocation.longitude!,
        userLocation.latitude!,
      ),
    );

    return isPointInBounds(userPoint, southwest!, northeast!);
  }

  bool isPointInBounds(Point point, Point southwest, Point northeast) {
    return point.coordinates.lng >= southwest.coordinates.lng &&
        point.coordinates.lng <= northeast.coordinates.lng &&
        point.coordinates.lat >= southwest.coordinates.lat &&
        point.coordinates.lat <= northeast.coordinates.lat;
  }

//when user inside the campus, it will focus on the user // this should happen when map is loaded in
  Future<void> _detectUserInBound() async {
    bool isRefreshPressed = true;
    bool foundInAnyBound = false;
    bool? isInBound =
        await isUserInBoundInit(locationService, southwest, northeast);

    if (isInBound == true) {
      setState(() {
        isInCampus = true; // User is inside the campus
      });

      LocationData? userLocation = await getUserLocation(locationService);

      if (userLocation != null) {
        Point newPosition = Point(
            coordinates:
                Position(userLocation.longitude!, userLocation.latitude!));
        updateCameraPosition(newPosition, mapboxMap, camera, 15);
      }
    } else {
      for (var entry in locationPoints.entries) {
        Point? otherSouthwest = entry.value['southwest'];
        Point? otherNortheast = entry.value['northeast'];

        if (otherSouthwest != null && otherNortheast != null) {
          bool? isInOtherBound = await isUserInBoundInit(
              locationService, otherSouthwest, otherNortheast);

          if (isInOtherBound == true) {
            foundInAnyBound = true;

            if (await userInOtherBoundAlert(context, entry.key)) {
              _handleDropdownChange(entry.key);
              setState(() {
                isInCampus = true; // User is inside another campus
              });
            }
            break;
          }
        }
      }
      if (!foundInAnyBound) {
        stopLocationTracking(locationService);
        setState(() {
          isInCampus = false; // User is outside the campus
        });
      }
    }

    if (isRefreshPressed && isMapLoaded) {
      showCampusStatusToast();
      setState(() {
        isRefreshPressed = false; // Reset the state
      });
    }
  }

  Future<void> _onRecenter() async {
    LocationData? userLocation = await getUserLocation(locationService);

    if (isInCampus) {
      if (userLocation != null) {
        Point newPosition = Point(
            coordinates:
                Position(userLocation.longitude!, userLocation.latitude!));
        updateCameraPosition(newPosition, mapboxMap, camera, 20);
      }
    } else {
      updateCameraPosition(campusCentroid!, mapboxMap, camera, 15);
    }
  }

  /// Helper function to recenter the map
  // void _recenterMap(LatLng targetLocation) {
  //   // Assuming you have a method to update the map's camera position
  //   // Example: Using a `MapController` or similar
  //   mapController.animateCamera(
  //     CameraUpdate.newLatLng(targetLocation),
  //   );
  // }
  Future<void> showCampusStatusToast() async {
    if (!isMapLoaded) return; // Do not show toast if map is not loaded

    Future.delayed(Duration(milliseconds: 500), () {
      if (isInCampus) {
        ToastUtil.showCustomToast(
          "🎉 Welcome back to ${dropdownValue}!",
          borderColor: Colors.green,
        );
      } else {
        ToastUtil.showCustomToast(
          "⚠️ You are outside the campus! Some features may not work.",
          borderColor: Colors.red,
        );
      }
    });
  }

  //when user picks an option in the drop down list, it will trigger these events
  void _handleDropdownChange(String? value) async {
    final context = _scaffoldKey.currentContext!;
    final appState = Provider.of<AppStateNotifier>(context, listen: false);

    if (value != null) {
      setState(() {
        dropdownValue = value;

        southwest = locationPoints[dropdownValue]?['southwest'];
        northeast = locationPoints[dropdownValue]?['northeast'];

        if (southwest != null && northeast != null) {
          Point centerPosition = computeCenterBound(southwest!, northeast!);
          boundMap(mapboxMap, southwest!, northeast!, 22, 15);
          updateCameraPosition(centerPosition, mapboxMap, camera, 10);
        }
      });

      bool isInCampus = await _isUserInSelectedCampus();
      setState(() {
        this.isInCampus = isInCampus;
      });

      if (dropdownValue.isNotEmpty) {
        try {
          int? campusId = getCampusId(dropdownValue);
          appState.setCampusId(campusId!);

          if (campusId != null) {
            clearOutdoorLayers(mapboxMap!);

            await addBuildingPolygon(mapboxMap!, campusId);
            await addVenuePolygon(mapboxMap!, campusId);
            await updateOutdoorMarkerLayer(mapboxMap!, campusId);
            await updateRouteLayer(mapboxMap!, campusId);

            setState(() {
              // Update any state variables if necessary
            });
          }
        } catch (e) {
          print("Error updating map layers: $e");
          // Optionally, show an error message to the user
        }
      }
    }
  }

  void _selectBuilding(String buildingName) {
    fadeOutSymbols(mapboxMap!, 'outdoor-marker-layer');

    setState(() {
      isBuildingSelected = true;
      selectedBuildingName = buildingName;
      mapboxMap?.gestures
          .updateSettings(GesturesSettings(rotateEnabled: false));
    });

    print("Building selected: $isBuildingSelected"); // Debug print
  }

  void _deselectBuilding() {
    fadeInSymbols(mapboxMap!, 'outdoor-marker-layer');
    hideOverlay(mapboxMap!);
    clearOfficeHighlight(mapboxMap!);

    setState(() {
      _resetView();

      isBuildingSelected = false;
      selectedBuildingCentroid = null;

      print("Building deselected: $isBuildingSelected"); // Debug print

      clearIndoorLayers(mapboxMap!);
      mapboxMap?.gestures.updateSettings(GesturesSettings(rotateEnabled: true));
    });
  }

  void _configureCompass() {
    if (mapboxMap != null) {
      final compassSettings = CompassSettings(
        position: OrnamentPosition.TOP_RIGHT,
        marginLeft: 0.0,
        marginTop: 90.0,
        marginRight: 15.0,
        marginBottom: 0.0,
      );
      mapboxMap!.compass.updateSettings(compassSettings);
    }
  }

  void _configureScaleBar() {
    if (mapboxMap != null) {
      final scaleBarSettings = ScaleBarSettings(
        position: OrnamentPosition.TOP_LEFT, // Move to bottom-left
        marginLeft: 15.0, // Adjust left margin
        marginTop: 95.0,
        marginRight: 0.0,
        marginBottom: 0.0, // Adjust bottom margin
      );
      mapboxMap!.scaleBar.updateSettings(scaleBarSettings);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    final context = _scaffoldKey.currentContext!;
    final appState = Provider.of<AppStateNotifier>(context, listen: false);
    this.mapboxMap = mapboxMap;

    appState.setLoading(true);

    _configureCompass();
    _configureScaleBar();
    _enableLocationTracking();

    Point? southwest = locationPoints[dropdownValue]?['southwest'];
    Point? northeast = locationPoints[dropdownValue]?['northeast'];
    if (southwest != null && northeast != null) {
      boundMap(mapboxMap, southwest, northeast, 22, 15);
    }

    try {
      // Perform all asynchronous operations
      await initializeLayers(mapboxMap);

      await addBuildingPolygon(mapboxMap, appState.campusId);
      await addVenuePolygon(mapboxMap, appState.campusId);
      await updateOutdoorMarkerLayer(mapboxMap, appState.campusId);
      await updateRouteLayer(mapboxMap, appState.campusId);
      // await updatePointLayer(mapboxMap);
    } catch (e) {
      print('Error during map initialization: $e');
      // Handle errors (e.g., show a toast or snackbar)
    } finally {
      setState(() {
        appState.setLoading(false);
        // isLoading = false;
        isMapLoaded = true;
      });

      await showCampusStatusToast();
    }
  }

  void _resetView() {
    // print("BUILDING GEOMETRY: $selectedBuildingCentroid");
    if (selectedBuildingCentroid != null) {
      // List<dynamic> coordinates = selectedBuildingCentroid!;
      // List<double> centroid = getPolygonCentroid(coordinates);

      setState(() {
        boundMap(mapboxMap, southwest!, northeast!, 22, 15);
        updateCameraPosition(selectedBuildingCentroid!, mapboxMap, camera, 15);
      });
    }
  }

//RETURN IMAGE NAME TOO
  void _onBuildingTap(MapContentGestureContext mapContext) async {
    // Access the BuildContext using a GlobalKey or other method
    final context = _scaffoldKey.currentContext!;
    final appState = Provider.of<AppStateNotifier>(context, listen: false);
    loadingText = "Fetching building details...";

    if (isBuildingSelected) {
      // Handle office tap
      final officeId =
          await onOfficeTap(mapContext, mapboxMap!, camera, appState);
      if (officeId != null) {
        setState(() {
          selectedOfficeId =
              officeId; // This will trigger the bottom sheet update
          debugPrint('[OFFICE TAP] Office ID selected: $officeId');
        });

        // Force the bottom sheet to show the personnel
        if (buildingInfo != null) {
          setState(() {
            _showPersonnelList = true;
          });
        }
      }
      return;
    }

    try {
      // appState.setLoading(true); // Show loading overlay

      // Step 1: Perform the initial building tap logic (e.g., zooming in)
      buildingInfo = await onBuildingTap(
        mapContext,
        mapboxMap!,
        camera,
        appState.campusId,
        appState,
      );
      isBuildingSelected = true;

      if (buildingInfo != null) {
        _selectBuilding(buildingInfo!['name']);
      }

      print("BUILDING INFO: $buildingInfo");

      if (buildingInfo != null) {
        selectedBuildingCentroid = Point(
          coordinates: Position(
            buildingInfo!['centroid'][0],
            buildingInfo!['centroid'][1],
          ),
        );

        selectedBuildingId = buildingInfo!['id'];
        buildingHasFloors = buildingInfo!['hasFloors'];
        buildingEntrances = buildingInfo!['entrances'];
        buildingImgName = buildingInfo?['imgName'];

        print("BUILDING'S ENTRANCES: $buildingEntrances");

        if (buildingHasFloors == true) {
          selectedFloorId = buildingInfo!['floorId'];
        }
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      // Ensure isLoading is set to false in case of errors
      appState.setLoading(false);
    }
  }

  void _toggleImage() {
    print('Toggling image viewer. Current state: $_showImage');
    print('Building image name: $buildingImgName');

    setState(() {
      _showImage = !_showImage;
    });
  }

  int? returnOfficeId(int officeId) {
    return officeId;
  }

  void _handleSearchResultTap(int id, String type) async {
    print("ID: $id TYPE : $type");

    if (type == 'Building') {
      await _searchBuilding(id);
    } else if (type == 'Office') {
      await _searchOffice(id);
    } else if (type == 'Personnel') {
      _searchPersonnel(id);
    }
  }

  Future<void> _searchPersonnel(int personnelId) async {
    int? officeId = await fetchOfficeIdByPersonnel(personnelId);
    print("PERSONNEL $personnelId IS IN $officeId");

    if (officeId != null) {
      _searchOffice(officeId);
    }
  }

  Future<void> _searchOffice(int officeId) async {
    final context = _scaffoldKey.currentContext!;
    final loadingState = Provider.of<AppStateNotifier>(context, listen: false);
    loadingText = "Fetching office details...";
    loadingState.setLoading(true);

    try {
      final buildingId = await fetchBuildingIdByOffice(officeId);
      final floorNum = await fetchFloorNumberByOffice(officeId);

      print("OFFICE IS IN BUILDING : $buildingId");

      if (buildingId != null) {
        await _searchBuilding(buildingId);

        // Only set the office ID - the sheet will handle the rest
        setState(() {
          selectedOfficeId = officeId;
          officeFloorNum = floorNum!;
        });
      }
    } catch (e) {
      print("ERROR searching office: $e");
    } finally {
      loadingState.setLoading(false);
    }
  }

  Future<void> _searchBuilding(int buildingId) async {
    final context = _scaffoldKey.currentContext!;
    final loadingState = Provider.of<AppStateNotifier>(context, listen: false);
    print("THIS IS THE ID: $buildingId");
    loadingText = "Fetching building details...";
    fadeOutSymbols(mapboxMap!, 'outdoor-marker-layer');
    try {
      // Fetch building details using the buildingId

      await _cleanupNavigation();

      buildingInfo = await findBuildingById(
        buildingId,
        mapboxMap!,
        camera,
        loadingState.campusId,
        loadingState,
      );

      if (buildingInfo != null) {
        setState(() {
          isBuildingSelected = true;
          selectedBuildingName = buildingInfo!['name'];
          selectedBuildingCentroid = Point(
            coordinates: Position(
              buildingInfo!['centroid'][0],
              buildingInfo!['centroid'][1],
            ),
          );
          selectedBuildingId = buildingInfo!['id'];
          buildingHasFloors = buildingInfo!['hasFloors'];
          buildingEntrances = buildingInfo!['entrances'];

          print("SEARCHED BUILDING ENTRANCES: $buildingEntrances");

          if (buildingHasFloors) {
            selectedFloorId = buildingInfo!['floorId'];
          }

          pressedNavigation = false;
          isNavigating = false;
        });

        // Zoom to the building
        updateCameraPosition(selectedBuildingCentroid!, mapboxMap, camera, 15);
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      loadingState.setLoading(false);
    }
  }

  void handleFloorSelection(int floorNum) {
    // onFloorSwitch(mapboxMap!, floor);
    clearIndoorLayers(mapboxMap!);
    handleBuildingIndoor(
        mapboxMap!, selectedBuildingId, floorNum, buildingHasFloors);
  }

  Future<void> _enterNavigationView() async {
    final context = _scaffoldKey.currentContext!;
    final appState = Provider.of<AppStateNotifier>(context, listen: false);
    loadingText = "Calculating route...";

    appState.setLoading(true);

    try {
      await _cleanupNavigation();
      // 1. Get user location with null check
      LocationData? userLocationData = await getUserLocation(locationService);
      if (userLocationData == null) {
        print("Error: Unable to get user location");
        return;
      }

      Point userLocation = locationToPoint(userLocationData);

      // 2. Get route points with proper type handling
      List<Map<String, dynamic>> allPointsData =
          await fetchAllRoutePoints(appState.campusId);
      List<List<double>> routePoints = allPointsData.map((point) {
        return [
          (point['longitude'] as num).toDouble(),
          (point['latitude'] as num).toDouble(),
        ];
      }).toList();

      // 3. Check if building has entrances
      if (buildingEntrances == null || buildingEntrances!.isEmpty) {
        print("Error: No building entrances available");
        return;
      }

      // 4. Find nearest entrance with null checks
      List<double>? nearestEntrance =
          findNearestEntrance(buildingEntrances!, userLocation);
      if (nearestEntrance == null) {
        print("Error: Couldn't find nearest entrance");
        return;
      }

      // 5. Find nearest point on route
      List<double> nearestPoint =
          findNearestPolygonPoint(routePoints, nearestEntrance);
      if (nearestPoint.isEmpty) {
        print("Error: Couldn't find nearest route point");
        return;
      }

      // 6. Extract destination coordinates
      double destLat = nearestPoint[1];
      double destLon = nearestPoint[0];

      // 7. Draw the route
      await findAndDrawRoute(
        mapboxMap!,
        userLocation.coordinates.lat.toDouble(),
        userLocation.coordinates.lng.toDouble(),
        destLat,
        destLon,
        appState.campusId,
      );

      print("Shortest path drawn successfully!");

      setState(() {
        pressedNavigation = true;
      });
      _deselectBuilding();
      appState.setLoading(false);
    } catch (e) {
      print("Critical navigation error: $e");
      ToastUtil.showCustomToast(
        "Navigation failed. Please try again.",
        borderColor: Colors.red,
      );
    }
  }

  Future<void> _exitNavigationView() async {
    clearPath(mapboxMap!);
    pressedNavigation = false;
    isNavigating = false;
    _deselectBuilding();
  }

  Future<void> _cleanupNavigation() async {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    clearPath(mapboxMap!);

    if (mounted) {
      setState(() {
        isNavigating = false;
        pressedNavigation = false;
      });
    }
  }

  void stopNavigation() {
    isNavigating = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    clearPath(mapboxMap!);
    pressedNavigation = false;
    isNavigating = false;
    _deselectBuilding();
  }

  Future<void> _navigateToDestination() async {
    final context = _scaffoldKey.currentContext!;
    final appState = Provider.of<AppStateNotifier>(context, listen: false);

    try {
      // Cancel any existing navigation
      await _cleanupNavigation();

      setState(() {
        isNavigating = true;
        pressedNavigation = false;
      });

      // Start continuous location updates with rerouting
      _locationSubscription = startLocationUpdates(locationService)
          .listen((Point? userLocation) async {
        if (userLocation == null) return;

        // Get fresh route points
        List<Map<String, dynamic>> allPointsData =
            await fetchAllRoutePoints(appState.campusId);
        List<List<double>> currentRoutePoints = allPointsData.map((point) {
          return [
            (point['longitude'] as num).toDouble(),
            (point['latitude'] as num).toDouble(),
          ];
        }).toList();

        // Find nearest entrance to current location
        List<double>? nearestEntrance =
            findNearestEntrance(buildingEntrances!, userLocation);
        if (nearestEntrance == null) return;

        // Find nearest point on route to entrance
        List<double> nearestPoint =
            findNearestPolygonPoint(currentRoutePoints, nearestEntrance);

        // Draw the new route
        await findAndDrawRoute(
          mapboxMap!,
          userLocation.coordinates.lat.toDouble(),
          userLocation.coordinates.lng.toDouble(),
          nearestPoint[1],
          nearestPoint[0],
          appState.campusId,
        );

        // Calculate and update remaining distance
        double remainingDistance = haversine(
          userLocation.coordinates.lat.toDouble(),
          userLocation.coordinates.lng.toDouble(),
          nearestPoint[1],
          nearestPoint[0],
        );

        _distanceController.add(remainingDistance);

        // Check for arrival
        if (remainingDistance <= arrivalRadius) {
          _handleArrival();
        }
      });
    } catch (e) {
      print("Navigation error: $e");
      ToastUtil.showCustomToast("Navigation failed", borderColor: Colors.red);
      _cleanupNavigation();
    }
  }

  void _handleArrival() {
    // Cancel subscription
    _locationSubscription?.cancel();
    _locationSubscription = null;
    clearPath(mapboxMap!);

    // Show success message
    ToastUtil.showCustomToast(
      "🎉 You've arrived at $selectedBuildingName!",
      borderColor: Colors.green,
    );

    // Update state
    if (mounted) {
      setState(() {
        isNavigating = false;
        pressedNavigation = false;
      });
    }

    // Clear path after delay
    // Future.delayed(Duration(seconds: 5), () {
    //   if (mounted) {}
    // });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateNotifier>(context);
    ToastUtil.init(context); // Initialize toast utility

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            // Map widget as the background
            MapView(
              cameraOptions: camera,
              onMapCreated: _onMapCreated,
              onTapListener: _onBuildingTap,
            ),

            // Transparent overlay to block building interactions (above the map but below UI elements)
            // if (isBuildingSelected)
            //   Positioned.fill(
            //     child: GestureDetector(
            //       behavior: HitTestBehavior
            //           .translucent, // Ensures other gestures pass through
            //       onTap: () {
            //         print("TAPPED");
            //       }, // Blocks taps
            //     ),
            //   ),

            // UI elements (above the overlay)
            if (!pressedNavigation && !isBuildingSelected) ...[
              custom.SearchBar(
                onResultTap: _handleSearchResultTap,
              ),
              CampusDropdownWidget(
                selectedValue: dropdownValue,
                onChanged: _handleDropdownChange,
                locationPoints: locationPoints.keys.toList(),
              ),
              Positioned(
                bottom: 130, // Adjust the position as needed
                right: 20, // Adjust the position as needed
                child: MapButtons(
                  onRefresh: _detectUserInBound, // Refresh function
                  onRecenter: _onRecenter, // Recenter function
                ),
              ),
            ],

            // Show top bar, building details, and navigation button when a building is selected
            if (!pressedNavigation && isBuildingSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 100, // Adjust this value to avoid overlapping
                child: BuildingDetailsSheet(
                  selectedBuildingInfo: buildingInfo,
                  onFloorSelected: handleFloorSelection,
                  selectedOfficeId: selectedOfficeId,
                  initialFloorNum: officeFloorNum,
                ),
              ),

            // Other widgets (e.g., TopBar, FloatingNavigationButton)
            if (!pressedNavigation && isBuildingSelected) ...[
              TopBar(
                isBuildingSelected: isBuildingSelected,
                selectedBuildingName: selectedBuildingName,
                onBackPressed: _deselectBuilding,
                onImagePressed: _toggleImage,
              ),
              FloatingNavigationButton(
                onPressed: _enterNavigationView,
                isVisible: isBuildingSelected,
                isInCampus: isInCampus,
              ),
            ],

            // Show navigation card and buttons when navigation is active
            if (pressedNavigation) ...[
              NavigationCard(
                isVisible: pressedNavigation,
                buildingName: selectedBuildingName,
                // onCancelNavigation: _exitNavigationView,
              ),
              Positioned(
                bottom: 20, // Place buttons at the bottom
                left: 20,
                right: 20,
                child: NavigationButtons(
                  onStart: _navigateToDestination, // Start navigation
                  onCancel: _exitNavigationView, // Cancel navigation
                ),
              ),
            ],

            // Show navigation bottom sheet when navigating
            if (isNavigating) ...[
              NavigationTopBar(
                isNavigationVisible: isNavigating,
                buildingName: selectedBuildingName,
                onCancelNavigation: stopNavigation,
              ),
              NavigationBottomSheet(
                buildingName: selectedBuildingName,
                distanceStream: distanceStream,
              ),
            ],

            if (_showImage)
              BuildingImageViewer(
                imageName: buildingImgName, // Can be null
                onClose: _toggleImage,
              ),

            // Show loading overlay when isLoading is true
            if (appState.isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(255, 32, 22, 84).withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/loading_cycle.json', // Loading animation
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 20), // Spacing
                        Text(
                          loadingText, // Dynamic loading text
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (appState.isAnimation)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // Block all taps
                  child: Container(
                    color: Colors.transparent, // Transparent overlay
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
