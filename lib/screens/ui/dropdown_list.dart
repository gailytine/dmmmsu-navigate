import 'package:flutter/material.dart';

class CampusDropdownWidget extends StatefulWidget {
  final String selectedValue;
  final Function(String) onChanged;
  final List<String> locationPoints;

  const CampusDropdownWidget({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    required this.locationPoints,
  }) : super(key: key);

  @override
  _CampusDropdownWidgetState createState() => _CampusDropdownWidgetState();
}

class _CampusDropdownWidgetState extends State<CampusDropdownWidget> {
  bool _isExpanded = false; // Track if the bottom sheet is open

  void _showDropdownSheet(BuildContext context) async {
    setState(() {
      _isExpanded = true;
    });

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          height: 250, // Adjusted height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Down arrow icon instead of the "-" handle
              Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.blue),
              SizedBox(height: 10),

              // Options list
              Expanded(
                child: ListView(
                  children: widget.locationPoints.map((value) {
                    bool isSelected = value == widget.selectedValue;
                    return ListTile(
                      title: Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ),
                      tileColor:
                          isSelected ? Colors.blue[100] : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        widget.onChanged(value);
                        Navigator.pop(context); // Close bottom sheet
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );

    // When the bottom sheet is closed, reset state
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () => _showDropdownSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 32, 35, 110),
                blurRadius: 4,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down // ▼ when expanded
                    : Icons.keyboard_arrow_up, // ▲ when collapsed
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(height: 6),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.selectedValue.isNotEmpty
                      ? Colors.blue[100]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  widget.selectedValue.isNotEmpty
                      ? widget.selectedValue
                      : "Select a location",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
