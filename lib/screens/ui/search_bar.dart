import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/local_database/queries.dart';
import '../../config/change_notifier.dart';
import 'package:provider/provider.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchBar extends StatefulWidget {
  final Function(int id, String type)? onResultTap;

  const SearchBar({Key? key, this.onResultTap}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  List<Map<String, dynamic>> _searchResults = [];

  Future<List<Map<String, dynamic>>> fetchNames(int campusId) async {
    final Database db = await getDatabase();
    return await db.rawQuery('''
      SELECT id, name, 'Building' AS type 
      FROM places 
      WHERE campus_id = ? AND type = 'building'

      UNION

      SELECT offices.id, offices.name, 'Office' AS type 
      FROM offices
      JOIN floors ON offices.floor_id = floors.id
      JOIN buildings ON floors.building_id = buildings.id
      JOIN places ON buildings.place_id = places.id
      WHERE places.campus_id = ?

      UNION

      SELECT personnel.id, personnel.name, 'Personnel' AS type 
      FROM personnel
      JOIN offices ON personnel.office_id = offices.id
      JOIN floors ON offices.floor_id = floors.id
      JOIN buildings ON floors.building_id = buildings.id
      JOIN places ON buildings.place_id = places.id
      WHERE places.campus_id = ?
    ''', [campusId, campusId, campusId]);
  }

  void _search(String query) {
    _debouncer.run(() async {
      if (query.isEmpty) {
        setState(() {
          _searchResults.clear();
        });
        return;
      }

      // Use Provider.of to access the CampusIdNotifier
      final campusIdNotifier =
          Provider.of<AppStateNotifier>(context, listen: false);
      final results = await fetchNames(campusIdNotifier.campusId);

      setState(() {
        _searchResults = results
            .where((item) =>
                item["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 20.0), // Add padding at the top of the Column
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Add vertical padding
            margin:
                EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(66, 32, 35, 110),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with your logo path
                    height: 24,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "Search for a place",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _search,
                  ),
                ),
                Icon(Icons.search, color: Colors.blue),
              ],
            ),
          ),

          // Search Results
          if (_searchResults.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 10, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(66, 32, 35, 110),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      200, // Adjust the max height of the results container
                ),
                child: Scrollbar(
                  thumbVisibility: true, // Show scrollbar when scrolling
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      bool isTapped = false; // Track tap state

                      return StatefulBuilder(
                        builder: (context, setInnerState) {
                          return Material(
                            color: Colors
                                .transparent, // Important for `InkWell` effect
                            child: InkWell(
                              onTapDown: (_) {
                                setInnerState(() => isTapped = true);
                              },
                              onTapCancel: () {
                                setInnerState(() => isTapped = false);
                              },
                              onTap: () {
                                setInnerState(() => isTapped = false);
                                if (widget.onResultTap != null) {
                                  widget.onResultTap!(
                                      item["id"],
                                      item[
                                          "type"]); // Pass id and type to the callback
                                  // print("Tapped on: ${item["id"]}");
                                }
                              },
                              splashColor: Colors.blue.withOpacity(0.3),
                              highlightColor: Colors.blue.withOpacity(0.1),
                              child: Container(
                                color: isTapped
                                    ? Colors.grey[300]
                                    : Colors
                                        .transparent, // Change background on tap
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"] ?? "Unknown",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      item["type"] ?? "Unknown",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
