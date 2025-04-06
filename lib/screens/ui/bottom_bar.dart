import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';

class BuildingDetailsSheet extends StatefulWidget {
  final Map<String, dynamic>? selectedBuildingInfo;
  final Function(int)? onFloorSelected;
  final int? selectedOfficeId;
  final int? initialFloorNum;

  const BuildingDetailsSheet({
    Key? key,
    this.selectedBuildingInfo,
    this.onFloorSelected,
    this.selectedOfficeId,
    this.initialFloorNum,
  }) : super(key: key);

  @override
  _BuildingDetailsSheetState createState() => _BuildingDetailsSheetState();
}

class _BuildingDetailsSheetState extends State<BuildingDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> floors = [];
  Map<String, List<Map<String, dynamic>>> offices = {};
  int selectedFloorNum = 0;

  // DraggableScrollableController
  final DraggableScrollableController _mainSheetController =
      DraggableScrollableController();
  bool _isMainSheetExpanded = false;

  bool _showPersonnelSheet = false;
  DraggableScrollableController _personnelSheetController =
      DraggableScrollableController();
  Map<String, dynamic>? _selectedOffice;

  void _selectOffice(int officeId) {
    if (widget.selectedBuildingInfo == null) return;

    final offices = (widget.selectedBuildingInfo!['officesInfo'] as List)
        .cast<Map<String, dynamic>>();

    try {
      final office = offices.firstWhere((o) => o['id'] == officeId);
      setState(() {
        _selectedOffice = office;
        _showPersonnelSheet =
            true; // Show the personnel sheet instead of just the list
      });
      _expandMainSheet(); // Expand the main sheet to make room
    } catch (e) {
      // Office not found
      setState(() {
        _selectedOffice = null;
        _showPersonnelSheet = false; // Ensure personnel sheet is hidden
      });
    }
  }

  @override
  void didUpdateWidget(covariant BuildingDetailsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When a new office ID is passed, find and select that office
    if (widget.selectedOfficeId != null &&
        widget.selectedOfficeId != oldWidget.selectedOfficeId) {
      _selectOffice(widget.selectedOfficeId!);
    }
  }

  @override
  // @override
  void initState() {
    super.initState();
    _initializeData();
    _mainSheetController.addListener(_updateMainSheetState);

    // Delay the initial toggle to ensure the sheet is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedOfficeId != null) {
        _selectOfficeById(widget.selectedOfficeId!);
      }

      if (widget.initialFloorNum != null && _tabController.length > 0) {
        final floorIndex = widget.initialFloorNum! - 1;
        if (floorIndex >= 0 && floorIndex < _tabController.length) {
          _tabController.animateTo(floorIndex);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_personnelSheetController.isAttached) {
        _personnelSheetController.reset(); // Reset any stuck positions
      }
    });
  }

  void _initializeData() {
    if (widget.selectedBuildingInfo != null) {
      final totalFloors = widget.selectedBuildingInfo!['totalFloorNum'] as int;
      final officesInfo = widget.selectedBuildingInfo!['officesInfo']
          as List<Map<String, dynamic>>;

      floors = List.generate(totalFloors, (index) => 'F-${index + 1}');
      final Map<int, List<Map<String, dynamic>>> groupedOffices = {};

      for (var office in officesInfo) {
        final floorNum = office['floorNum'] as int;
        groupedOffices.putIfAbsent(floorNum, () => []).add({
          'id': office['id'],
          'name': office['name'],
          'floorNum': office['floorNum'],
          'personnel': office['personnel'] ?? [],
        });
      }

      offices = {};
      for (var i = 0; i < totalFloors; i++) {
        final floorName = floors[i];
        final floorNum = i + 1;
        offices[floorName] = groupedOffices[floorNum] ?? [];
      }
    }

    // Initialize the TabController
    _tabController = TabController(length: floors.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        selectedFloorNum = _tabController.index + 1;
        widget.onFloorSelected?.call(selectedFloorNum);
      }
    });
  }

  void _selectOfficeById(int officeId) {
    debugPrint('[DEBUG] Starting _selectOfficeById with officeId: $officeId');
    debugPrint(
        '[DEBUG] Current state - show: $_showPersonnelSheet, office: ${_selectedOffice?['id']}');

    // First force close any existing sheet
    debugPrint('[DEBUG] Closing personnel sheet');
    _closePersonnelSheet();

    // Then after a delay, reopen with new selection
    Future.delayed(Duration(milliseconds: 250), () {
      if (!mounted) {
        debugPrint('[DEBUG] Widget not mounted, aborting');
        return;
      }

      debugPrint(
          '[DEBUG] Searching for office $officeId in ${offices.length} floors');

      bool officeFound = false;

      for (var floor in offices.keys) {
        debugPrint('[DEBUG] Checking floor $floor');
        for (var office in offices[floor]!) {
          debugPrint('[DEBUG] Checking office ${office['id']}');
          if (office['id'] == officeId) {
            debugPrint(
                '[DEBUG] Found matching office: ${office['id']} - ${office['name']}');
            officeFound = true;

            setState(() {
              _selectedOffice = office;
              _showPersonnelSheet = true;
              debugPrint(
                  '[DEBUG] Updated state - show: $_showPersonnelSheet, office: ${_selectedOffice?['id']}');
            });

            _expandMainSheet();

            // Force the personnel sheet to open
            if (_personnelSheetController.isAttached) {
              debugPrint('[DEBUG] Animating personnel sheet open');
              _personnelSheetController
                  .animateTo(
                0.7,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              )
                  .then((_) {
                debugPrint('[DEBUG] Personnel sheet animation complete');
              });
            } else {
              debugPrint('[WARNING] Personnel sheet controller not attached');
            }
            break;
          }
        }
        if (officeFound) break;
      }

      if (!officeFound) {
        debugPrint('[WARNING] Office $officeId not found in any floor');
      }
    });
  }

  void _expandMainSheet() async {
    if (!_mainSheetController.isAttached) {
      await Future.delayed(Duration(milliseconds: 100));
      _expandMainSheet();
      return;
    }

    try {
      await _mainSheetController.animateTo(
        0.7,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint("Sheet expansion error: $e");
    }
  }

  void _onOfficeSelected(Map<String, dynamic> office) {
    // First, close the sheet and reset state
    setState(() {
      _showPersonnelSheet = false;
      _selectedOffice = null;
    });

    // Then after a small delay, reopen with the same office
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _selectedOffice = office;
          _showPersonnelSheet = true;
        });
        _expandMainSheet();

        // Force the personnel sheet to open
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_personnelSheetController.isAttached) {
            _personnelSheetController.animateTo(
              0.7,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _closePersonnelSheet() {
    // Reset the personnel sheet controller
    if (_personnelSheetController.isAttached) {
      _personnelSheetController.animateTo(
        0.0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }

    // Reset the state after animation completes

    if (mounted) {
      setState(() {
        _showPersonnelSheet = false;
        _selectedOffice = null;
      });
    }
  }

  // Update sheet state based on controller size
  void _updateMainSheetState() {
    if (_mainSheetController.isAttached) {
      setState(() {
        _isMainSheetExpanded = _mainSheetController.size > 0.5;
      });
    }
  }

  // Method to toggle the sheet size

  void _toggleMainSheetSize() async {
    while (!_mainSheetController.isAttached) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    setState(() {
      _isMainSheetExpanded = !_isMainSheetExpanded;
    });

    await _mainSheetController.animateTo(
      _isMainSheetExpanded ? 0.7 : 0.25,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onOfficeButtonTapped(Map<String, dynamic> office) {
    setState(() => _showPersonnelSheet = false);

    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _selectedOffice = office;
          _showPersonnelSheet = true;
          _isMainSheetExpanded = true;
        });
        _expandMainSheet();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainSheetController.removeListener(_updateMainSheetState);
    _mainSheetController.dispose();
    _personnelSheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (floors.isEmpty || widget.selectedBuildingInfo == null) {
      return SizedBox.shrink();
    }

    debugPrint(
        "Building sheet - show personnel: $_showPersonnelSheet, office: ${_selectedOffice?['id']}");

    return Stack(
      children: [
        DraggableScrollableSheet(
          controller: _mainSheetController,
          initialChildSize: 0.25, // Initial peek height
          minChildSize: 0.25, // Minimum height
          maxChildSize: 0.7, // Maximum height
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleMainSheetSize,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Icon(
                          _isMainSheetExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),

                  // Floor Tabs

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey[500],
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: floors.map((floor) {
                        return Tab(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width /
                                floors.length,
                            child: Center(
                              child: Text(
                                floor,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // AnimatedSwitcher for Office List and Personnel List

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: floors.map((floor) {
                        final floorOffices = offices[floor] ?? [];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount:
                                floorOffices.isEmpty ? 1 : floorOffices.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[300],
                              height: 5,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) {
                              if (floorOffices.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.apartment,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "No offices here",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final office = floorOffices[index];
                              final officeName =
                                  office['name'] as String? ?? 'Unknown Office';

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    officeName,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.chevron_right,
                                          color: Colors.grey[600]),
                                      onPressed: () =>
                                          _onOfficeSelected(office),
                                      padding: EdgeInsets.all(3),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_showPersonnelSheet) _buildPersonnelOverlaySheet(),
      ],
    );
  }

  Widget _buildOfficeList(ScrollController scrollController) {
    return Column(
      key: ValueKey('office-list'),
      children: [
        // Office List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: floors.map((floor) {
              final floorOffices = offices[floor] ?? [];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: floorOffices.isEmpty ? 1 : floorOffices.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 5,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (floorOffices.isEmpty) {
                      // Placeholder with building icon and centered text
                      return Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Add padding around the placeholder
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apartment, // Building icon
                                size: 60, // Adjust size as needed
                                color: Colors.grey[400], // Subtle color
                              ),
                              SizedBox(
                                  height: 16), // Spacing between icon and text
                              Text(
                                "No offices here",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final office = floorOffices[index];
                    final officeName =
                        office['name'] as String? ?? 'Unknown Office';

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          officeName,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.chevron_right,
                                color: Colors.grey[600]),
                            onPressed: () {
                              _onOfficeButtonTapped(office);
                            },
                            padding: EdgeInsets.all(3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonnelOverlaySheet() {
    if (!_personnelSheetController.isAttached) {
      _personnelSheetController = DraggableScrollableController();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: _closePersonnelSheet,
        behavior: HitTestBehavior.opaque,
        child: DraggableScrollableSheet(
          controller: _personnelSheetController,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          snap: true,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () {}, // Prevent taps from closing the sheet
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with back button and office name
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _closePersonnelSheet,
                        ),
                        title: Text(
                          _selectedOffice?['name'] ?? 'Office Personnel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    // Personnel list
                    Expanded(
                      child: _buildPersonnelList(scrollController),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonnelList(ScrollController scrollController) {
    final personnelList = _selectedOffice?['personnel'] ?? [];

    if (personnelList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "No personnel in this office",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: personnelList.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final personnel = personnelList[index];
        return ListTile(
          title: Text(personnel['name'] ?? 'Unknown'),
          subtitle: Text(personnel['position'] ?? ''),
        );
      },
    );
  }
}
