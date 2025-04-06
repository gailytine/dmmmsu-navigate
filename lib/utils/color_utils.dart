int hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  return int.parse("0xFF$hex");
}

String interpolateColor(String startColor, String endColor, double ratio) {
  // Convert hex colors to RGB
  final start = _hexToRgb(startColor);
  final end = _hexToRgb(endColor);

  // Interpolate RGB values
  final r = (start[0] + (end[0] - start[0]) * ratio).round();
  final g = (start[1] + (end[1] - start[1]) * ratio).round();
  final b = (start[2] + (end[2] - start[2]) * ratio).round();

  // Convert RGB back to hex
  return '#${r.toRadixString(16).padLeft(2, '0')}'
         '${g.toRadixString(16).padLeft(2, '0')}'
         '${b.toRadixString(16).padLeft(2, '0')}';
}

List<int> _hexToRgb(String hex) {
  hex = hex.replaceAll('#', '');
  return [
    int.parse(hex.substring(0, 2), radix: 16),
    int.parse(hex.substring(2, 4), radix: 16),
    int.parse(hex.substring(4, 6), radix: 16),
  ];
}