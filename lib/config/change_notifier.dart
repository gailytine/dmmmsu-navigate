import 'package:flutter/material.dart';

class AppStateNotifier with ChangeNotifier {
  bool _isLoading = false; // Tracks loading state
  bool _isAnimation = false; // Tracks animation state
  int _campusId = 1;

  bool get isLoading => _isLoading;
  bool get isAnimation => _isAnimation;
  int get campusId => _campusId;

  void setCampusId(int newCampusId) {
    if (_campusId != newCampusId) {
      _campusId = newCampusId;
      notifyListeners(); // Notify listeners when campusId changes
    }
  }

  // Method to set loading state
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners(); // Notify listeners when isLoading changes
    }
  }

  // Method to set animation state
  void setAnimation(bool value) {
    if (_isAnimation != value) {
      _isAnimation = value;
      notifyListeners(); // Notify listeners when isAnimation changes
    }
  }

  // Method to reset both states
  void reset() {
    _isLoading = false;
    _isAnimation = false;
    notifyListeners(); // Notify listeners when both states are reset
  }
}